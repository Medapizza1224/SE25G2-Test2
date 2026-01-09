<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 5秒後に自動遷移するメタタグ（念のためのフォールバック） -->
    <meta http-equiv="refresh" content="5;URL=${pageContext.request.contextPath}/user_home">
    <title>チャージ完了</title>
    <style>
        body {
            font-family: "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
            background-color: #F8F7F5;
            margin: 0;
            display: flex;
            justify-content: center;
            color: #333;
        }
        .container {
            width: 100%;
            max-width: 480px;
            background: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
            border-left: 1px solid #ddd;
            border-right: 1px solid #ddd;
        }

        /* ヘッダーエリア */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 20px;
            background-color: white;
            border-bottom: 4px solid #ccc;
            height: 60px;
        }
        .header a {
            text-decoration: none;
            color: #000;
            font-size: 8px;
            font-weight: bold;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 2px;
        }
        .icon { font-size: 24px; line-height: 1; }
        
        .header-center {
            display: flex;
            align-items: center;
            font-weight: bold;
            font-size: 14px;
        }
        .cow-icon { font-size: 24px; margin-right: 5px; }

        /* メインコンテンツ */
        .content {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
            margin-bottom: 100px;
        }

        .message {
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 120px;
            letter-spacing: 1px;
        }

        /* オレンジ色の完了ボタン */
        .return-btn {
            background-color: #FF6600;
            color: white;
            text-decoration: none;
            padding: 20px 0;
            width: 80%;
            max-width: 300px;
            border-radius: 40px;
            font-size: 20px;
            font-weight: bold;
            text-align: center;
            box-shadow: 0 4px 10px rgba(255, 102, 0, 0.2);
            transition: opacity 0.2s;
            border: none;
            display: block;
        }
        .return-btn:active {
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- ヘッダー -->
        <div class="header">
            <a href="${pageContext.request.contextPath}/user_home">
                <span class="icon">🏠</span>
                <span>ホームに戻る</span>
            </a>
            
            <div class="header-center">
                <span class="cow-icon">🐄</span>
                <span>焼肉〇〇</span>
            </div>
            
            <a href="${pageContext.request.contextPath}/user_signin">
                <span class="icon">🚪</span>
                <span>ログアウト</span>
            </a>
        </div>

        <!-- コンテンツ -->
        <div class="content">
            <div class="message">
                チャージが完了しました。
            </div>

            <!-- ボタン -->
            <a href="${pageContext.request.contextPath}/user_home" class="return-btn">
                決済画面に戻る
            </a>
        </div>
    </div>

    <!-- 5秒後に自動遷移するスクリプト -->
    <script>
        setTimeout(function() {
            window.location.href = "${pageContext.request.contextPath}/user_home";
        }, 5000); // 5000ミリ秒 = 5秒
    </script>
</body>
</html>