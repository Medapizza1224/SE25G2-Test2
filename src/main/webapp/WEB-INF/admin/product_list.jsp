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
    <title>商品管理</title>
    <style>
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; display: flex; height: 100vh; background-color: #f5f5f5; color: #333; 
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        a { text-decoration: none; color: inherit; }

        .sidebar { width: 240px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; }
        .sidebar-item { display: flex; align-items: center; padding: 15px 25px; color: #666; font-weight: bold; font-size: 16px; transition: 0.2s; }
        .sidebar-item:hover { background-color: #f9f9f9; color: #333; }
        .sidebar-item.active { background-color: #fff5f0; color: var(--main-color); border-right: 4px solid var(--main-color); }
        .icon-img { width: 24px; height: 24px; margin-right: 10px; object-fit: contain; }

        .content { flex: 1; padding: 40px; overflow-y: auto; }
        .page-header { border-left: 5px solid var(--main-color); padding-left: 15px; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: bold; }

        .top-bar { display: flex; justify-content: flex-end; margin-bottom: 20px; }
        .add-btn { background: #000; color: white; padding: 12px 25px; border-radius: 30px; font-weight: bold; font-size: 14px; display: flex; align-items: center; gap: 5px; transition: 0.2s; }
        .add-btn:hover { opacity: 0.8; }

        .table-container { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f9f9f9; text-align: left; padding: 15px 20px; border-bottom: 2px solid #eee; font-size: 14px; color: #666; }
        td { padding: 15px 20px; border-bottom: 1px solid #eee; vertical-align: middle; }
        .p-img { width: 60px; height: 40px; object-fit: cover; border-radius: 4px; background: #ddd; }
        .status-ok { color: #00A0E9; font-weight: bold; font-size: 12px; }
        .status-ng { color: #FF0000; font-weight: bold; font-size: 12px; }
        .edit-btn { background: #333; color: white; padding: 6px 15px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        /* ブランド部分 */
        .brand { 
            padding: 0 25px 30px; 
            display: flex; align-items: center; justify-content: flex-start;
        }
        /* ロゴ画像 */
        .brand-logo { height: 35px; width: auto; object-fit: contain; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand">
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" class="brand-logo" alt="ロゴ">
        </div>
        <a href="AdminKitchen" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_kitchen.svg" class="icon-img"> 注文状況
        </a>
        <a href="AdminAnalysis" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_analysis.svg" class="icon-img"> 分析
        </a>
        <a href="AdminUserView" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_user.svg" class="icon-img"> ユーザー
        </a>
        <a href="AdminProductList" class="sidebar-item active">
            <img src="${pageContext.request.contextPath}/image/system/icon_product.svg" class="icon-img"> 商品
        </a>
        <a href="admin-setup" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_setting.svg" class="icon-img"> 設定
        </a>
        <a href="Admin?action=logout" class="sidebar-item" style="margin-top:auto;">
            <img src="${pageContext.request.contextPath}/image/system/icon_logout.svg" class="icon-img"> ログアウト
        </a>
    </div>

    <div class="content">
        <div class="page-header">
            <div class="page-title">商品一覧</div>
        </div>

        <div class="top-bar">
            <a href="AdminProductEdit" class="add-btn">＋ 商品登録フォーム</a>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th style="width:50px;">No.</th>
                        <th style="width:80px;">画像</th>
                        <th>商品ID</th>
                        <th>商品名</th>
                        <th>カテゴリ</th>
                        <th>価格</th>
                        <th>状態</th>
                        <th style="width:80px;">操作</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${result.productList}" varStatus="st">
                        <tr>
                            <td>${st.count}</td>
                            <td>
                                <img src="${pageContext.request.contextPath}/image/product/${p.image}" class="p-img" alt="">
                            </td>
                            <td>${p.productId}</td>
                            <td style="font-weight:bold;">${p.productName}</td>
                            <td>${p.category}</td>
                            <td>¥ <fmt:formatNumber value="${p.price}" /></td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.salesStatus == '販売中'}">
                                        <span class="status-ok">販売中</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-ng">${p.salesStatus}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <a href="AdminProductEdit?id=${p.productId}" class="edit-btn">更新</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>