<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>エラー</title>
    <style>
        body {
            font-family: "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f5;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            color: #333;
        }
        .error-card {
            background: #fff;
            width: 90%;
            max-width: 400px;
            padding: 40px 30px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        .icon {
            width: 80px;
            height: 80px;
            margin-bottom: 20px;
        }
        .error-title {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 15px;
            color: #FF3B30; /* エラー色の赤 */
        }
        .error-message {
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 40px;
            color: #555;
        }
        .btn {
            display: inline-block;
            background-color: #333;
            color: #fff;
            text-decoration: none;
            padding: 15px 40px;
            border-radius: 30px;
            font-weight: bold;
            font-size: 16px;
            transition: opacity 0.2s;
        }
        .btn:hover { opacity: 0.8; }
    </style>
</head>
<body>
    <div class="error-card">
        <!-- エラーアイコン (既存のシステム画像を使用) -->
        <img src="${pageContext.request.contextPath}/image/system/エラー.svg" class="icon" alt="Error">
        
        <div class="error-title">エラーが発生しました</div>
        
        <div class="error-message">
            <c:out value="${errorMessage}" default="予期せぬエラーが発生しました。" />
        </div>

        <!-- 戻るボタン (遷移先はServletから指定) -->
        <a href="${pageContext.request.contextPath}${nextUrl}" class="btn">
            <c:out value="${nextLabel}" default="戻る" />
        </a>
    </div>
</body>
</html>