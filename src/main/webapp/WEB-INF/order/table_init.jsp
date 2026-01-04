<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>テーブル設定</title>
    <!-- スタイル省略 -->
</head>
<body>
    <h2>初期設定</h2>
    <c:if test="${not empty error}"><p style="color:red;">${error}</p></c:if>
    
    <form action="Order" method="post"> <!-- AdminTableInit -->
        <p>管理者ID: <input type="text" name="adminName"></p>
        <p>パスワード: <input type="password" name="password"></p>
        <p>テーブル番号 (4桁): <input type="text" name="tableNumber" placeholder="0001"></p>
        <button type="submit">設定して開始</button>
    </form>
</body>
</html>