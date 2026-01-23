<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="util.AppConfig" %>
<%
    AppConfig conf = AppConfig.load(application);
    request.setAttribute("conf", conf);
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 5秒後に自動でメニュー画面に戻る -->
    <meta http-equiv="refresh" content="5;URL=${pageContext.request.contextPath}/OrderHome">
    <title>注文完了</title>
    <style>
        :root {
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        body { 
            margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; 
            background: #f5f5f5; color: #333; height: 100vh; display: flex; flex-direction: column; 
        }
        
        /* ヘッダー */
        .header { 
            padding: 20px 40px; background: #fff; display: flex; justify-content: center; align-items: center; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.05); flex-shrink: 0;
        }
        .logo-img { height: 35px; width: auto; }

        .container { 
            flex: 1; display: flex; padding: 40px; justify-content: center; align-items: center;
        }

        /* 全画面カードスタイル（会計警告と統一） */
        .full-screen-card {
            width: 100%;
            max-width: 800px;
            height: 80vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            background: #fff;
            border-radius: 24px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        }

        /* チェックアイコンのアニメーション */
        .success-icon { 
            font-size: 80px; 
            color: #4CAF50; 
            margin-bottom: 20px; 
            animation: scaleUp 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275); 
        }
        
        .title { font-size: 36px; font-weight: bold; color: #333; margin-bottom: 20px; }
        .text { font-size: 20px; color: #666; line-height: 1.8; margin-bottom: 40px; }
        
        /* ボタン */
        .back-btn { 
            background: var(--main-color); 
            color: white; 
            padding: 20px 80px; 
            border-radius: 50px; 
            text-decoration: none; 
            font-weight: bold; 
            font-size: 22px; 
            box-shadow: 0 6px 15px rgba(0,0,0,0.1);
            transition: opacity 0.2s;
        }
        .back-btn:hover { opacity: 0.9; }

        .timer-text { font-size: 14px; color: #999; margin-top: 25px; }

        @keyframes scaleUp {
            from { transform: scale(0); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="header">
        <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" class="logo-img">
    </div>

    <div class="container">
        <div class="full-screen-card">
            <div class="success-icon">✅</div>
            <div class="title">ご注文を承りました</div>
            <div class="text">
                キッチンで調理を開始いたします。<br>
                お料理が届くまで、今しばらくお待ちください。
            </div>
            
            <a href="${pageContext.request.contextPath}/OrderHome" class="back-btn">メニューに戻る</a>
            
            <div class="timer-text">
                ※5秒後に自動的にメニューへ戻ります
            </div>
        </div>
    </div>
</body>
</html>