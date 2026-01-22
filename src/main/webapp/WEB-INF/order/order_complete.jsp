<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- セッションチェック --%>
<c:if test="${empty sessionScope.tableNumber}">
    <c:redirect url="/Order" />
</c:if>

<%
    // キャッシュ無効化（戻るボタン対策）
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注文完了</title>
    <style>
        body { 
            font-family: "Helvetica Neue", Arial, sans-serif; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
            background-color: #f5f5f5;
            color: #333;
        }
        .card {
            background: #fff;
            width: 80%;
            max-width: 600px;
            padding: 60px 40px;
            border-radius: 24px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        .logo {
            height: 40px;
            width: auto;
            margin-bottom: 40px;
            object-fit: contain;
        }
        
        /* チェックマークアイコン */
        .check-icon {
            width: 80px;
            height: 80px;
            background-color: #4CAF50; /* 緑色 */
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 30px;
            position: relative;
        }
        .check-icon::after {
            content: '';
            display: block;
            width: 25px;
            height: 45px;
            border: solid white;
            border-width: 0 6px 6px 0;
            transform: rotate(45deg);
            margin-top: -8px;
        }

        h2 {
            font-size: 28px;
            font-weight: bold;
            margin: 0 0 15px 0;
            color: #333;
        }
        p {
            font-size: 16px;
            color: #888;
            margin: 0 0 50px 0;
            line-height: 1.6;
        }

        .btn { 
            background: #FF6900; 
            color: white; 
            padding: 18px 100px; 
            text-decoration: none; 
            border-radius: 50px; 
            font-weight: bold; 
            font-size: 20px; 
            box-shadow: 0 4px 15px rgba(255, 105, 0, 0.3);
            transition: transform 0.1s, opacity 0.2s;
            display: inline-block;
        }
        .btn:active { 
            transform: scale(0.98);
            opacity: 0.9; 
        }
    </style>
</head>
<body>
    <div class="card">
        <!-- ロゴ画像 -->
        <img class="logo" src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="ロゴ">
        
        <!-- チェックアイコン -->
        <div class="check-icon"></div>
        
        <h2>ご注文を承りました</h2>
        <p>スタッフが商品をお持ちします。<br>しばらくお待ちください。</p>
        
        <!-- メニューへ戻るボタン -->
        <a href="${pageContext.request.contextPath}/OrderHome" class="btn">メニューに戻る</a>
    </div>
</body>
</html>