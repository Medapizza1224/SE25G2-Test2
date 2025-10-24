#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
ci_review.py（CI 用レビュースクリプト）

概要（やること）
1) PR で変更された docs/SRS/*.md を収集
2) 各 SRS に行番号を付与（例: "0001│ ...")
3) review_runner.py の仕様に合わせ、repo ルートの srs/ に“一時コピー”
   ↳ review_runner.py は「--srs <ファイル名>」で srs/ を参照
4) review_runner.py を起動（モデルや出力形式は review_runner 側に準拠）
5) 生成 JSON を読み取り、PR にコメント投稿（総評1件＋行コメント複数）

使い方（ローカル検証・CI 共通の考え方）
- 既定: review_runner.py の MODELS/SRS 設定をそのまま使用（“コマンドで必須指定しない”方針）
    python generate_review/ci_review.py
- 必要時だけモデルを一時上書き（任意）
    python generate_review/ci_review.py --models gpt-5-mini,gpt-4.1

環境変数（CI から受け取り）
- REPO, PR_NUMBER, GITHUB_TOKEN（必須）

備考
- 日本語は UTF-8 のまま送信。requests はデフォルトで UTF-8 を扱えるため追加設定は不要です。
"""

from __future__ import annotations
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import textwrap
import time
from pathlib import Path
from collections import deque
from typing import Dict, Any, List, Tuple, Optional

import difflib
import requests

# ========= 基本パス =========
ROOT = Path(__file__).resolve().parents[1]          # リポジトリルート
SRS_INPUT_DIR = ROOT / "docs" / "SRS"               # 変更検出対象ディレクトリ
SRS_STAGING_DIR = ROOT / "srs"                       # ★review_runner が読む場所（A案：ここへ一時コピー）
RESULT_DIR = ROOT / "generate_review_result"         # review_runner の出力置き場
RUNNER = ROOT / "generate_review" / "review_runner.py"  # 既存スクリプト

# ========= ログ =========
# 直近ログの簡易リングバッファ（失敗通知に貼る用）
LOG_RING: deque[str] = deque(maxlen=1000)
def info(msg: str) -> None:
    print(f"[ci_review] {msg}", flush=True)
    try:
        LOG_RING.append(f"[INFO] {msg}")
    except Exception:
        pass

def warn(msg: str) -> None:
    print(f"[ci_review][warn] {msg}", flush=True)
    try:
        LOG_RING.append(f"[WARN] {msg}")
    except Exception:
        pass

# ========= GitHub API（薄いラッパ：簡易リトライ） =========
def gh_get(url: str, token: str, params: Optional[Dict[str, Any]] = None, max_tries: int = 3):
    headers = {"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"}
    for i in range(1, max_tries+1):
        try:
            r = requests.get(url, headers=headers, params=params or {})
            # 2xx 以外は raise_for_status で例外化
            r.raise_for_status()
            return r
        except Exception as e:
            if i == max_tries:
                raise
            warn(f"GET retry {i}/{max_tries-1} after error: {e}")
            time.sleep(1.0 * i)

def gh_post(url: str, token: str, payload: Dict[str, Any], max_tries: int = 3):
    headers = {"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"}
    for i in range(1, max_tries+1):
        try:
            r = requests.post(url, headers=headers, json=payload)
            # 2xx 以外は例外化（本文も出す）
            if r.status_code >= 300:
                raise RuntimeError(f"POST {url} failed: {r.status_code} {r.text}")
            return r
        except Exception as e:
            if i == max_tries:
                raise
            warn(f"POST retry {i}/{max_tries-1} after error: {e}")
            time.sleep(1.0 * i)

# ========= PR 差分から docs/SRS/*.md を取得 =========
def get_changed_files(repo: str, pr_number: int, token: str) -> List[Dict[str, Any]]:
    """
    GitHub API: GET /repos/{owner}/{repo}/pulls/{pull_number}/files
    戻り値の各要素には filename/status/patch などが入る。
    """
    url = f"https://api.github.com/repos/{repo}/pulls/{pr_number}/files"
    files = []
    page = 1
    while True:
        r = gh_get(url, token, params={"page": page, "per_page": 100})
        batch = r.json()
        files.extend(batch)
        if len(batch) < 100:
            break
        page += 1
    return files

# ========= 行番号付与（0001│ のようなフォーマット） =========
def number_srs(src: Path) -> Path:
    """
    入力: docs/SRS/*.md の実ファイル
    出力: /tmp に作る一時ファイル（中身は行番号付与済み）
    """
    lines = src.read_text(encoding="utf-8").splitlines()
    numbered = "\n".join(f"{i:04d}│ {line}" for i, line in enumerate(lines, 1))
    tmp = Path(tempfile.gettempdir()) / f"numbered_{src.name}"
    tmp.write_text(numbered, encoding="utf-8")
    return tmp

# ========= 既存 review_runner の起動（A案の核心） =========
def run_review_runner_with_staged_file(staged_name: str, models_arg: Optional[str]) -> None:
    """
    review_runner.py は従来どおり「--srs <ファイル名>」で srs/ を参照する前提。
    - staged_name には SRS_STAGING_DIR に置いた“一時ファイル名”を渡す
    - cwd=ROOT で起動し、相対パス参照（input_prompt など）を安全にする
    """
    cmd = [sys.executable, str(RUNNER), "--srs", staged_name]
    if models_arg:
        # 任意。指定があれば review_runner のハードコード設定を上書き可能
        cmd += ["--models", models_arg]

    info("$ " + " ".join(cmd))
    # 出力を捕捉しつつ実行（失敗通知にログを添付できるように）
    p = subprocess.run(
        cmd,
        check=True,
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    if p.stdout:
        for ln in p.stdout.splitlines():
            print(ln)
            try:
                LOG_RING.append(f"[runner][out] {ln}")
            except Exception:
                pass
    if p.stderr:
        for ln in p.stderr.splitlines():
            print(ln, file=sys.stderr)
            try:
                LOG_RING.append(f"[runner][err] {ln}")
            except Exception:
                pass


# ========= 生成結果の読み取りとPRコメント投稿 =========
def find_latest_json_for(stem_prefix: str) -> Optional[Path]:
    """
    generate_review_result/ に作られた <stem>__<model>.json を見つける。
    複数モデルがある場合、タイムスタンプ新しいものを採用。
    """
    if not RESULT_DIR.exists():
        return None
    cands = sorted(RESULT_DIR.glob(f"{stem_prefix}__*.json"), key=lambda p: p.stat().st_mtime, reverse=True)
    return cands[0] if cands else None

def post_overall_comment(repo: str, pr_number: int, token: str, overall: str) -> None:
    url = f"https://api.github.com/repos/{repo}/issues/{pr_number}/comments"
    gh_post(url, token, {"body": overall})

def ensure_review_comment_thread(repo: str, pr_number: int, token: str) -> int:
    """
    PR レビュー用のスレッド（コメント）を開始するためのダミー "EVENT_REQUEST_CHANGES" を作成。
    - GitHub API: POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews
    - 戻り値 JSON に review.id が入る
    """
    url = f"https://api.github.com/repos/{repo}/pulls/{pr_number}/reviews"
    payload = {
        "body": "Auto review comments",
        "event": "REQUEST_CHANGES",  # thread を作るために一旦 changes 要求
    }
    r = gh_post(url, token, payload)
    rid = r.json().get("id")
    if not rid:
        raise RuntimeError("review.id を取得できませんでした")
    return int(rid)

def submit_review_comments(repo: str, pr_number: int, token: str, review_id: int, comments: List[Dict[str, Any]]) -> None:
    """
    まとめて行コメントを送信
    - GitHub API: POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews/{review_id}/comments
    - payload は { comments: [ { path, position, body }, ... ] }
    """
    url = f"https://api.github.com/repos/{repo}/pulls/{pr_number}/reviews/{review_id}/comments"
    gh_post(url, token, {"comments": comments})

def find_patch_position_for_line(patch_text: str, target_line_text: str) -> Optional[int]:
    """
    GitHub の "position" は unified diff 上の行番号。対象の行テキストが
    unified diff のどこに現れるかを探し、その位置を返す。
    - 完全一致ではなく、余計な空白等の差異を吸収するために近似マッチを使用
    """
    best_pos = None
    best_ratio = 0.0
    lines = patch_text.splitlines()
    for i, ln in enumerate(lines, 1):
        ratio = difflib.SequenceMatcher(None, ln.strip(), target_line_text.strip()).ratio()
        if ratio > best_ratio:
            best_ratio = ratio
            best_pos = i
    # ある程度以上似ていないと採用しない
    if best_ratio < 0.6:
        return None
    return best_pos

def build_pr_review_comments_from_json(repo: str, pr_number: int, token: str, items: List[Dict[str, Any]], files_meta: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    review_items[] から PR 行コメント（path/position/body）を構築
    - position を決めるために PR ファイルごとの unified diff を参照
    """
    comments: List[Dict[str, Any]] = []

    # PR で変更されたファイルの filename -> patch（unified diff）を引くための辞書
    patch_map: Dict[str, str] = {}
    for f in files_meta:
        fn = f.get("filename")
        patch = f.get("patch")
        if not fn or not patch:
            continue
        patch_map[fn] = patch

    for it in items:
        line_text = it.get("line")
        comment = it.get("comment")
        if not line_text or not comment:
            continue

        # 今回は docs/SRS/ 配下しかレビューしない前提
        # まず対象 path 候補を列挙（SRS 内の一番似ているファイルに付ける）
        srs_paths = [p for p in patch_map.keys() if p.startswith("docs/SRS/")]
        if not srs_paths:
            continue

        best_path = None
        best_score = 0.0
        for p in srs_paths:
            # ファイル名の stem が近いものを優先（簡易）
            score = difflib.SequenceMatcher(None, Path(p).stem, "".join(re.findall(r"\w+", line_text.lower()))[:20]).ratio()
            if score > best_score:
                best_path = p
                best_score = score

        if not best_path:
            best_path = srs_paths[0]

        patch_text = patch_map.get(best_path, "")
        pos = find_patch_position_for_line(patch_text, line_text)
        if pos is None:
            # 位置が見つからない場合、最低限コメント本文だけでも残す（fall back）
            body = f"[行位置が特定できませんでした]\n\n{comment}\n\n> {line_text}"
            comments.append({"path": best_path, "position": 1, "body": body})
            continue

        body = comment
        comments.append({
            "path": best_path,
            "position": int(pos),
            "body": body,
        })

    return comments


# ========= メインフロー =========
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--models", help="任意。モデルを一時上書き（カンマ区切り）。未指定時は review_runner の既定を使用。")
    args = parser.parse_args()

    repo = os.environ.get("REPO")
    pr_number = os.environ.get("PR_NUMBER")
    token = os.environ.get("GITHUB_TOKEN")
    if not repo or not pr_number or not token:
        print("REPO/PR_NUMBER/GITHUB_TOKEN の環境変数が必要です", file=sys.stderr)
        sys.exit(2)
    pr_number_i = int(pr_number)

    info(f"REPO={repo} PR={pr_number_i}")

    # 1) PRの変更ファイル一覧
    files_meta = get_changed_files(repo, pr_number_i, token)
    srs_files = [f for f in files_meta if f.get("filename", "").startswith("docs/SRS/")]
    if not srs_files:
        info("docs/SRS/ 配下の変更が見つからないため、処理を終了します。")
        return

    # 2) 行番号付与 -> 3) srs/ にステージング
    SRS_STAGING_DIR.mkdir(exist_ok=True)
    for f in srs_files:
        rel = f["filename"]
        src = ROOT / rel
        if not src.exists():
            warn(f"変更検出されたが実体がない: {src}")
            continue
        num = number_srs(src)
        staged_name = f"ci_numbered__{src.name}"
        dst = SRS_STAGING_DIR / staged_name
        info(f"stage: {src} -> {dst}")
        dst.write_text(num.read_text(encoding="utf-8"), encoding="utf-8")

        # 4) review_runner 起動
        try:
            run_review_runner_with_staged_file(staged_name, args.models)
        except subprocess.CalledProcessError as e:
            warn(f"review_runner 実行に失敗: {e}")
            # 失敗時はログをPRに貼り付ける
            log_text = "\n".join(list(LOG_RING))
            overall = textwrap.dedent(f"""
            🚨 自動レビュー実行に失敗しました
            - スクリプト: generate_review/review_runner.py
            - 例外: {e}

            <details><summary>直近ログ</summary>

            ```
            {log_text}
            ```
            </details>
            """
            ).strip()
            post_overall_comment(repo, pr_number_i, token, overall)
            continue

        # 5) 生成 JSON 読み取り -> コメント投稿
        stem_prefix = Path(staged_name).stem  # 例: ci_numbered__se24g2
        json_path = find_latest_json_for(stem_prefix)
        if not json_path or not json_path.exists():
            warn(f"結果 JSON が見つかりません: {json_path}")
            continue

        data = json.loads(json_path.read_text(encoding="utf-8"))
        overall = data.get("overall")
        items = data.get("review_items", [])

        if overall:
            post_overall_comment(repo, pr_number_i, token, overall)

        if items:
            review_id = ensure_review_comment_thread(repo, pr_number_i, token)
            comments = build_pr_review_comments_from_json(repo, pr_number_i, token, items, files_meta)
            if comments:
                submit_review_comments(repo, pr_number_i, token, review_id, comments)


if __name__ == "__main__":
    main()

