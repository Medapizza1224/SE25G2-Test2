<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

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
        /* レイアウト基本設定 */
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; height: 100vh; display: flex; flex-direction: column; color: #333; }
        a { text-decoration: none; }
        
        /* ヘッダー */
        .header { padding: 15px 20px; background: #333; color: #fff; display: flex; justify-content: space-between; align-items: center; flex-shrink: 0; /* 縮小させない */ }
        .header-title { font-size: 18px; font-weight: bold; }
        .table-no { background: #FF6900; padding: 5px 10px; border-radius: 4px; font-weight: bold; }

        /* コンテナ（左右分割） */
        .container { display: flex; flex: 1; overflow: hidden; /* 全体スクロールを禁止 */ }

        /* --- 左側：商品エリア --- */
        .main-area { flex: 3; display: flex; flex-direction: column; background: #f4f4f4; border-right: 1px solid #ddd; min-width: 0; /* Flexboxのはみ出し防止 */ }
        
        /* カテゴリバー */
        .category-bar { padding: 10px; background: #fff; display: flex; gap: 10px; overflow-x: auto; border-bottom: 1px solid #ddd; flex-shrink: 0; /* 縮小させない */ }
        .cat-btn { padding: 12px 25px; background: #eee; color: #333; border-radius: 30px; font-weight: bold; white-space: nowrap; transition: 0.3s; }
        .cat-btn.active { background: #FF6900; color: #fff; box-shadow: 0 2px 5px rgba(255, 105, 0, 0.3); }

        /* --- 商品グリッド（ここを修正） --- */
        .product-grid { 
            padding: 20px; 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); 
            gap: 20px; 
            
            /* ▼▼▼ 追加・変更した部分 ▼▼▼ */
            overflow-y: auto;   /* 縦スクロールを許可 */
            flex: 1;            /* 親の余白を埋める */
            min-height: 0;      /* コンテンツが多くても親を突き破らないようにする */
            align-content: start; /* 商品が少ない時に上詰めで表示 */
            /* ▲▲▲ 追加・変更した部分 ▲▲▲ */
        }

        .product-card { background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); cursor: pointer; transition: transform 0.2s; height: fit-content; }
        .product-card:active { transform: scale(0.98); }
        .p-img { width: 100%; height: 140px; object-fit: cover; background: #ddd; }
        .p-info { padding: 15px; }
        .p-name { font-weight: bold; font-size: 16px; margin-bottom: 8px; }
        .p-price { color: #FF6900; font-weight: bold; font-size: 15px; }

        /* --- 右側：カートサイドバー --- */
        .sidebar { flex: 1; min-width: 320px; max-width: 400px; background: #fff; display: flex; flex-direction: column; box-shadow: -2px 0 10px rgba(0,0,0,0.05); z-index: 10; }
        .cart-header { padding: 20px; border-bottom: 1px solid #eee; font-weight: bold; font-size: 18px; display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
        
        /* カートリスト */
        .cart-list { flex: 1; overflow-y: auto; padding: 10px; min-height: 0; /* 追加推奨 */ }
        .cart-item { display: flex; gap: 10px; padding: 15px; border-bottom: 1px solid #f9f9f9; align-items: center; }
        .c-img { width: 60px; height: 60px; object-fit: cover; border-radius: 8px; background: #eee; }
        .c-details { flex: 1; }
        .c-name { font-weight: bold; font-size: 14px; margin-bottom: 4px; }
        .c-meta { font-size: 12px; color: #666; }
        .c-price { font-weight: bold; color: #333; margin-top: 4px; }
        .del-btn { background: #eee; border: none; width: 30px; height: 30px; border-radius: 50%; color: #666; cursor: pointer; font-size: 16px; display: flex; justify-content: center; align-items: center; }

        /* カートフッター（集計・ボタン） */
        .cart-footer { padding: 20px; background: #fff; border-top: 1px solid #eee; flex-shrink: 0; }
        .total-row { display: flex; justify-content: space-between; font-size: 20px; font-weight: bold; margin-bottom: 20px; }
        .order-btn { display: block; width: 100%; padding: 18px; background: #FF6900; color: #fff; border: none; border-radius: 12px; font-size: 18px; font-weight: bold; cursor: pointer; text-align: center; box-shadow: 0 4px 10px rgba(255, 105, 0, 0.3); }
        .order-btn:disabled { background: #ccc; box-shadow: none; cursor: not-allowed; }

        .sub-menu { display: flex; gap: 10px; margin-top: 15px; }
        .sub-btn { flex: 1; padding: 12px; background: #333; color: #fff; border-radius: 8px; text-align: center; font-size: 14px; font-weight: bold; }
    </style>
</head>
<body>
    <!-- ヘッダー -->
    <div class="header">
        <div class="header-title">🐄 焼肉〇〇 注文端末</div>
        <div class="table-no">卓番: ${sessionScope.tableNumber}</div>
    </div>

    <div class="container">
        <!-- 左：商品エリア -->
        <div class="main-area">
            <!-- カテゴリ -->
            <div class="category-bar">
                <c:set var="curr" value="${menuResult.currentCategory}" />
                <a href="OrderHome?category=肉" class="cat-btn ${curr == '肉' ? 'active' : ''}">🍖 肉</a>
                <a href="OrderHome?category=ホルモン" class="cat-btn ${curr == 'ホルモン' ? 'active' : ''}">🥩 ホルモン</a>
                <a href="OrderHome?category=サイド" class="cat-btn ${curr == 'サイド' ? 'active' : ''}">🥗 サイド</a>
                <a href="OrderHome?category=ドリンク" class="cat-btn ${curr == 'ドリンク' ? 'active' : ''}">🍺 ドリンク</a>
            </div>

            <!-- 商品リスト -->
            <div class="product-grid">
                <c:if test="${empty menuResult.productList}">
                    <p style="padding:20px;">このカテゴリの商品は現在ありません。</p>
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
            <div class="cart-header">🛒 注文カゴ</div>
            
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
                    <a href="${pageContext.request.contextPath}/OrderHistory" class="sub-btn">📜 履歴</a>
                    <a href="${pageContext.request.contextPath}/ShowQr" class="sub-btn">💳 会計</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>