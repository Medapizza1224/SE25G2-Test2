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
    <title>ホーム - 焼肉〇〇</title>
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
            font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            display: flex;
            justify-content: center;
            /* ノッチ対応 + 余白追加 */
            padding-top: calc(env(safe-area-inset-top) + 20px);
            padding-bottom: env(safe-area-inset-bottom);
            padding-left: env(safe-area-inset-left);
            padding-right: env(safe-area-inset-right);
        }
        .container {
            width: 100%;
            max-width: 420px;
            background: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
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

        .content { padding: 20px; flex: 1; display: flex; flex-direction: column; }

        /* 残高カード */
        .balance-card {
            background: linear-gradient(135deg, var(--main-color) 0%, #FF8800 100%);
            color: white;
            border-radius: 16px;
            padding: 25px 20px;
            margin-bottom: 30px;
            box-shadow: 0 8px 16px rgba(0,0,0,0.1);
            position: relative;
        }
        .balance-label { font-size: 14px; opacity: 0.9; margin-bottom: 5px; }
        .balance-amount { font-size: 40px; font-weight: bold; letter-spacing: -1px; margin-bottom: 10px; }
        
        .point-badge {
            background: rgba(255,255,255,0.2);
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            display: inline-block;
        }

        .charge-btn-mini {
            position: absolute;
            top: 25px;
            right: 20px;
            background: white;
            color: var(--main-color);
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
            padding: 8px 16px;
            border-radius: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .action-area {
            text-align: center;
            margin-top: 20px;
        }
        .qr-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            background-color: #333;
            color: white;
            text-decoration: none;
            padding: 20px 0;
            border-radius: 12px;
            font-size: 18px;
            font-weight: bold;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            transition: transform 0.1s;
        }
        .qr-btn:active { transform: scale(0.98); }
        
        .qr-icon-img { 
            width: 24px; 
            height: 24px; 
            margin-right: 10px; 
            object-fit: contain;
            filter: invert(1);
        }

        .welcome-msg {
            margin-bottom: 15px;
            font-weight: bold;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="icon-btn">
                <img src="${pageContext.request.contextPath}/image/system/ホーム.svg" class="icon-img" alt="ホーム">
            </div>
            
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="焼肉〇〇" class="header-logo">
            
            <a href="${pageContext.request.contextPath}/User?action=logout" class="icon-btn" title="ログアウト">
                <img src="${pageContext.request.contextPath}/image/system/ログアウト.svg" class="icon-img" alt="ログアウト">
            </a>
        </div>

        <div class="content">
            <div class="welcome-msg">
                ようこそ、<c:out value="${user.userName}"/> さん
            </div>

            <div class="balance-card">
                <div class="balance-label">残高</div>
                <div class="balance-amount">¥<fmt:formatNumber value="${user.balance}" /></div>
                
                <div class="point-badge">
                    P <fmt:formatNumber value="${user.point}" /> pt
                </div>

                <a href="${pageContext.request.contextPath}/UserCharge" class="charge-btn-mini">
                    + チャージ
                </a>
            </div>

            <div class="action-area">
                <p style="color:#666; margin-bottom:10px; font-size:14px;">お会計はこちらから</p>
                <a href="${pageContext.request.contextPath}/user_qr_scan" class="qr-btn">
                    <img src="${pageContext.request.contextPath}/image/system/カメラ.svg" class="qr-icon-img" alt="カメラ">
                    QRコードを読み取る
                </a>
            </div>
        </div>
    </div>
</body>
</html>