<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>端末ログイン</title>
    <style>
        /* 管理画面ログイン等と同じデザイン */
        body { font-family: "Yu Gothic", sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background-color: #fff; }
        .container { width: 300px; display: flex; flex-direction: column; align-items: center; }
        .logo { width: 160px; height: auto; margin-bottom: 40px; }
        .error-msg { color: red; margin-bottom: 10px; font-size: 14px; font-weight: bold; width: 100%; text-align: left; }
        form { width: 100%; display: flex; flex-direction: column; gap: 18px; }
        .input-group { position: relative; }
        .input-label { font-size: 15px; font-weight: bold; margin-bottom: 6px; display: block; }
        input { width: 100%; height: 40px; box-sizing: border-box; border: 2px solid #BFBFBF; border-radius: 20px; padding: 0 20px; font-size: 14px; font-weight: bold; outline: none; }
        .eye-icon { position: absolute; right: 15px; top: 35px; width: 24px; cursor: pointer; }
        button { width: 100%; height: 50px; background-color: #000; color: #fff; border: none; border-radius: 25px; font-size: 18px; font-weight: bold; cursor: pointer; margin-top: 30px; }
        button:hover { opacity: 0.8; }
    </style>
    <script>
        function togglePassword(id) {
            const x = document.getElementById(id);
            x.type = (x.type === "password") ? "text" : "password";
        }
    </script>
</head>
<body>
    <div class="container">
        <img class="logo" src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="ロゴ">
        
        <c:if test="${not empty error}"><p class="error-msg">${error}</p></c:if>
        
        <form action="Order" method="post">
            <div class="input-group">
                <span class="input-label">管理者名</span>
                <input type="text" name="adminName" value="${not empty adminName ? adminName : ''}">
            </div>
            <div class="input-group">
                <span class="input-label">パスワード</span>
                <input type="password" name="password" id="pass">
                <img src="${pageContext.request.contextPath}/image/system/password.svg" class="eye-icon" onclick="togglePassword('pass')">
            </div>
            <button type="submit">ログイン</button>
        </form>
    </div>
</body>
</html>