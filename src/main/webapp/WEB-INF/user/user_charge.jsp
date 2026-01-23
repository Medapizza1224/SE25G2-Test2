<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="util.AppConfig" %>
<%
    AppConfig conf = AppConfig.load(application);
    request.setAttribute("conf", conf);
%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/User" />
</c:if>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title>チャージ</title>
    <script>
        window.addEventListener('pageshow', function(event) {
            if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
                window.location.reload();
            }
        });
    </script>
    <style>
        :root {
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        body {
            font-family: "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
            background-color: #F8F7F5; /* 元の背景色に戻す */
            margin: 0;
            display: flex;
            justify-content: center;
            color: #333;
            
            /* ノッチ対応 + 余白追加 */
            padding-top: calc(env(safe-area-inset-top) + 20px);
            padding-bottom: env(safe-area-inset-bottom);
            padding-left: env(safe-area-inset-left);
            padding-right: env(safe-area-inset-right);
        }
        .container {
            width: 100%;
            max-width: 420px;
            background: transparent; /* コンテナ自体は透明 */
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        
        /* ヘッダー */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            background: white;
            border-bottom: 1px solid #eee;
            height: 60px;
            box-sizing: border-box;
        }
        .header-logo {
            height: 28px;
            width: auto;
            object-fit: contain;
        }

        .icon-btn { 
            text-decoration: none; 
            color: #333; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            width: 40px; 
            height: 40px;
        }
        .icon-img {
            width: 24px;
            height: 24px;
            object-fit: contain;
        }
        
        /* 戻る用 */
        .back-text {
            font-size: 14px;
            font-weight: bold;
            color: #333;
            text-decoration: none;
            display: flex;
            align-items: center;
        }

        /* コンテンツエリア (白い角丸カード) */
        .content { 
            background: white; 
            margin: 15px 15px 30px 15px; 
            padding: 30px 25px;
            border-radius: 24px; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); 
            flex: 1;
        }

        /* 以下、チャージ画面固有のデザイン */
        .balance-card {
            background-color: var(--main-color);
            color: white;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            position: relative;
        }
        .balance-label { font-size: 13px; margin-bottom: 8px; opacity: 0.9; }
        .balance-amount { font-size: 32px; font-weight: bold; letter-spacing: 0.5px; font-family: Arial, sans-serif; }

        .label { font-weight: bold; margin-bottom: 12px; display: block; font-size: 15px; color: #333; }
        .input-box {
            width: 100%; padding: 12px; font-size: 28px; font-weight: bold;
            border: none; border-bottom: 1px solid #ddd; border-radius: 0;
            text-align: right; box-sizing: border-box; margin-bottom: 25px;
            background: transparent; font-family: Arial, sans-serif; color: #333;
        }
        .input-box:focus { outline: none; border-bottom: 2px solid var(--main-color); }

        .quick-buttons { display: flex; gap: 12px; margin-bottom: 40px; }
        .q-btn {
            flex: 1; padding: 14px 0; background-color: #F5F5F5;
            border: 1px solid #F5F5F5; color: #999; border-radius: 8px;
            font-weight: bold; font-size: 14px; cursor: pointer; text-align: center; transition: all 0.2s;
        }
        .q-btn.selected {
            background-color: #FFF5F5;
            color: var(--main-color);
            border: 2px solid var(--main-color);
            position: relative;
        }

        .method-box {
            border: 2px solid var(--main-color);
            background-color: #FFF5F5;
            border-radius: 12px; padding: 18px;
            display: flex; align-items: center; justify-content: space-between; margin-bottom: 50px;
        }
        .card-icon { font-size: 24px; margin-right: 15px; }
        .card-info { flex: 1; font-weight: bold; font-size: 15px; color: #333; }
        .card-sub { font-size: 12px; color: #666; display: block; margin-top: 2px; }
        .check-circle {
            width: 22px; height: 22px; border-radius: 50%;
            background-color: var(--main-color);
            position: relative;
        }

        .refresh-btn {
            position: absolute; top: 20px; right: 20px; background: transparent;
            border: none; color: white; font-size: 24px; font-weight: bold; opacity: 0.8;
            cursor: pointer; padding: 0; line-height: 1; transition: transform 0.3s; z-index: 10;
        }
        .refresh-btn:active { transform: rotate(360deg); opacity: 1; }

        .charge-btn {
            width: 100%; padding: 20px;
            background-color: var(--main-color);
            color: white; border: none; border-radius: 35px;
            font-size: 18px; font-weight: bold; cursor: pointer;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
            transition: opacity 0.2s;
        }
        .charge-btn:active { opacity: 0.8; }
        
        .error-msg { color: #FF0000; font-weight: bold; margin-bottom: 20px; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <!-- ヘッダー (ホーム画面と共通レイアウト) -->
        <div class="header">
            <!-- 左側ボタン -->
            <c:choose>
                <c:when test="${param.returnTo == 'payment'}">
                    <a href="${pageContext.request.contextPath}/UserPayment?orderId=${param.orderId}" class="back-text">
                        <span style="font-size:20px; margin-right:5px;">‹</span> 戻る
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/user_home" class="icon-btn">
                        <img src="${pageContext.request.contextPath}/image/system/ホーム.svg" class="icon-img" alt="ホーム">
                    </a>
                </c:otherwise>
            </c:choose>
            
            <!-- 中央ロゴ -->
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="焼肉〇〇" class="header-logo">
            
            <!-- 右側スペース調整 (ホームのログアウトボタン分のスペースを空けるか、空divを置く) -->
            <div style="width: 40px;"></div>
        </div>

        <div class="content">
            <div class="balance-card">
                <div class="balance-label">残高</div>
                <div class="balance-amount">¥ <fmt:formatNumber value="${user.balance}" /></div>
                <button type="button" class="refresh-btn" onclick="location.reload()" title="残高を更新">↻</button>
            </div>

            <c:if test="${not empty error}">
                <div class="error-msg">${error}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/UserCharge" method="post">
                <input type="hidden" name="returnTo" value="${param.returnTo}">
                <input type="hidden" name="orderId" value="${param.orderId}">
                <label class="label">チャージ金額</label>
                <input type="number" id="chargeInput" name="amount" class="input-box" value="5000" placeholder="¥ 0">

                <div class="quick-buttons">
                    <button type="button" class="q-btn" onclick="selectAmount(this, 1000)">+1,000</button>
                    <button type="button" class="q-btn selected" onclick="selectAmount(this, 5000)">+5,000</button>
                    <button type="button" class="q-btn" onclick="selectAmount(this, 10000)">+10,000</button>
                </div>

                <label class="label">チャージ方法</label>
                <div class="method-box">
                    <div class="card-icon">💳</div>
                    <div class="card-info">
                        クレジットカード
                        <span class="card-sub">VISA **** 5678</span>
                    </div>
                    <div class="check-circle"></div>
                </div>

                <button type="submit" class="charge-btn">チャージする</button>
            </form>
        </div>
    </div>

    <script>
        const input = document.getElementById('chargeInput');
        function selectAmount(btn, val) {
            input.value = val;
            document.querySelectorAll('.q-btn').forEach(b => b.classList.remove('selected'));
            btn.classList.add('selected');
        }
        input.addEventListener('input', function() {
            document.querySelectorAll('.q-btn').forEach(b => b.classList.remove('selected'));
        });
    </script>
</body>
</html>