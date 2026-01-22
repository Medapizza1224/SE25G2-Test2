<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/User" />
</c:if>

<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>登録完了</title></head>
<body style="text-align:center; padding:50px;">
    <h2 style="color:#00aa00;">登録が完了しました！</h2>
    <p>ようこそ、${user.userName} さん</p>
    <p>初回特典として 10,000円 チャージされています。</p>
    <br>
    <a href="user_signin" style="background:#FF6900; color:white; padding:10px 20px; text-decoration:none; border-radius:5px;">ログイン画面へ</a>
</body>
</html>