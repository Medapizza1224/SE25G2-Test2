<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:if test="${empty sessionScope.adminNameManagement}">
    <c:redirect url="/AdminLogin" />
</c:if>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>設定</title>
    <style>
    </style>
</head>
<body>

    <%-- 成功メッセージ --%>
    <c:if test="${not empty requestScope.logoSuccess}">
        OK: ${fn:escapeXml(requestScope.logoSuccess)}
    </c:if>

    <%-- エラーメッセージ --%>
    <c:if test="${not empty requestScope.logoError}">
        NG: ${fn:escapeXml(requestScope.logoError)}
    </c:if>

    <p>現在のロゴ：</p>
    <img src="${pageContext.request.contextPath}/image/logo/logo.svg?t=<%= System.currentTimeMillis() %>" width="100" alt="ロゴ"><br>

    <form action="Setup" method="post" enctype="multipart/form-data">
        <p>ファイルを選択（SVGのみ）：</p>
        <input type="hidden" name="action" value="uploadLogo">
        <input type="file" name="logoFile" accept=".svg" required><br><br>
        <input type="submit" value="アップロード">
    </form>
</body>
</html>