<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${empty sessionScope.tableNumber}">
    <c:redirect url="/Order" />
</c:if>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注文端末：人数</title>
    <style>
        /* =========================================
           基本スタイル (PC向けにサイズアップ)
           ========================================= */
        body {
            font-family: "Yu Gothic", "YuGothic", "Hiragino Kaku Gothic ProN", "Meiryo", sans-serif;
            margin: 0;
            padding: 0;
            background-color: #ffffff;
            color: #000000;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center; /* 画面中央に配置 */
            min-height: 100vh;
        }

        .container {
            width: 100%;
            max-width: 900px; /* ★幅を大きくしました */
            padding: 40px;
            box-sizing: border-box;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* =========================================
           ロゴ・タイトルエリア
           ========================================= */
        .header-logo {
            margin-bottom: 40px;
        }
        
        /* ロゴ画像のサイズ調整 */
        .header-logo img {
            height: 60px; /* ★ロゴも少し大きく */
            width: auto;
            display: block;
        }

        h2 {
            font-size: 36px; /* ★文字サイズアップ */
            font-weight: 700;
            margin: 0 0 50px 0;
            letter-spacing: 0.05em;
        }

        /* =========================================
           入力パネル（グレー背景）
           ========================================= */
        .selection-panel {
            background-color: #F2F2F2;
            border-radius: 20px; /* 角丸を少し大きく */
            padding: 50px 60px; /* ★内側の余白をたっぷりと */
            width: 100%;
            box-sizing: border-box;
            margin-bottom: 60px;
        }

        .row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 50px; /* 行間を広げる */
        }

        .row:last-child {
            margin-bottom: 0;
        }

        /* アイコンとラベル */
        .info-group {
            display: flex;
            align-items: center;
            gap: 30px; /* アイコンと文字の間隔を広げる */
            text-align: left;
            margin-right: 30px;
        }

        /* 人物アイコン画像のサイズ */
        .person-icon-img {
            width: 60px;  /* ★アイコンサイズアップ */
            height: auto;
            display: block;
        }
        
        .child-icon-img {
            width: 60px;  /* ★アイコンサイズアップ */
            height: auto;
            display: block;
        }

        .label-container {
            display: flex;
            flex-direction: column;
        }

        .label-main {
            font-size: 28px; /* ★文字サイズアップ */
            font-weight: 700;
        }

        .label-sub {
            font-size: 20px; /* ★文字サイズアップ */
            font-weight: 700;
            margin-top: 5px;
            color: #555;
        }

        /* =========================================
           カウンターボタン（＋・−）
           ========================================= */
        .counter-group {
            display: flex;
            align-items: center;
            gap: 30px; /* ボタンと数値の間隔を広げる */
            margin-left: 30px;
        }

        /* ボタン枠 */
        .btn-img-wrapper {
            background: none;
            border: none;
            padding: 0;
            cursor: pointer;
            width: 50px; /* ★ボタンを大きく (64px) */
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: opacity 0.2s;
        }

        /* ボタン内の画像サイズ */
        .btn-img-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        .btn-img-wrapper:active {
            opacity: 0.7;
        }

        /* 無効化（限度到達）時のスタイル */
        .btn-disabled {
            cursor: default;
            pointer-events: none;
            opacity: 0.3;
            filter: grayscale(100%);
        }

        /* 数値表示 */
        .count-display {
            font-size: 40px; /* ★数字をかなり大きく */
            font-weight: 700;
            width: 120px; /* 幅を確保 */
            text-align: center;
            font-variant-numeric: tabular-nums;
        }

        /* =========================================
           決定ボタン
           ========================================= */
        .submit-btn {
            background-color: #FF6900;
            color: white;
            font-size: 32px; /* ★ボタン文字サイズアップ */
            font-weight: 700;
            border: none;
            padding: 20px 0; /* 高さを出す */
            width: 350px;   /* 幅を広げる */
            border-radius: 60px;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            transition: background-color 0.2s, transform 0.1s;
        }

        .submit-btn:hover {
            background-color: #e65e00;
        }
        
        .submit-btn:active {
            transform: translateY(2px);
        }
    </style>
</head>
<body>

<div class="container">
    
    <!-- ロゴ画像 -->
    <div class="header-logo">
        <!-- ▼ ロゴ画像のURLを指定してください ▼ -->
        <img src="image/logo/logo.svg" alt="ロゴ">
    </div>

    <h2>人数を選択してください</h2>
    
    <form action="CustomerCount" method="post">
        
        <div class="selection-panel">
            
            <!-- 大人 -->
            <div class="row">
                <div class="info-group">
                    <!-- 大人アイコン画像 -->
                    <img src="image/system/大人.svg" class="person-icon-img" alt="大人">
                    
                    <div class="label-container">
                        <span class="label-main">大人</span>
                    </div>
                </div>
                
                <div class="counter-group">
                    <!-- マイナスボタン画像 -->
                    <button type="button" id="btn-adult-minus" class="btn-img-wrapper" onclick="updateCount('adult', -1)">
                        <img src="image/system/マイナス.svg" alt="減らす">
                    </button>
                    
                    <span id="adult-display" class="count-display">1人</span>
                    <input type="hidden" id="adult-input" name="adult" value="1">
                    
                    <!-- プラスボタン画像 -->
                    <button type="button" id="btn-adult-plus" class="btn-img-wrapper" onclick="updateCount('adult', 1)">
                        <img src="image/system/プラス.svg" alt="増やす">
                    </button>
                </div>
            </div>

            <!-- 子ども -->
            <div class="row">
                <div class="info-group">
                    <!-- 子どもアイコン画像 -->
                    <img src="image/system/子供.svg" class="child-icon-img" alt="子ども">
                    
                    <div class="label-container">
                        <span class="label-main">子ども</span>
                        <span class="label-sub">（〜12歳）</span>
                    </div>
                </div>
                
                <div class="counter-group">
                    <!-- マイナスボタン画像 -->
                    <button type="button" id="btn-child-minus" class="btn-img-wrapper" onclick="updateCount('child', -1)">
                        <img src="image/system/マイナス.svg" alt="減らす">
                    </button>
                    
                    <span id="child-display" class="count-display">0人</span>
                    <input type="hidden" id="child-input" name="child" value="0">
                    
                    <!-- プラスボタン画像 -->
                    <button type="button" id="btn-child-plus" class="btn-img-wrapper" onclick="updateCount('child', 1)">
                        <img src="image/system/プラス.svg" alt="増やす">
                    </button>
                </div>
            </div>

        </div>

        <button type="submit" class="submit-btn">決定</button>
    </form>
</div>

<script>
    <script>
    // 最小値・最大値の設定
    const limits = {
        adult: { min: 1, max: 8 },
        child: { min: 0, max: 7 }
    };
    
    // ★追加: 合計人数の上限
    const TOTAL_MAX = 8;

    // 初期ロード時にボタンの状態をチェック
    window.addEventListener('DOMContentLoaded', () => {
        updateAllButtons();
    });

    // ★追加: 現在の合計人数を取得する関数
    function getTotalCount() {
        const adult = parseInt(document.getElementById('adult-input').value) || 0;
        const child = parseInt(document.getElementById('child-input').value) || 0;
        return adult + child;
    }

    function updateCount(type, delta) {
        const input = document.getElementById(type + '-input');
        const display = document.getElementById(type + '-display');
        
        let currentValue = parseInt(input.value);
        let newValue = currentValue + delta;
        let currentTotal = getTotalCount();

        // ★追加: 増やす場合、合計が8人を超えるなら何もしない
        if (delta > 0 && currentTotal >= TOTAL_MAX) {
            return;
        }

        // 範囲チェック (個別の最小・最大チェック)
        if (newValue >= limits[type].min && newValue <= limits[type].max) {
            input.value = newValue;
            display.textContent = newValue + '人';
            
            // ★変更: 両方のボタンの状態を更新する
            // (合計人数が変わると、もう片方のボタンの押下可否も変わるため)
            updateAllButtons();
        }
    }

    // ★追加: 両方のカテゴリのボタン状態を更新するラッパー関数
    function updateAllButtons() {
        checkButtonState('adult');
        checkButtonState('child');
    }

    // ボタンの有効/無効化（グレーアウト）処理
    function checkButtonState(type) {
        const input = document.getElementById(type + '-input');
        const currentValue = parseInt(input.value);
        const limit = limits[type];
        const currentTotal = getTotalCount(); // 現在の合計を取得

        const minusBtn = document.getElementById('btn-' + type + '-minus');
        const plusBtn = document.getElementById('btn-' + type + '-plus');

        // マイナスボタンの制御（下限チェック）
        if (currentValue <= limit.min) {
            minusBtn.classList.add('btn-disabled');
        } else {
            minusBtn.classList.remove('btn-disabled');
        }

        // プラスボタンの制御
        // ★変更: 「個別の最大値に達している」または「合計が8人に達している」場合は無効化
        if (currentValue >= limit.max || currentTotal >= TOTAL_MAX) {
            plusBtn.classList.add('btn-disabled');
        } else {
            plusBtn.classList.remove('btn-disabled');
        }
    }
</script>

</body>
</html>