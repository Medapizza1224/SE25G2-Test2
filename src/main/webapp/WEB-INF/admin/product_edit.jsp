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

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>商品編集</title>
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

        /* 編集フォーム固有 */
        .form-card { background: white; padding: 40px; border-radius: 12px; max-width: 800px; margin: 0 auto; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .form-row { display: flex; margin-bottom: 25px; align-items: center; border-bottom: 1px solid #f5f5f5; padding-bottom: 25px; }
        .label { width: 180px; font-weight: bold; color: #666; font-size: 14px; }
        .input-area { flex: 1; }
        input[type="text"], input[type="number"] { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 16px; box-sizing: border-box; }
        input:focus { border-color: var(--main-color); outline: none; }
        .readonly { background: #f9f9f9; border: none; font-weight: bold; color: #333; }
        .preview-img { width: 120px; height: 80px; object-fit: cover; border-radius: 6px; margin-right: 15px; border: 1px solid #ddd; }
        
        .radio-group { display: flex; gap: 20px; }
        .radio-label { display: flex; align-items: center; gap: 5px; cursor: pointer; }
        .tag { padding: 4px 10px; border-radius: 20px; font-size: 12px; color: white; font-weight: bold; }
        .tag-ok { background: #00A0E9; }
        .tag-ng { background: #ccc; }

        .submit-area { text-align: center; margin-top: 40px; }
        .submit-btn { width: 250px; padding: 15px; background: var(--main-color); color: white; border: none; border-radius: 30px; font-size: 18px; font-weight: bold; cursor: pointer; transition: 0.2s; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .submit-btn:hover { opacity: 0.9; }
        .error-msg { background: #ffe0e0; color: #d00; padding: 10px; border-radius: 4px; margin-bottom: 20px; }
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
            <div class="page-title">
                <c:choose>
                    <c:when test="${result.mode == 'insert'}">商品新規登録</c:when>
                    <c:otherwise>商品編集</c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="form-card">
            <c:if test="${not empty error}">
                <div class="error-msg">⚠️ ${error}</div>
            </c:if>

            <form action="AdminProductEdit" method="post" enctype="multipart/form-data">
                <input type="hidden" name="mode" value="${result.mode}">
                <input type="hidden" name="currentImage" value="${result.product.image}">

                <div class="form-row">
                    <div class="label">商品ID</div>
                    <div class="input-area">
                        <c:choose>
                            <c:when test="${result.mode == 'update'}">
                                <input type="text" name="productId" value="${result.product.productId}" class="readonly" readonly>
                            </c:when>
                            <c:otherwise>
                                <input type="text" name="productId" value="" placeholder="例: BEEF001" required>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="form-row">
                    <div class="label">商品画像</div>
                    <div class="input-area" style="display:flex; align-items:center;">
                        <c:if test="${not empty result.product.image}">
                            <img src="${pageContext.request.contextPath}/image/product/${result.product.image}" class="preview-img">
                        </c:if>
                        <input type="file" name="imageFile" accept="image/*">
                    </div>
                </div>

                <div class="form-row">
                    <div class="label">商品名</div>
                    <div class="input-area">
                        <input type="text" name="productName" value="${result.product.productName}" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="label">カテゴリ</div>
                    <div class="input-area">
                        <input type="text" name="category" value="${result.product.category}" list="catList">
                        <datalist id="catList">
                            <c:forEach var="c" items="${conf.categories}">
                                <option value="${c.name}">
                            </c:forEach>
                        </datalist>
                    </div>
                </div>

                <div class="form-row">
                    <div class="label">価格 (円)</div>
                    <div class="input-area">
                        <input type="number" name="price" value="${result.product.price}" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="label">販売状況</div>
                    <div class="input-area radio-group">
                        <label class="radio-label">
                            <input type="radio" name="salesStatus" value="販売中" ${result.product.salesStatus == '販売中' || result.mode == 'insert' ? 'checked' : ''}>
                            <span class="tag tag-ok">販売中</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="salesStatus" value="準備中" ${result.product.salesStatus == '準備中' ? 'checked' : ''}>
                            <span class="tag tag-ng">準備中</span>
                        </label>
                    </div>
                </div>

                <div class="submit-area">
                    <button type="submit" class="submit-btn">
                        ${result.mode == 'insert' ? '登録する' : '更新する'}
                    </button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>