<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>


<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ログイン</title>
    <style>
        body { font-family: "Yu Gothic", "YuGothic", sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background-color: #fff; }
        .container { width: 300px; display: flex; flex-direction: column; align-items: center; }
        .logo { width: 160px; height: auto; margin-bottom: 40px; }
        h2 { display: none; }

        form { width: 100%; display: flex; flex-direction: column; gap: 18px; }
        .input-group { margin: 0; padding: 0; display: flex; flex-direction: column; position: relative; }
        .input-label { font-size: 15px; font-weight: bold; color: #000; margin-bottom: 6px; display: block; }
        input[type="text"], input[type="password"] { width: 100%; height: 40px; box-sizing: border-box; border: 2px solid #BFBFBF; border-radius: 20px; padding: 0 20px; font-size: 14px; font-weight: bold; font-family: inherit; outline: none; color: #000; }
        input::placeholder { color: #A6A6A6; }
        .eye-icon { position: absolute; right: 15px; top: 35px; width: 24px; height: 24px; cursor: pointer; pointer-events: auto; }

        button[type="submit"] { width: 100%; height: 50px; background-color: #000000; color: #FFFFFF; border: none; border-radius: 25px; font-size: 18px; font-weight: bold; cursor: pointer; font-family: inherit; margin-top: 10px; }
        button[type="submit"]:hover { opacity: 0.8; }
        
        .link-area { margin-top: 25px; font-size: 14px; font-weight: bold; text-align: center; }
        .link-area a { color: #000; text-decoration: none; border-bottom: 1px solid #000; }

        /* エラー表示スタイル */
        .error-container { display: flex; align-items: center; justify-content: flex-start; gap: 5px; color: #FF0000; font-size: 13px; font-weight: bold; margin-top: 10px; margin-bottom: 10px; }
        .error-icon { width: 16px; height: 16px; }
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
        <img class="logo" src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="ロゴ">
        <h2>ログイン</h2>

        <form action="${pageContext.request.contextPath}/User" method="post">
            <div class="input-group">
                <span class="input-label">メールアドレス</span>
                <input type="text" name="name" placeholder="" required>
            </div>

            <div class="input-group">
                <span class="input-label">パスワード</span>
                <input type="password" name="password" id="userPass" value="dummy_pass">
                <img src="${pageContext.request.contextPath}/image/system/password.svg" class="eye-icon" onclick="togglePassword('userPass')" alt="表示切替">
            </div>

            <!-- エラーメッセージ -->
            <c:if test="${not empty error}">
                <div class="error-container">
                    <img src="${pageContext.request.contextPath}/image/system/エラー.svg" class="error-icon" alt="!">
                    <span>${error}</span>
                </div>
            </c:if>

            <button type="submit">ログイン</button>
        </form>

        <div class="link-area">
            <a href="${pageContext.request.contextPath}/user_signup">新規登録はこちら</a>
        </div>
    </div>
</body>
</html>