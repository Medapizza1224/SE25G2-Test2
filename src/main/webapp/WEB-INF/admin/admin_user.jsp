<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ユーザー管理</title>
</head>
<body>
    <h1>ユーザー一覧</h1>
    <table border="1">
        <thead>
            <tr>
                <!-- 1. 連番用の列 -->
                <th>No.</th>
                <th>ユーザーID (UUID)</th>
                <th>ユーザー名</th>
                <th>決済</th>
                <th>状態</th>
                <th>操作</th>
            </tr>
        </thead>
        <tbody>
            <!-- varStatus="status" でループ回数を取得 -->
            <c:forEach var="dto" items="${result.list}" varStatus="status">
                <tr>
                    <!-- 1. 連番を表示 (1から開始) -->
                    <td>${status.count}</td>
                    <td><c:out value="${dto.user.userId}" /></td>
                    <td><c:out value="${dto.user.userName}" /></td>
                    <td>
                        <c:if test="${dto.paid}">済</c:if>
                        <c:if test="${!dto.paid}">未</c:if>
                    </td>
                    <td>
                        <c:if test="${dto.user.lockout}">
                            <span style="color:red;">ロック中</span>
                        </c:if>
                        <c:if test="${!dto.user.lockout}">正常</c:if>
                    </td>
                    <td>
                        <c:if test="${dto.user.lockout}">
                            <form action="${pageContext.request.contextPath}/AdminUserUnlock" method="post">
                                <input type="hidden" name="userId" value="${dto.user.userId}">
                                <button type="submit">解除</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>