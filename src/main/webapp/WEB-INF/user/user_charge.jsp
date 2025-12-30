<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>チャージ</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            display: flex;
            justify-content: center;
        }
        .container {
            width: 100%;
            max-width: 420px;
            background: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            border-left: 1px solid #eee;
            border-right: 1px solid #eee;
        }
        
        /* ヘッダー */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            border-bottom: 3px solid #ddd;
        }
        .header-title { font-weight: bold; font-size: 16px; }
        .blue-bar { background-color: #00A0E9; color: white; text-align: center; padding: 5px; font-size: 12px; font-weight: bold; }

        /* コンテンツ */
        .content { padding: 20px; }

        /* 残高カード */
        .balance-card {
            background-color: #FF6900;
            color: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .balance-label { font-size: 14px; margin-bottom: 5px; }
        .balance-amount { font-size: 36px; font-weight: bold; letter-spacing: -1px; }

        /* 入力エリア */
        .label { font-weight: bold; margin-bottom: 10px; display: block; font-size: 14px; }
        .input-box {
            width: 100%;
            padding: 15px;
            font-size: 24px;
            font-weight: bold;
            border: 2px solid #ccc;
            border-radius: 12px;
            text-align: right;
            box-sizing: border-box;
            margin-bottom: 15px;
        }

        /* クイックボタン */
        .quick-buttons {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
        }
        .q-btn {
            flex: 1;
            padding: 10px 0;
            background-color: #ddd;
            border: none;
            border-radius: 20px;
            font-weight: bold;
            font-size: 12px;
            cursor: pointer;
            text-align: center;
        }
        .q-btn.selected {
            background-color: #ffcccc; /* 薄い赤 */
            color: #d00;
            border: 2px solid #f00;
        }

        /* チャージ方法 */
        .method-box {
            border: 2px solid #FF0000;
            background-color: #FFEEEE;
            border-radius: 12px;
            padding: 15px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 40px;
        }
        .card-icon { font-size: 24px; margin-right: 10px; }
        .card-info { flex: 1; font-weight: bold; font-size: 14px; }
        .card-sub { font-size: 12px; color: #666; display: block;}
        .check-circle {
            width: 20px; height: 20px;
            border-radius: 50%;
            border: 3px solid #FF0000;
        }

        /* チャージボタン */
        .charge-btn {
            width: 100%;
            padding: 18px;
            background-color: #FF0000;
            color: white;
            border: none;
            border-radius: 30px;
            font-size: 20px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 4px 6px rgba(255, 0, 0, 0.3);
        }
        
        .error-msg { color: red; font-weight: bold; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <!-- 青いバー (エラー等表示用エリア) -->
        <div class="blue-bar">チャージ画面</div>

        <!-- ヘッダー -->
        <div class="header">
            <a href="${pageContext.request.contextPath}/user_home" style="text-decoration:none; color:#333;">
                <div style="font-size:20px;">🏠</div>
                <div style="font-size:10px;">ホーム</div>
            </a>
            <div class="header-title">🐄 焼肉〇〇</div>
            <a href="${pageContext.request.contextPath}/user_signin" style="text-decoration:none; color:#333;">
                <div style="font-size:20px;">🚪</div>
                <div style="font-size:10px;">ログアウト</div>
            </a>
        </div>

        <div class="content">
            <!-- 残高表示 -->
            <div class="balance-card">
                <div class="balance-label">残高</div>
                <div class="balance-amount">¥<fmt:formatNumber value="${user.balance}" /></div>
            </div>

            <!-- エラーメッセージ -->
            <c:if test="${not empty error}">
                <div class="error-msg">${error}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/UserCharge" method="post">
                <!-- チャージ金額入力 -->
                <label class="label">チャージ金額</label>
                <input type="number" id="chargeInput" name="amount" class="input-box" value="5000" placeholder="¥ 0">

                <!-- クイックボタン -->
                <div class="quick-buttons">
                    <button type="button" class="q-btn" onclick="addAmount(1000)">+¥1,000</button>
                    <button type="button" class="q-btn selected" onclick="setAmount(5000)">+¥5,000</button>
                    <button type="button" class="q-btn" onclick="addAmount(10000)">+¥10,000</button>
                </div>

                <!-- チャージ方法 (固定) -->
                <label class="label">チャージ方法</label>
                <div class="method-box">
                    <div class="card-icon">💳</div>
                    <div class="card-info">
                        クレジットカード
                        <span class="card-sub">VISA ****5678</span>
                    </div>
                    <div class="check-circle"></div>
                </div>

                <!-- ボタン -->
                <button type="submit" class="charge-btn">チャージ</button>
            </form>
        </div>
    </div>

    <script>
        const input = document.getElementById('chargeInput');

        // 金額を加算する関数
        function addAmount(val) {
            let current = parseInt(input.value) || 0;
            input.value = current + val;
            updateBtnStyle();
        }

        // 金額をセットする関数 (真ん中の+5000ボタン用)
        function setAmount(val) {
            input.value = val;
            updateBtnStyle();
        }

        // ボタンのスタイル更新（今回は簡易実装）
        function updateBtnStyle() {
            // 必要に応じてボタンの色を変える処理など
        }
    </script>
</body>
</html>