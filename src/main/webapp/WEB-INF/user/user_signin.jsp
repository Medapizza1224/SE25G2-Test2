<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ログイン</title>
    <style>
        /* 簡易スタイル */
        body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f5f5f5; }
        .card { background: white; padding: 30px; border-radius: 12px; width: 300px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); text-align: center; }
        input { width: 100%; padding: 10px; margin: 10px 0; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #FF6900; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; }
        .error { color: red; font-size: 12px; }
    </style>
</head>
<body>
    <div class="card">
        <h2>ログイン</h2>
        <c:if test="${not empty error}"><p class="error">${error}</p></c:if>
        <form action="user_signin" method="post">
            <input type="text" name="name" placeholder="ユーザー名" required>
            <input type="password" name="password" placeholder="パスワード" value="dummy_pass">
            <button type="submit">ログイン</button>
        </form>
        <br>
        <a href="${pageContext.request.contextPath}/PaymentSetup" style="font-size:12px;">データ未作成の方はこちら(Setup)</a>
    </div>
</body>
</html>