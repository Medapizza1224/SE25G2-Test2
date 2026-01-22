<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 5秒後に自動遷移 -->
    <meta http-equiv="refresh" content="5;URL=${nextUrl}">
    <title>チャージ完了</title>
    <script>
        window.addEventListener('pageshow', function(event) {
            if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
                window.location.reload();
            }
        });
    </script>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            display: flex;
            justify-content: center;
            color: #333;
        }
        .container {
            width: 100%;
            max-width: 420px;
            background: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
        }

        /* ヘッダー */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            background: white;
            border-bottom: 1px solid #eee;
        }
        .logo-small { height: 24px; width: auto; }
        .icon-btn { text-decoration: none; font-size: 20px; color: #333; }

        /* コンテンツ */
        .content {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px;
            text-align: center;
        }

        /* アニメーション付きチェックマーク */
        .success-circle {
            width: 100px;
            height: 100px;
            background-color: #FF6900; /* テーマカラー */
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(255, 105, 0, 0.3);
            animation: popIn 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .checkmark {
            width: 30px;
            height: 55px;
            border: solid white;
            border-width: 0 8px 8px 0;
            transform: rotate(45deg);
            margin-top: -10px;
        }

        @keyframes popIn {
            0% { transform: scale(0); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }

        h2 { font-size: 24px; margin: 0 0 10px 0; }
        p { font-size: 14px; color: #888; margin: 0 0 60px 0; }

        .result-amount {
            font-size: 32px; font-weight: bold; margin-bottom: 10px; color: #333;
        }
        .result-label { font-size: 12px; color: #666; margin-bottom: 40px; }

        .btn {
            display: block;
            width: 100%;
            padding: 16px;
            background-color: #333;
            color: white;
            text-decoration: none;
            border-radius: 30px;
            font-size: 16px;
            font-weight: bold;
            transition: opacity 0.2s;
        }
        .btn:active { opacity: 0.8; }
        
        .auto-redirect-msg {
            font-size: 12px; color: #aaa; margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <a href="${pageContext.request.contextPath}/user_home" class="icon-btn">✕</a>
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="ロゴ" class="logo-small">
            <div style="width:20px;"></div> <!-- スペーサー -->
        </div>

        <div class="content">
            <div class="success-circle">
                <div class="checkmark"></div>
            </div>

            <h2>チャージ完了</h2>
            
            <div class="result-amount">
                +<fmt:formatNumber value="${result.chargedAmount}" />
            </div>
            <div class="result-label">現在の残高: ¥<fmt:formatNumber value="${result.newBalance}" /></div>

            <a href="${nextUrl}" class="btn">
                ${nextLabel}
            </a>

            <div class="auto-redirect-msg">5秒後に自動で移動します...</div>
        </div>
    </div>

    <script>
        setTimeout(function() {
            window.location.href = "${nextUrl}";
        }, 5000);
    </script>
</body>
</html>