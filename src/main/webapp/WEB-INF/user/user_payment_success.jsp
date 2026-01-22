<%@ page language="java" contentType="text/html; charset=UTF-8" %>
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
    <title>決済完了</title>
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
        .mobile-container {
            width: 100%;
            max-width: 420px;
            background: #fff;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }

        /* ヘッダー */
        .header {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 15px;
            background: #fff;
            position: relative;
            border-bottom: 1px solid #f9f9f9;
        }
        .logo-img { height: 28px; width: auto; }
        .logout-btn {
            position: absolute; right: 20px;
            text-decoration: none; font-size: 20px; color: #333;
        }

        /* コンテンツ */
        .content {
            flex: 1;
            padding: 40px 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .complete-icon-box {
            width: 80px; height: 80px;
            background: #FF6900;
            border-radius: 50%;
            display: flex; justify-content: center; align-items: center;
            margin-bottom: 20px;
            box-shadow: 0 4px 10px rgba(255, 105, 0, 0.3);
        }
        .checkmark {
            width: 25px; height: 45px;
            border: solid white; border-width: 0 6px 6px 0;
            transform: rotate(45deg); margin-top: -8px;
        }

        .title { font-size: 22px; font-weight: bold; margin-bottom: 10px; }
        .sub-title { font-size: 14px; color: #888; margin-bottom: 40px; }

        /* レシート風エリア */
        .receipt-card {
            width: 100%;
            background: #F9F9F9;
            border-radius: 16px;
            padding: 30px 20px;
            margin-bottom: 40px;
            position: relative;
            border: 1px solid #eee;
        }
        /* レシートのギザギザ（擬似要素） */
        .receipt-card::after {
            content: "";
            position: absolute; bottom: -10px; left: 0; width: 100%; height: 10px;
            background: linear-gradient(135deg, transparent 75%, #F9F9F9 75%) 0 50%,
                        linear-gradient(45deg, transparent 75%, #F9F9F9 75%) 0 50%;
            background-size: 20px 20px;
            transform: rotate(180deg);
        }

        .amount-row { display: flex; justify-content: center; align-items: baseline; margin-bottom: 10px; color: #333; }
        .currency { font-size: 24px; font-weight: bold; margin-right: 5px; }
        .amount { font-size: 42px; font-weight: bold; letter-spacing: -1px; }
        
        .info-row {
            display: flex; justify-content: space-between;
            font-size: 14px; color: #666; margin-top: 15px; border-top: 1px dashed #ccc; padding-top: 15px;
        }
        .highlight { color: #FF6900; font-weight: bold; }

        .home-btn {
            width: 100%; padding: 16px;
            background: #333; color: white;
            text-decoration: none; border-radius: 30px;
            font-weight: bold; text-align: center;
            font-size: 16px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            transition: transform 0.1s;
        }
        .home-btn:active { transform: scale(0.98); }

    </style>
</head>
<body>
    <div class="mobile-container">
        <div class="header">
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="ロゴ" class="logo-img">
            <a href="${pageContext.request.contextPath}/User?action=logout" class="logout-btn" title="ログアウト">🚪</a>
        </div>

        <div class="content">
            <div class="complete-icon-box">
                <div class="checkmark"></div>
            </div>
            
            <div class="title">決済完了</div>
            <div class="sub-title">ご利用ありがとうございました</div>

            <c:if test="${not empty successMessage}">
                <div class="receipt-card">
                    <div style="text-align:center; font-size:12px; color:#888; margin-bottom:5px;">お支払い金額</div>
                    <div class="amount-row">
                        <span class="currency">¥</span>
                        <span class="amount"><fmt:formatNumber value="${result.paidAmount}" /></span>
                    </div>
                    
                    <div class="info-row">
                        <span>獲得ポイント</span>
                        <span class="highlight">+<fmt:formatNumber value="${result.earnedPoints}" /> pt</span>
                    </div>
                    <div class="info-row" style="border-top:none; margin-top:5px; padding-top:0;">
                        <span>残高</span>
                        <span>¥<fmt:formatNumber value="${result.currentBalance}" /></span>
                    </div>
                </div>
            </c:if>

            <a href="${pageContext.request.contextPath}/user_home" class="home-btn">ホームに戻る</a>
        </div>
    </div>
</body>
</html>