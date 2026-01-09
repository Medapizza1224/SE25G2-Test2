<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新規登録</title>
    <style>body{text-align:center; padding:50px; font-family:sans-serif;} input{padding:10px; margin:10px; width:250px;} button{padding:10px 20px; background:#FF6900; color:white; border:none; font-weight:bold;}</style>
</head>
<body>
    <h2>新規会員登録</h2>
    <p>メールアドレス認証を行います。</p>
    <form action="user_signup" method="post">
        <input type="email" name="email" placeholder="メールアドレス (Gmail等)" required><br>
        <input type="password" name="password" placeholder="パスワード" required><br>
        <input type="text" name="securityCode" placeholder="セキュリティコード(数字4桁)" required><br>
        <button type="submit">確認メールを送信</button>
    </form>
    <br>
    <a href="user_signin">ログイン画面に戻る</a>
</body>
</html>