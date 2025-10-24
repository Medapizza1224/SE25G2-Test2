#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
review_runner.py（Responses + Structured Outputs／Chat + Function Calling 両対応）

概要
- gpt-5 系: Responses API の Structured Outputs（json_schema）で“サーバ側”で構造を強制
- その他: Chat Completions + Function Calling（tools）で“クライアント側”で構造を強制
- system_v4.0.txt には教育方針のみ（スキーマは本スクリプトで一元管理）

使い方（モデルや対象はファイル内デフォルトで動作。CLI指定は任意）
- そのまま実行（ファイル内の MODELS/SRS_PATTERNS を使用）
    python generate_review/review_runner.py

- 対象SRSを一時的に変更（--srs は任意。未指定なら SRS_PATTERNS を使用）
    python generate_review/review_runner.py --srs se24g2.md
    python generate_review/review_runner.py --srs "se24g*.md"

- モデルを一時的に上書き（--models は任意。未指定なら MODELS を使用）
    python generate_review/review_runner.py --models gpt-5-mini,gpt-4.1-mini

出力
- ディレクトリ: generate_review_result/
- 形式: <stem>__<model>.json（例: se24g2__gpt-5.json）

前提・環境
- .env に API キーを設定（python-dotenv で自動ロード）
  - OPENAI_API_KEY（OpenAI）
  - GOOGLE_API_KEY または GEMINI_API_KEY（Gemini 使用時）

備考
- “モデル選択をコマンドで必須にしない”方針のため、既定は本ファイル内の定数で管理します。
- CLI で与えた --models/--srs がある場合のみ一時的に上書きします。
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Tuple

from dotenv import load_dotenv
from openai import OpenAI
from google import genai
from google.genai import types as gtypes
import argparse


# =============================
# ハードコード設定
# =============================

MODELS: List[str] = [
    "gpt-5",          # Responses + Structured Outputs
    # "gpt-5-mini",   # Responses + Structured Outputs
    # "gpt-4.1-mini",   # Chat + Function Calling
    # "gpt-4.1",
    # "o3",
    # "gemini-2.5-flash", # Gemini + Structured Output
    # "gemini-2.5-pro",   # Gemini + Structured Output
]

SRS_PATTERNS: List[str] = [
    "se18g2.md",
]

HERE = Path(__file__).resolve().parent   # generate_review/
ROOT = HERE.parent
INPUT_PROMPT_DIR = HERE / "input_prompt"
SRS_DIR = ROOT / "srs"
OUT_DIR = ROOT / "generate_review_result"

SYSTEM_FILE = INPUT_PROMPT_DIR / "system_v4.0.txt"
RUBRIC_FILE = INPUT_PROMPT_DIR / "rubric_craftn.md"

# Chat（非 gpt-5）側
CHAT_MAX_TOKENS = 4096
CHAT_TEMPERATURE: float | None = None

# gpt-5（Responses）側
GPT5_MODELS = {"gpt-5","gpt-5-mini","o3"}  # 必要に応じて追加
GPT5_MAX_OUTPUT_TOKENS = 32768 # 8192 | 16384 | 32768
GPT5_REASONING_EFFORT = "medium"           # "low" | "medium" | "high"
GPT5_EMPTY_RETRY = True
GPT5_RETRY_FACTOR = 2.0
RESPONSES_TOOL_CHOICE = {"type": "function", "name": "emit_review"}  # ← function.name ではなく name

def _strip_ci_prefix(stem: str) -> str:
    """ci_review が作る一時名 'ci_numbered__<stem>' を元の stem に戻す。"""
    return stem[len("ci_numbered__"):] if stem.startswith("ci_numbered__") else stem

def parse_args():
    """
    CLI 引数（任意）。未指定時はファイル内定数 MODELS/SRS_PATTERNS を使用します。

    --srs
        - 対象 SRS（srs/ 配下を想定）。相対パス・ワイルドカード可。
        - 例: --srs se24g2.md / --srs "se24g*.md"
    --models
        - 一時的にモデルを上書き（カンマ区切り）。
        - 例: --models gpt-5-mini,gpt-4.1
    """
    p = argparse.ArgumentParser(description="Run SRS reviews with schema-enforced outputs.")
    p.add_argument("--srs", nargs="+", help="任意。対象SRS（srs/ 配下）。相対/ワイルドカード可。未指定時は SRS_PATTERNS を使用。")
    p.add_argument("--models", help="任意。モデルを一時上書き（カンマ区切り）。未指定時は MODELS を使用。")
    return p.parse_args()

def resolve_srs_targets_from_cli(tokens: list[str]) -> list[Path]:
    """
    --srs で渡されたトークンから、実ファイル Path を解決する。
    原則 srs/ 配下にステージされている想定。
    """
    outs: list[Path] = []
    for tok in tokens:
        p = Path(tok)
        # 絶対パスならそのまま
        if p.is_absolute() and p.exists():
            outs.append(p.resolve())
            continue
        # 相対なら srs/ 配下を見る（ワイルドカードも許容）
        if any(ch in tok for ch in "*/?[]"):
            outs.extend((SRS_DIR).glob(tok))
        else:
            cand = (SRS_DIR / tok)
            if cand.exists():
                outs.append(cand.resolve())
    if not outs:
        raise FileNotFoundError(f"SRS not found for CLI args: {tokens}")
    # 重複除去して並べる
    return sorted({p for p in outs})

# =============================
# スキーマ一元定義
#  - Responses: response_format.json_schema に丸ごと渡す
#  - Chat: tools.function.parameters に丸ごと渡す
# =============================

def build_review_json_schema_core() -> Dict[str, Any]:
    """
    出力JSONの“唯一の真実”。
    - { 全体: overall, 各レビュー: review_items[] } の２層構造
    - 各レビューは { line, axis[], comment } を必須
    """
    return {
        "type": "object",
        "additionalProperties": False,
        "properties": {
            "overall": {
                "type": "string",
                "maxLength": 800,
                "description": "SRS全体に対する総評。忖度なしでポジティブ・ネガティブ両方に触れる。"
            },
            "review_items": {
                "type": "array",
                "minItems": 1,
                "maxItems": 50,
                "items": {
                    "type": "object",
                    "additionalProperties": False,
                    "properties": {
                        "line": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 300,
                            "description": "SRS内のレビュー対象箇所の“実際の文章”を記号なども含めて抜粋して記述。見出しだけや要約は禁止。"
                        },
                        "axis": {
                            "type": "array",
                            "minItems": 1,
                            "uniqueItems": True,
                            "items": {
                                "type": "string",
                                "enum": ["C", "R", "A", "F", "T", "N"]
                            },
                            "description": "評価軸ID（C,R,A,F,T,N）を1つ以上。"
                        },
                        "comment": {
                            "type": "string",
                            "minLength": 40,
                            "maxLength": 400,
                            "description": "対象箇所へのレビュー。必ず『問題点・その理由・実現可能な改善案』の3点を含め優しい言葉で理解しやすく。"
                        }
                    },
                    "required": ["line", "axis", "comment"]
                }
            }
        },
        "required": ["overall", "review_items"]
    }


def build_responses_json_schema() -> Dict[str, Any]:
    """
    Responses API の Structured Outputs で使うラッパ。
    """
    return {
        "type": "json_schema",
        "json_schema": {
            "name": "review_response",
            "schema": build_review_json_schema_core(),
        },
    }

def build_tools_for_chat() -> List[Dict[str, Any]]:
    """
    Chat Completions で Function Calling を使うための tools 定義。
    - “emit_review” 関数の parameters に JSON スキーマを埋め込む
    - tool_choice でこの関数を強制すれば、arguments が必ずスキーマ準拠になる
    """
    return [
        {
            "type": "function",
            "function": {
                "name": "emit_review",
                "description": "Return the review in the required JSON schema.",
                "parameters": build_review_json_schema_core(),  # ← 同じコアスキーマを共有
            },
        }
    ]

def build_tools_for_responses() -> List[Dict[str, Any]]:
    """
    Responses API 用の tools（Function Calling）。
    Chat と違い、function.name はトップレベル 'name' に置く必要がある。
    """
    return [
        {
            "type": "function",
            "name": "emit_review",                        # ← トップレベルの name
            "description": "Return the review in the required JSON schema.",
            "parameters": build_review_json_schema_core()  # ← コアスキーマを共有
        }
    ]

# ========== Gemini用：JSONスキーマ変換 ==========
def to_gemini_schema(schema_core: dict) -> dict:
    """
    あなたの “唯一の真実” スキーマ（JSON Schema風）を
    Geminiの response_schema（OpenAPI 3.0 subset）に素直に落とす。
    - ここではシンプルな object/array/string/number/boolean の範囲に限定
    - enum があればそのまま通す
    - propertyOrdering は使わない（必要なら後で追加可）
    """
    def convert(node):
        if not isinstance(node, dict):
            return node
        t = node.get("type")
        out = {}
        if t == "object":
            out["type"] = "OBJECT"
            props = node.get("properties", {})
            out["properties"] = {k: convert(v) for k, v in props.items()}
            if "required" in node:
                out["required"] = list(node["required"])
        elif t == "array":
            out["type"] = "ARRAY"
            out["items"] = convert(node.get("items", {}))
        elif t == "string":
            out["type"] = "STRING"
            if "enum" in node:
                out["enum"] = list(node["enum"])
        elif t == "number":
            out["type"] = "NUMBER"
        elif t == "integer":
            out["type"] = "INTEGER"
        elif t == "boolean":
            out["type"] = "BOOLEAN"
        else:
            # fallback: string 扱い
            out["type"] = "STRING"
        return out

    return convert(schema_core)

# ========== Gemini用：レビュー実行 ==========
def run_single_gemini(
    model: str,
    system_text: str,         # あなたの system_v4.0 と rubric を結合したもの
    srs_text: str,            # SRS本文
    schema_core: dict,        # あなたの唯一スキーマ（build_review_json_schema_core()の戻り値）
    out_path: Path,
    max_output_tokens: int = 8192,
) -> None:
    """
    Geminiの Structured Output を使って、
    OpenAI 側と同じJSON形（overall + review_items[]）を返す。
    """
    client = genai.Client()  # GOOGLE_API_KEY / GEMINI_API_KEY を自動検出 :contentReference[oaicite:8]{index=8}

    # 1) response_schema: OpenAPI subset dict に変換（SDKは dict/Schema/Pydantic を許容） :contentReference[oaicite:9]{index=9}
    gem_schema = to_gemini_schema(schema_core)

    # 2) system instruction と generation config
    #    → v4.0の「教育的方針」だけをここに。JSON形は schema で強制する（重複記述を避ける） :contentReference[oaicite:10]{index=10}
    gen_config = gtypes.GenerateContentConfig(
        system_instruction=system_text,
        response_mime_type="application/json",
        response_schema=gem_schema,
        # safety_settings, temperature 等は必要に応じて
        # max_output_tokens は SDK 側で gtypes を使う場合、現行は generationConfig に含めず運用することが多い。
        # 長大SRSで切れる場合はチャンク分割を推奨（OpenAI側と同じ方針）。
    )

    # 3) contents は「SRS本文のみ」をユーザ入力として渡す
    contents = srs_text

    # 4) 生成
    resp = client.models.generate_content(
        model=model,               # 例: "gemini-2.5-flash" / "gemini-2.5-pro"
        contents=contents,
        config=gen_config,
    )

    # 5) 取り出し
    #   - response.text はJSON文字列
    #   - response.parsed は 型指定時（Pydantic/typing）の構造体。今回は dict schema なので text を使うのが確実。 :contentReference[oaicite:11]{index=11}
    text = (resp.text or "").strip()

    # 念のためJSONとして妥当か軽く確認してから保存
    try:
        import json
        data = json.loads(text) if text else {}
    except Exception:
        data = {}
    out_path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
# =============================
# ユーティリティ
# =============================

def log(msg: str) -> None:
    """簡易ロガー。標準出力にログを即時フラッシュする（開発時の追跡用）。"""
    print(f"[review_runner] {msg}", flush=True)

def ensure_exists(path: Path) -> None:
    """ファイル/ディレクトリの存在を確認し、無ければ FileNotFoundError を送出する。"""
    if not path.exists():
        raise FileNotFoundError(str(path))

def load_text(path: Path) -> str:
    """テキストファイルを UTF-8 で読み込んで返す。"""
    ensure_exists(path)
    return path.read_text(encoding="utf-8")

def resolve_srs_targets(patterns: List[str]) -> List[Path]:
    """SRS パターン（glob）から対象 Markdown を解決して返す。見つからなければ例外。"""
    if not patterns:
        return sorted(SRS_DIR.glob("*.md"))
    out: list[Path] = []
    for pat in patterns:
        out.extend(SRS_DIR.glob(pat))
    if not out:
        raise FileNotFoundError(f"SRS not found for: {patterns}")
    return sorted({p.resolve() for p in out})

def build_system_prompt_plain(system_text: str, rubric_md: str) -> str:
    """
    スキーマは書かない。教育的指示＋評価観点だけを残す。
    最後に“説明や前置きは出力しない”ことを添えておく。
    """
    return (
        system_text.rstrip()
        + "\n\n### Rubric\n"
        + rubric_md.strip()
        + "\n\n（注）出力形式はシステム側で制御されます。説明文や前置きは一切出力せず、要求された構造データのみ返してください。\n"
    )

def _responses_extract_tool_args(resp: Any) -> str:
    """
    Responses の output から emit_review の arguments(JSON文字列)を抽出。
    カバーするパターン：
      1) item.type が "function_call" / "tool_call" / "tool" の直下に name/arguments がある
      2) item.type == "message" の content[] の中に function_call / tool_call / tool がいる
    見つからなければ空文字を返す。
    """
    output = getattr(resp, "output", []) or []

    def _pick_args(obj) -> str:
        if not obj:
            return ""
        # dict / pydantic 両対応
        get = (lambda k: (getattr(obj, k, None) if not isinstance(obj, dict) else obj.get(k)))
        typ = get("type")
        name = get("name")
        if typ in ("function_call", "tool_call", "tool") and name == "emit_review":
            args = get("arguments")
            if isinstance(args, str) and args.strip():
                return args.strip()
        return ""

    # 1) 直下に function_call / tool_call / tool
    for item in output:
        args = _pick_args(item)
        if args:
            return args

    # 2) message.content[] 内に function_call 等
    for item in output:
        # dict / pydantic 両対応で type 取得
        item_type = getattr(item, "type", None) if not isinstance(item, dict) else item.get("type")
        if item_type == "message":
            contents = getattr(item, "content", None) if not isinstance(item, dict) else item.get("content")
            contents = contents or []
            for c in contents:
                args = _pick_args(c)
                if args:
                    return args

    return ""


def _debug_dump_responses_output(resp: Any) -> None:
    """
    Responses の output 構造をざっと可視化（型/名前/arguments長さ）。
    想定外の形でも壊れないように try/except で守る。
    """
    try:
        output = getattr(resp, "output", []) or []
        print("[debug/resp] output len:", len(output))
        for i, item in enumerate(output):
            try:
                t = getattr(item, "type", None) or (isinstance(item, dict) and item.get("type"))
                nm = getattr(item, "name", None) or (isinstance(item, dict) and item.get("name"))
                # arguments の長さだけ見る（全文は出さない）
                args = getattr(item, "arguments", None) or (isinstance(item, dict) and item.get("arguments"))
                alen = len(args) if isinstance(args, str) else None
                print(f"[debug/resp]  [{i}] type={t} name={nm} args.len={alen}")
                # message 型なら content 側も軽く覗く
                if t == "message":
                    contents = getattr(item, "content", []) or (isinstance(item, dict) and item.get("content", [])) or []
                    print(f"[debug/resp]    message.content len={len(contents)}")
                    for j, c in enumerate(contents[:5]):  # 最初の数件だけ
                        ct = getattr(c, "type", None) or (isinstance(c, dict) and c.get("type"))
                        print(f"[debug/resp]      content[{j}].type={ct}")
            except Exception as e:
                print(f"[debug/resp]  [{i}] dump error:", e)
    except Exception as e:
        print("[debug/resp] dump error:", e)

# =============================
# API 呼び出し
# =============================

def call_chat_with_function_calling(
    client: OpenAI,
    model: str,
    system_prompt: str,
    srs_text: str,
) -> Tuple[Dict[str, Any], str]:
    """
    Chat Completions（非 gpt-5）の経路。
    - tools（Function Calling）で JSON スキーマを強制
    - tool_choice で "emit_review" を必ず呼ぶよう指定
    - 返却は tool_calls[0].function.arguments（JSON文字列）をそのまま本文として扱う
    """
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user",   "content": srs_text},
    ]

    kwargs: Dict[str, Any] = {
        "model": model,
        "messages": messages,
        "tools": build_tools_for_chat(),
        "tool_choice": {"type": "function", "function": {"name": "emit_review"}},  # ← 強制
        "max_tokens": CHAT_MAX_TOKENS,
    }
    if CHAT_TEMPERATURE is not None:
        kwargs["temperature"] = CHAT_TEMPERATURE

    resp = client.chat.completions.create(**kwargs)
    d = resp.to_dict()

    # 返却の取り出し：forced tool call の第一件
    tool_calls = d.get("choices", [{}])[0].get("message", {}).get("tool_calls", [])
    if not tool_calls:
        # 念のため通常の content も確認（起きない想定）
        content = d.get("choices", [{}])[0].get("message", {}).get("content") or ""
        return d, (content.strip() if content else "")

    args_text = tool_calls[0].get("function", {}).get("arguments", "")  # ← JSON文字列
    return d, args_text.strip()


def call_gpt5_responses(
    client: OpenAI,
    model: str,
    system_prompt: str,
    srs_text: str,
    max_output_tokens: int,
    reasoning_effort: str,
    allow_retry: bool,
    retry_factor: float,
) -> Tuple[Dict[str, Any], str]:
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user",   "content": srs_text},
    ]
    tools = build_tools_for_responses()            # ← Responses 版を使用
    tool_choice = RESPONSES_TOOL_CHOICE            # ← Responses 版を使用

    def _once(limit_tokens: int) -> Tuple[Dict[str, Any], str]:
        # 1) API 呼び出し
        resp = client.responses.create(
            model=model,
            input=messages,
            tools=tools,                           # ← ここで tools 指定
            tool_choice=tool_choice,               # ← emit_review を強制
            reasoning={"effort": reasoning_effort},
            max_output_tokens=limit_tokens,
        )

        # 2) ★ usage ログ（API呼び出し直後に記録）
        u = getattr(resp, "usage", None)
        if u:
            prompt     = getattr(u, "prompt_tokens",     0) or 0
            completion = getattr(u, "completion_tokens", 0) or 0
            reasoning  = getattr(u, "reasoning_tokens",  0) or 0
            total      = getattr(u, "total_tokens",      0) or 0
            print(f"[debug/resp-usage] model={model} effort={reasoning_effort} "
                  f"limit={limit_tokens} prompt={prompt} completion={completion} "
                  f"reasoning={reasoning} total={total}")
        else:
            print(f"[debug/resp-usage] model={model} effort={reasoning_effort} "
                  f"limit={limit_tokens} usage=<none>")

        # 3) 出力構造のダンプ（ブロックの種類や function_call の有無を確認）
        _debug_dump_responses_output(resp)

        # 4) emit_review の JSON を最優先で回収
        json_text = _responses_extract_tool_args(resp)

        # 5) 見つからない場合の保険として output_text をチェック
        if not json_text:
            json_text = (getattr(resp, "output_text", "") or "").strip()

        # 6) 返却用の dict 化（ログ保存などに使う）
        try:
            d = resp.to_dict()
        except Exception:
            d = json.loads(resp.model_dump_json()) if hasattr(resp, "model_dump_json") else {"raw": str(resp)}
        return d, json_text

    # 初回実行
    d, text = _once(max_output_tokens)
    if text or not allow_retry:
        return d, text

    # 再試行（出力が空のときのみ）
    new_limit = int(max_output_tokens * retry_factor)
    log(f"[retry/resp] output empty → raising max_output_tokens {max_output_tokens} → {new_limit}")
    return _once(new_limit)


def send_request(
    client: OpenAI,
    model: str,
    system_prompt: str,
    srs_text: str,
) -> Tuple[Dict[str, Any], str]:
    """モデル種別に応じて Responses/Chat 経路を選択し、スキーマ準拠のJSON文字列を回収する。"""
    if model in GPT5_MODELS:
        log(f"  [api] Responses (gpt-5) max_output_tokens={GPT5_MAX_OUTPUT_TOKENS}, effort='{GPT5_REASONING_EFFORT}'")
        return call_gpt5_responses(
            client=client,
            model=model,
            system_prompt=system_prompt,
            srs_text=srs_text,
            max_output_tokens=GPT5_MAX_OUTPUT_TOKENS,
            reasoning_effort=GPT5_REASONING_EFFORT,
            allow_retry=GPT5_EMPTY_RETRY,
            retry_factor=GPT5_RETRY_FACTOR,
        )
    else:
        log(f"  [api] Chat (Function Calling) max_tokens={CHAT_MAX_TOKENS}")
        return call_chat_with_function_calling(
            client=client,
            model=model,
            system_prompt=system_prompt,
            srs_text=srs_text,
        )


# =============================
# メイン処理
# =============================

def run(models: List[str], srs_paths: List[Path], system_file: Path, rubric_file: Path) -> None:
    """エントリポイント。環境/プロンプトを読み込み、対象SRS×モデルでレビューを実行・保存する。"""
    load_dotenv()
    client = OpenAI()
    OUT_DIR.mkdir(exist_ok=True)

    log(f"Project root       : {ROOT}")
    log(f"System file        : {system_file}")
    log(f"Rubric file        : {rubric_file}")

    system_text = load_text(system_file)
    rubric_md   = load_text(rubric_file)
    system_prompt = build_system_prompt_plain(system_text, rubric_md)
    log("System prompt ready (system + rubric concatenated).")

    log(f"SRS files          : {len(srs_paths)} target(s)")
    log(f"Models             : {', '.join(models)}")

    for srs_path in srs_paths:
        srs_text = load_text(srs_path)
        log(f"▶ SRS: {srs_path.name}")

        for model in models:
            log(f"  - model: {model}")
            try:
                # 既存のループ内で model ごとに
                if model.startswith("gemini-"):
                    # 共通スキーマを再利用
                    schema_core = build_review_json_schema_core()  # あなたの既存関数
                    # 例: 出力先
                    stem_for_output = _strip_ci_prefix(Path(srs_path).stem)   # ← ここがポイント
                    out_path = OUT_DIR / f"{stem_for_output}__{model}.json"
                    print(f"[review_runner]   [api] Gemini Structured Output: {model}")
                    run_single_gemini(
                        model=model,
                        system_text=system_prompt,  # 既存の system_v4.0 + rubric 結合文字列
                        srs_text=srs_text,
                        schema_core=schema_core,
                        out_path=out_path,
                    )
                else:
                    # 既存のOpenAIルート（Responses / Chat）へ
                    resp_dict, content = send_request(
                        client=client,
                        model=model,
                        system_prompt=system_prompt,
                        srs_text=srs_text,
                    )

                    # 返却は JSON 文字列の想定（どちらの経路でもスキーマ準拠）
                    if content:
                        try:
                            parsed = json.loads(content)
                            out_text = json.dumps(parsed, ensure_ascii=False, indent=2)
                        except json.JSONDecodeError:
                            # 想定外（ほぼ起きない設計）でも raw を保存
                            out_text = content
                    else:
                        out_text = ""

                    stem_for_output = _strip_ci_prefix(Path(srs_path).stem)   # ← ここがポイント
                    out_path = OUT_DIR / f"{stem_for_output}__{model}.json"
                    print("[debug] saving file with content_length:", len(out_text))
                    out_path.write_text(out_text, encoding="utf-8")
                    log(f"    ✔ saved: {out_path}")

            except Exception as e:
                log(f"    ✖ error: {e}")

    log("All done.")


if __name__ == "__main__":
    args = parse_args()

    # モデルは --models があれば上書き、なければ既定 MODELS
    models = [m.strip() for m in args.models.split(",")] if getattr(args, "models", None) else MODELS

    # 対象SRSは --srs 優先。なければ従来の SRS_PATTERNS を使う。
    if getattr(args, "srs", None):
        srs_targets = resolve_srs_targets_from_cli(args.srs)
    else:
        srs_targets = resolve_srs_targets(SRS_PATTERNS)

    run(
        models=models,
        srs_paths=srs_targets,
        system_file=SYSTEM_FILE,
        rubric_file=RUBRIC_FILE,
    )
