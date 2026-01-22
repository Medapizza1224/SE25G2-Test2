<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>決済完了</title>
    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            font-family: 'Yu Gothic', 'YuGothic', 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
            background-color: #fff;
            color: #333;
        }

        body {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .mobile-platform {
            width: 100%;
            height: 100%;
            max-width: 450px;
            max-height: 960px;
            box-sizing: border-box;
            background: #fff;
            border: 2px solid #F8F7F5;
            display: flex;
            flex-direction: column;
        }

        /* ヘッダー周り */
        .header-container {
            width: 100%;
            box-sizing: border-box;
            background: #FFF;
            padding: 70px 20px 20px 20px;
            display: flex;
            justify-content: center; 
            align-items: center;
            position: relative;
            border-bottom: 1px solid #f0f0f0;
        }

        .logo-img {
            height: 40px;
            width: auto;
            max-width: 200px;
            object-fit: contain;
        }

        .header-right {
            position: absolute;
            right: 20px;
            display: flex;
            align-items: center;
        }

        .logout-icon {
            width: 40px;
            height: 40px;
            object-fit: contain;
            cursor: pointer;
        }

        /* コンテンツエリア */
        .message-container {
            width: 100%;
            box-sizing: border-box;
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding-top: 15%; /* 少し上に詰めてバランス調整 */
            text-align: center;
        }

        .complete-icon {
            width: 115px;
            height: 92px;
            object-fit: contain;
            margin-bottom: 30px;
        }

        /* メッセージテキスト */
        .success-text {
            font-size: 18px;
            font-weight: bold;
            line-height: 1.8;
            margin-bottom: 30px;
            color: #000;
        }

        /* --- 今回追加した金額表示用のスタイル --- */
        .amount-box {
            background-color: #F9F9F9;
            width: 80%;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 50px;
        }

        .amount-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 5px;
            display: block;
        }

        .amount-value {
            font-size: 36px;
            font-weight: bold;
            color: #333;
            font-family: 'Helvetica Neue', Arial, sans-serif; /* 数字をきれいに見せる */
            letter-spacing: -1px;
        }

        .amount-currency {
            font-size: 24px;
            font-weight: normal;
            margin-right: 5px;
            vertical-align: 2px;
        }
        /* ------------------------------------- */

        /* ボタンデザイン */
        .home-button {
            display: flex;
            justify-content: center;
            align-items: center;
            width: 60%;
            max-width: 250px;
            height: 45px;
            background-color: #FF6900;
            color: #FFFFFF;
            font-size: 18px;
            font-weight: bold;
            text-decoration: none;
            border-radius: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: opacity 0.3s;
        }

        .home-button:hover {
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="mobile-platform">
        <div class="header-container">
            <!-- ロゴ -->
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?t=<%= System.currentTimeMillis() %>" alt="ロゴ" class="logo-img">
            
            <!-- ログアウト -->
            <a href="${pageContext.request.contextPath}User" class="header-right">
                <img src="${pageContext.request.contextPath}/image/system/logout.svg" alt="ログアウト" class="logout-icon">
            </a>
        </div>

        <div class="message-container">
            <img src="${pageContext.request.contextPath}/image/system/complete.svg" alt="完了" class="complete-icon">
            
            <c:if test="${not empty successMessage}">
                <div class="success-text">
                    <p style="margin: 0;">決済が完了しました。</p>
                    <p style="margin: 0;">またのご来店をお待ちしております。</p>
                </div>
                <div class="amount-box">
                    <span class="amount-label">お支払い金額</span>
                    <span class="amount-currency">¥</span>
                    <span class="amount-value">
                        <fmt:formatNumber value="${result.paidAmount}" />
                    </span>
                </div>
            </c:if>

            <a href="${pageContext.request.contextPath}/user_home" class="home-button">ホームに戻る</a>
        </div>
    </div>
</body>
</html>