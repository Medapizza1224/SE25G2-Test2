<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="util.AppConfig" %>
<%
    AppConfig conf = AppConfig.load(application);
    request.setAttribute("conf", conf);
%>

<c:if test="${empty sessionScope.tableNumber}">
    <c:redirect url="/Order" />
</c:if>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注文メニュー</title>
    <style>
            :root {
                --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
            }

            body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; height: 100vh; display: flex; flex-direction: column; color: #333; }
            a { text-decoration: none; }
            
            .header { padding: 0 20px; background: #333; color: #fff; display: flex; justify-content: space-between; align-items: center; flex-shrink: 0; height: 60px; }
            .header-title { font-size: 18px; font-weight: bold; display: flex; align-items: center; gap: 10px; }
            .logo-invert { filter: invert(1); height: 24px; }
            .table-no { background: var(--main-color); padding: 5px 10px; border-radius: 4px; font-weight: bold; }

            .container { display: flex; flex: 1; overflow: hidden; }

            .main-area { flex: 1; display: flex; flex-direction: column; background: #f4f4f4; border-right: 1px solid #ddd; min-width: 0; }
            
            .category-bar { padding: 10px; background: #fff; display: flex; gap: 10px; overflow-x: auto; border-bottom: 1px solid #ddd; flex-shrink: 0; }
            .cat-btn { padding: 10px 20px; background: #eee; color: #333; border-radius: 30px; font-weight: bold; white-space: nowrap; font-size: 14px; display: flex; align-items: center; gap: 5px; }
            .cat-btn.active { background: var(--main-color); color: #fff; }
            .cat-icon { width: 18px; height: 18px; object-fit: contain; }

            /* --- 修正ポイント：横4列固定 ＋ 縦方向の重なりを解消 --- */
            .product-grid { 
                padding: 20px; 
                display: grid; 
                /* PCでは常に横4列に固定 (1fr × 4) */
                grid-template-columns: repeat(4, 1fr); 
                /* ★重要：行の高さを「中身の最大値」に自動合わせすることで重なりを防止 */
                grid-auto-rows: min-content; 
                gap: 20px; 
                overflow-y: auto; 
                flex: 1; 
                min-height: 0; 
                align-content: start;
            }

            .product-card { 
                background: #fff; border-radius: 12px; overflow: hidden; 
                box-shadow: 0 2px 8px rgba(0,0,0,0.08); cursor: pointer; 
                display: flex; flex-direction: column;
                /* ★重要：高さを固定せず、中身に合わせて伸びるようにする */
                height: 100%; 
            }

            .p-img { 
                width: 100%; 
                aspect-ratio: 4 / 3; 
                object-fit: cover; 
                background: #ddd; 
                display: block;
                flex-shrink: 0;
            }

            .p-info { 
                padding: 15px; 
                flex-grow: 1; 
                display: flex; 
                flex-direction: column;
            }

            /* ★重要：商品名が長すぎても重ならないよう制限をかける（2行まで） */
            .p-name { 
                font-weight: bold; 
                font-size: 16px; 
                line-height: 1.4; 
                margin-bottom: 8px;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
                word-break: break-all;
            }

            .p-price { 
                color: var(--main-color); 
                font-weight: bold; 
                font-size: 16px; 
                margin-top: auto; /* 価格を常にカードの下端に寄せる */
            }

            /* サイドバー幅を安定させる */
            .sidebar { width: 380px; flex-shrink: 0; background: #fff; display: flex; flex-direction: column; box-shadow: -2px 0 10px rgba(0,0,0,0.05); z-index: 10; }
            .cart-header { padding: 20px; border-bottom: 1px solid #eee; font-weight: bold; font-size: 18px; display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
            .cart-list { flex: 1; overflow-y: auto; padding: 10px; min-height: 0; }
            .cart-item { display: flex; gap: 10px; padding: 12px; border-bottom: 1px solid #f9f9f9; align-items: center; }
            .c-img { width: 50px; height: 50px; object-fit: cover; border-radius: 6px; }
            .cart-footer { padding: 20px; background: #fff; border-top: 1px solid #eee; flex-shrink: 0; }
            .total-row { display: flex; justify-content: space-between; font-size: 20px; font-weight: bold; margin-bottom: 20px; }
            .order-btn { display: block; width: 100%; padding: 18px; background: var(--main-color); color: #fff; border: none; border-radius: 12px; font-size: 18px; font-weight: bold; cursor: pointer; text-align: center; }
            .sub-menu { display: flex; gap: 10px; margin-top: 15px; }
            .sub-btn { flex: 1; padding: 12px; background: #333; color: #fff; border-radius: 8px; text-align: center; font-size: 14px; font-weight: bold; display: flex; align-items: center; justify-content: center; }
        </style>
</head>
<body>
    <!-- ヘッダー -->
    <div class="header">
        <div class="header-title">
            <!-- ロゴ画像 (白黒反転クラスを追加) -->
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="ロゴ" class="logo-invert" style="height: 28px; vertical-align: middle;">
        </div>
        <div class="table-no">卓番: ${sessionScope.tableNumber}</div>
    </div>

    <div class="container">
        <!-- 左：商品エリア -->
        <div class="main-area">
            <!-- カテゴリ (動的生成) -->
            <div class="category-bar">
                <c:set var="curr" value="${menuResult.currentCategory}" />
                
                <c:if test="${empty conf.categories}">
                     <a href="OrderHome?category=肉" class="cat-btn ${curr == '肉' ? 'active' : ''}">🍖 肉</a>
                     <a href="OrderHome?category=ホルモン" class="cat-btn ${curr == 'ホルモン' ? 'active' : ''}">🥩 ホルモン</a>
                     <a href="OrderHome?category=サイド" class="cat-btn ${curr == 'サイド' ? 'active' : ''}">🥗 サイド</a>
                     <a href="OrderHome?category=ドリンク" class="cat-btn ${curr == 'ドリンク' ? 'active' : ''}">🍺 ドリンク</a>
                </c:if>

                <c:forEach var="cat" items="${conf.categories}">
                    <a href="OrderHome?category=${fn:escapeXml(cat.name)}" class="cat-btn ${curr == cat.name ? 'active' : ''}">
                        <c:if test="${not empty cat.icon}">
                            <img src="${pageContext.request.contextPath}/image/system/${fn:escapeXml(cat.icon)}" class="cat-icon" onerror="this.style.display='none'">
                        </c:if>
                        ${fn:escapeXml(cat.name)}
                    </a>
                </c:forEach>
            </div>

            <!-- 商品リスト -->
            <div class="product-grid">
                <c:if test="${empty menuResult.productList}">
                    <p style="padding:12px;">このカテゴリの商品は現在ありません。</p>
                </c:if>
                
                <c:forEach var="p" items="${menuResult.productList}">
                    <div class="product-card" onclick="location.href='${pageContext.request.contextPath}/ProductDetail?id=${p.productId}'">
                        <img src="${pageContext.request.contextPath}/image/product/${p.image}" class="p-img" alt="商品画像" onerror="this.src='https://placehold.jp/150x100.png?text=NoImage'">
                        <div class="p-info">
                            <div class="p-name">${p.productName}</div>
                            <div class="p-price">¥ <fmt:formatNumber value="${p.price}" /></div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- 右：カートサイドバー -->
        <div class="sidebar">
            <div class="cart-header">
                <!-- 注文カゴアイコン -->
                <img src="${pageContext.request.contextPath}/image/system/注文カゴ.svg" class="sys-icon">
                注文カゴ
            </div>
            
            <div class="cart-list">
                <c:if test="${empty sessionScope.cart.items}">
                    <div style="text-align:center; color:#999; margin-top:50px;">
                        商品をタップして<br>追加してください
                    </div>
                </c:if>

                <c:forEach var="item" items="${sessionScope.cart.items}">
                    <div class="cart-item">
                        <img src="${pageContext.request.contextPath}/image/product/${item.product.image}" class="c-img" onerror="this.style.display='none'">
                        <div class="c-details">
                            <div class="c-name">${item.product.productName}</div>
                            <div class="c-meta">¥${item.product.price} × ${item.quantity}</div>
                            <div class="c-price">¥ <fmt:formatNumber value="${item.subTotal}" /></div>
                        </div>
                        <form action="${pageContext.request.contextPath}/OrderCart" method="post">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="productId" value="${item.product.productId}">
                            <button type="submit" class="del-btn">×</button>
                        </form>
                    </div>
                </c:forEach>
            </div>

            <div class="cart-footer">
                <div class="total-row">
                    <span>合計</span>
                    <span>¥ <fmt:formatNumber value="${sessionScope.cart.totalAmount}" /></span>
                </div>

                <form action="${pageContext.request.contextPath}/OrderSubmit" method="post">
                    <button type="submit" class="order-btn" ${empty sessionScope.cart.items ? 'disabled' : ''}>
                        注文を確定する
                    </button>
                </form>

                <div class="sub-menu">
                    <a href="${pageContext.request.contextPath}/OrderHistory" class="sub-btn">
                        <!-- 履歴アイコン -->
                        <img src="${pageContext.request.contextPath}/image/system/履歴.svg" class="sys-icon-white">
                        履歴
                    </a>
                    <a href="${pageContext.request.contextPath}/PaymentSelect" class="sub-btn">
                        <!-- 会計アイコン -->
                        <img src="${pageContext.request.contextPath}/image/system/会計.svg" class="sys-icon-white">
                        会計
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>