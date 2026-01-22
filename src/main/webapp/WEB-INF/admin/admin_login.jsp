<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>管理者ログイン</title>
    <style>
        body {
            font-family: "Yu Gothic", "YuGothic", sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background-color: #fff;
        }

        .container {
            width: 300px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo {
            width: 160px;
            height: auto;
            margin-bottom: 40px;
        }

        h2 { display: none; }

        .error-msg {
            color: red;
            margin-bottom: 10px;
            font-size: 14px;
            font-weight: bold;
            width: 100%;
            text-align: left;
        }

        form {
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .input-group {
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .input-label {
            font-size: 15px;
            font-weight: bold;
            color: #000;
            margin-bottom: 6px;
            display: block;
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            height: 40px;
            box-sizing: border-box;
            border: 2px solid #BFBFBF;
            border-radius: 20px;
            padding: 0 20px;
            font-size: 14px;
            font-weight: bold;
            font-family: inherit;
            outline: none;
            color: #000;
        }
        
        input::placeholder { color: #A6A6A6; }

        /* 目のアイコン (画像) */
        .eye-icon {
            position: absolute;
            right: 15px;
            top: 35px; /* ラベルの高さ等を考慮して位置調整 */
            width: 24px;
            height: 24px;
            cursor: pointer;
            pointer-events: auto;
        }

        button[type="submit"] {
            width: 100%;
            height: 50px;
            background-color: #000000;
            color: #FFFFFF;
            border: none;
            border-radius: 25px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            font-family: inherit;
            margin-top: 30px;
        }

        button[type="submit"]:hover { opacity: 0.8; }
    </style>
    <script>
        function togglePassword(id) {
            const input = document.getElementById(id);
            if (input.type === "password") {
                input.type = "text";
            } else {
                input.type = "password";
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <!-- ロゴ画像 -->
        <img class="logo" src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="ロゴ">
        
        <h2>管理者ログイン</h2>

        <c:if test="${not empty error}">
            <p class="error-msg">${error}</p>
        </c:if>

        <form action="${pageContext.request.contextPath}/Admin" method="post">
            <!-- 管理者名 -->
            <div class="input-group">
                <span class="input-label">管理者名</span>
                <input type="text" name="adminName" value="${not empty adminName ? adminName : ''}">
            </div>

            <!-- パスワード -->
            <div class="input-group">
                <span class="input-label">パスワード</span>
                <input type="password" name="password" id="adminPass">
                <!-- 目のアイコン (画像に変更) -->
                <img src="${pageContext.request.contextPath}/image/system/password.svg" 
                     class="eye-icon" 
                     onclick="togglePassword('adminPass')" 
                     alt="表示切替">
            </div>

            <button type="submit">ログイン</button>
        </form>
    </div>
</body>
</html>