<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="util.AppConfig" %>
<%
    // 変数名を変更
    AppConfig appSettings = AppConfig.load(application);
    request.setAttribute("conf", appSettings);
%>

<c:if test="${empty sessionScope.adminNameManagement}">
    <c:redirect url="/Admin" />
</c:if>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>ユーザー管理</title>
    <style>
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; display: flex; height: 100vh; background-color: #f5f5f5; color: #333; 
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        a { text-decoration: none; color: inherit; }

        .sidebar { width: 240px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; }
        .brand { font-size: 20px; font-weight: bold; padding: 0 25px 30px; display: flex; align-items: center; gap: 10px; }
        .sidebar-item { display: flex; align-items: center; padding: 15px 25px; color: #666; font-weight: bold; font-size: 16px; transition: 0.2s; }
        .sidebar-item:hover { background-color: #f9f9f9; color: #333; }
        .sidebar-item.active { background-color: #fff5f0; color: var(--main-color); border-right: 4px solid var(--main-color); }
        .icon-img { width: 24px; height: 24px; margin-right: 10px; object-fit: contain; }

        .content { flex: 1; padding: 40px; overflow-y: auto; }
        .page-header { border-left: 5px solid var(--main-color); padding-left: 15px; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: bold; }

        .table-container { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #fff; text-align: left; padding: 20px; border-bottom: 2px solid #ccc; font-size: 14px; font-weight: bold; color: #000; }
        td { padding: 20px; border-bottom: 1px solid #eee; vertical-align: middle; font-size: 14px; }

        .badge-active { background-color: #00A0E9; color: white; padding: 8px 0; border-radius: 20px; font-weight: bold; font-size: 12px; display: inline-block; text-align: center; width: 100px; }
        .badge-lock { background-color: #FF0000; color: white; padding: 8px 0; border-radius: 20px; font-weight: bold; font-size: 12px; display: inline-block; text-align: center; width: 100px; }
        .btn-unlock { background-color: #000; color: white; padding: 8px 20px; border-radius: 6px; font-size: 12px; font-weight: bold; border: none; cursor: pointer; transition: 0.2s; }
        .btn-unlock:hover { opacity: 0.8; }
        .uuid-text { font-family: monospace; color: #444; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand">🐄 焼肉〇〇</div>
        <a href="AdminKitchen" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_kitchen.svg" class="icon-img"> 注文状況
        </a>
        <a href="AdminAnalysis" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_analysis.svg" class="icon-img"> 分析
        </a>
        <a href="AdminUserView" class="sidebar-item active">
            <img src="${pageContext.request.contextPath}/image/system/icon_user.svg" class="icon-img"> ユーザー
        </a>
        <a href="AdminProductList" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_product.svg" class="icon-img"> 商品
        </a>
        <a href="admin-setup" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_setting.svg" class="icon-img"> 設定
        </a>
        <a href="Admin" class="sidebar-item" style="margin-top:auto;">
            <img src="${pageContext.request.contextPath}/image/system/icon_logout.svg" class="icon-img"> ログアウト
        </a>
    </div>

    <div class="content">
        <div class="page-header">
            <div class="page-title">ユーザー</div>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th style="width: 80px; padding-left: 30px;">整理番号</th>
                        <th>UUID</th>
                        <th>ユーザー名</th>
                        <th style="text-align: center;">ユーザー状況</th>
                        <th style="text-align: center;">ロックアウト</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="dto" items="${result.list}" varStatus="status">
                        <tr>
                            <td style="padding-left: 30px;">${status.count}</td>
                            <td class="uuid-text"><c:out value="${dto.user.userId}" /></td>
                            <td><c:out value="${dto.user.userName}" /></td>
                            <td style="text-align: center;">
                                <c:choose>
                                    <c:when test="${dto.user.lockout}">
                                        <span class="badge-lock">ロックアウト</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-active">アクティブ</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: center;">
                                <c:if test="${dto.user.lockout}">
                                    <form action="${pageContext.request.contextPath}/AdminUserUnlock" method="post">
                                        <input type="hidden" name="userId" value="${dto.user.userId}">
                                        <button type="submit" class="btn-unlock">解除</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>