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
            max-width: 450px; /* 少し幅を広げる */
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
            margin-bottom: 20px;
            color: #FF3B30; /* エラー色の赤 */
        }
        .error-message {
            font-size: 16px;
            line-height: 1.8;
            margin-bottom: 40px;
            color: #444;
            /* ★追加: 改行コードを反映させ、長文を折り返す */
            white-space: pre-wrap; 
            text-align: left;     /* 左寄せで読みやすく */
            background-color: #fafafa;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #eee;
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
        <!-- エラーアイコン -->
        <img src="${pageContext.request.contextPath}/image/system/エラー.svg" class="icon" alt="Error">
        
        <div class="error-title">
            <c:out value="${errorTitle}" default="エラー" />
        </div>
        
        <div class="error-message"><c:out value="${errorMessage}" default="予期せぬエラーが発生しました。" /></div>

        <!-- 戻るボタン -->
        <a href="${pageContext.request.contextPath}${nextUrl}" class="btn">
            <c:out value="${nextLabel}" default="戻る" />
        </a>
    </div>
</body>
</html>