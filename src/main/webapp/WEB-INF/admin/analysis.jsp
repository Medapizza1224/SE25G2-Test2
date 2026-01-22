<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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

<c:if test="${empty sessionScope.adminNameManagement}">
    <c:redirect url="/Admin" />
</c:if>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>売上分析</title>
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

        /* 分析固有 */
        .tab-container { display: flex; gap: 10px; margin-bottom: 30px; border-bottom: 1px solid #ddd; padding-bottom: 10px; }
        .tab-btn { padding: 10px 25px; border-radius: 30px; background: #eee; color: #666; font-weight: bold; font-size: 14px; transition: 0.2s; }
        .tab-btn:hover { background: #e0e0e0; }
        .tab-btn.active { background: var(--main-color); color: white; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }

        .ranking-container { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .section-title { font-size: 18px; font-weight: bold; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .section-icon { color: var(--main-color); }

        .rank-grid { display: flex; gap: 30px; overflow-x: auto; padding-bottom: 20px; }
        .rank-card { width: 200px; flex-shrink: 0; display: flex; flex-direction: column; align-items: center; }
        .crown { font-size: 32px; margin-bottom: 5px; }
        .gold { color: #FFD700; }
        .silver { color: #C0C0C0; }
        .bronze { color: #CD7F32; }
        .rank-badge { background: var(--main-color); color: white; width: 30px; height: 30px; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-weight: bold; margin-bottom: 10px; }
        
        .food-img { width: 100%; height: 140px; object-fit: cover; border-radius: 12px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-bottom: 15px; }
        .food-name { font-weight: bold; font-size: 16px; margin-bottom: 5px; text-align: center; }
        .food-count { font-size: 13px; color: #666; background: #f0f0f0; padding: 5px 15px; border-radius: 20px; }
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
        <a href="AdminAnalysis" class="sidebar-item active">
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
            <div class="page-title">売上分析</div>
        </div>

        <div class="tab-container">
            <c:set var="cur" value="${result.currentType}" />
            <a href="AdminAnalysis?type=Single" class="tab-btn ${cur == 'Single' ? 'active' : ''}">おひとり様</a>
            <a href="AdminAnalysis?type=Pair" class="tab-btn ${cur == 'Pair' ? 'active' : ''}">大人2人</a>
            <a href="AdminAnalysis?type=Family" class="tab-btn ${cur == 'Family' ? 'active' : ''}">ファミリー</a>
            <a href="AdminAnalysis?type=AdultGroup" class="tab-btn ${cur == 'AdultGroup' ? 'active' : ''}">大人グループ</a>
            <a href="AdminAnalysis?type=Group" class="tab-btn ${cur == 'Group' ? 'active' : ''}">グループ</a>
        </div>

        <div class="ranking-container">
            <div class="section-title">
                <span class="section-icon">🏆</span> 人気商品ランキング (TOP 5)
            </div>
            <div class="rank-grid">
                <c:if test="${empty result.ranking}">
                    <p style="color:#999; padding:20px;">データが集計されていません。</p>
                </c:if>
                <c:forEach var="item" items="${result.ranking}" varStatus="st">
                    <div class="rank-card">
                        <!-- ここを統一しました -->
                        <div class="rank-badge">${st.count}</div>
                        <img src="${pageContext.request.contextPath}/image/product/${item.image}" class="food-img" alt="商品画像">
                        <div class="food-name">${item.productName}</div>
                        <div class="food-count">注文数: ${item.count}</div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</body>
</html>