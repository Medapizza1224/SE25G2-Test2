<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="util.AppConfig" %>
<%
    // 変数名を config -> appSettings に変更
    AppConfig appSettings = AppConfig.load(application);
    request.setAttribute("conf", appSettings);
%>
<c:if test="${empty sessionScope.adminNameManagement}">
    <c:redirect url="/Admin" />
</c:if>

<c:if test="${empty sessionScope.adminNameManagement}">
    <c:redirect url="/Admin" />
</c:if>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>注文状況 | キッチン</title>
    <style>
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; display: flex; height: 100vh; background-color: #f5f5f5; color: #333; 
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        a { text-decoration: none; color: inherit; }
        
        .sidebar { width: 240px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; }
        /* ブランド部分 */
        .brand { 
            padding: 0 25px 30px; 
            display: flex; align-items: center; justify-content: flex-start;
        }
        /* ロゴ画像 */
        .brand-logo { height: 35px; width: auto; object-fit: contain; }
        .sidebar-item { display: flex; align-items: center; padding: 15px 25px; color: #666; font-weight: bold; font-size: 16px; transition: 0.2s; }
        .sidebar-item:hover { background-color: #f9f9f9; color: #333; }
        .sidebar-item.active { background-color: #fff5f0; color: var(--main-color); border-right: 4px solid var(--main-color); }
        .icon-img { width: 24px; height: 24px; margin-right: 10px; object-fit: contain; }

        .content { flex: 1; padding: 40px; overflow-y: auto; }
        .page-header { border-left: 5px solid var(--main-color); padding-left: 15px; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: bold; }

        /* キッチン固有 */
        .order-container { display: flex; flex-wrap: wrap; gap: 20px; }
        .order-card { background: #fff; width: 300px; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.05); display: flex; flex-direction: column; }
        .card-header { background: #f9f9f9; padding: 15px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; font-weight: bold; }
        .timer { color: var(--main-color); display: flex; align-items: center; gap: 5px; font-size: 14px; }
        .card-body { padding: 0; flex: 1; }
        .order-item { padding: 15px; border-bottom: 1px solid #f5f5f5; display: flex; align-items: center; background-color: #ffeaea; }
        .qty-badge { background: #FF0000; color: white; width: 28px; height: 28px; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-weight: bold; margin-right: 10px; font-size: 14px; }
        .item-name { font-weight: bold; font-size: 16px; }
        .card-footer { padding: 15px; }
        .done-btn { width: 100%; padding: 12px; border: none; border-radius: 30px; background: var(--main-color); color: white; font-weight: bold; cursor: pointer; font-size: 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: 0.2s; }
        .done-btn:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand">
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" class="brand-logo" alt="ロゴ">
        </div>
        <a href="AdminKitchen" class="sidebar-item active">
            <img src="${pageContext.request.contextPath}/image/system/icon_kitchen.svg" class="icon-img"> 注文状況
        </a>
        <a href="AdminAnalysis" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_analysis.svg" class="icon-img"> 分析
        </a>
        <a href="AdminUserView" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_user.svg" class="icon-img"> ユーザー
        </a>
        <a href="AdminProductList" class="sidebar-item">
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
            <div class="page-title">注文状況（未提供）</div>
        </div>
        
        <div class="order-container">
            <c:if test="${empty result.unservedList}">
                <p style="color:#666; font-size:18px;">現在、未提供の注文はありません。</p>
            </c:if>
            <c:forEach var="item" items="${result.unservedList}">
                <div class="order-card">
                    <div class="card-header">
                        <!-- ★修正: テーブル番号を表示 -->
                        <span style="font-size:18px;">Table: ${item.tableNumber}</span>
                        <span class="timer" data-start-time="${item.addOrderAt.time}">⏱ 計算中...</span>
                    </div>
                    <div class="card-body">
                        <div class="order-item">
                            <span class="qty-badge">${item.quantity}</span>
                            <span class="item-name"><c:out value="${item.productName != null ? item.productName : item.productId}" /></span>
                        </div>
                    </div>
                    <div class="card-footer">
                        <form action="AdminKitchen" method="post">
                            <input type="hidden" name="orderItemId" value="${item.orderItemId}">
                            <button type="submit" class="done-btn">提供済み</button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    
    <script>
        function updateTimers() {
            const now = new Date().getTime();
            document.querySelectorAll('.timer').forEach(timer => {
                const startTime = parseInt(timer.getAttribute('data-start-time'));
                if (!isNaN(startTime)) {
                    let diff = Math.floor((now - startTime) / 1000);
                    if (diff < 0) diff = 0;
                    timer.textContent = '⏱ ' + diff + 's';
                    if (diff > 600) { timer.style.color = '#FF0000'; timer.style.fontWeight = 'bold'; }
                }
            });
        }
        updateTimers();
        setInterval(updateTimers, 1000);
        setTimeout(() => location.reload(), 30000);
    </script>
</body>
</html>