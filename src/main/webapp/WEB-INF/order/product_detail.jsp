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
    <title>注文端末：数量</title>
    <style>
        body { 
            margin: 0; 
            background: #fafafa; 
            height: 100vh; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            font-family: "Helvetica Neue", Arial, sans-serif; 
            color: #333;
            position: relative;
        }
        
        /* 左上の店舗名 */
        .page-header {
            position: absolute;
            top: 50px;
            left: 50px;
            display: flex;
            align-items: center;
            gap: 15px;
            font-weight: bold;
            font-size: 24px;
            color: #333;
        }
        
        /* カード本体: サイズを大きく */
        .modal-card { 
            background: #fff; 
            width: 960px; /* 幅を広げる */
            max-width: 95%; 
            height: 480px; /* 高さを広げる */
            display: flex; 
            border-radius: 24px; 
            overflow: hidden; 
            border: 1px solid #eee;
            box-shadow: 0 15px 40px rgba(0,0,0,0.08); 
        }
        
        /* 画像エリア: 左半分 (1:1) */
        .img-area { 
            flex: 0 0 50%; 
            position: relative;
            background: #f0f0f0;
            overflow: hidden;
        }
        
        .img-area img { 
            width: 100%; 
            height: 100%; 
            object-fit: cover; 
            display: block;
        }
        
        /* 情報・操作エリア: 右半分 */
        .info-area { 
            flex: 1; 
            padding: 50px 60px; 
            display: flex; 
            flex-direction: column; 
            justify-content: center; 
            position: relative;
            box-sizing: border-box;
        }
        
        /* 閉じるボタン */
        .close-btn { 
            position: absolute; 
            top: 25px; 
            right: 30px; 
            text-decoration: none; 
            color: #ccc; 
            font-size: 36px; 
            line-height: 1;
            font-weight: bold;
            transition: color 0.2s;
        }
        .close-btn:hover { color: #999; }
        
        .p-title { 
            font-size: 32px; 
            font-weight: bold; 
            margin-bottom: 15px; 
            color: #333; 
            line-height: 1.3;
        }
        .p-price { 
            font-size: 28px; 
            color: #FF6900; 
            font-weight: bold; 
            margin-bottom: 40px;
        }
        
        /* 数量選択エリア: 中央揃えで対称に */
        .counter-container {
            display: flex;
            align-items: center;
            justify-content: center; /* 中央寄せ */
            gap: 40px; /* 間隔を広めに */
            margin-bottom: 40px;
        }
        
        .count-btn { 
            width: 60px; 
            height: 60px; 
            border-radius: 50%; 
            border: 2px solid #ddd; 
            background: #fff; 
            font-size: 28px; 
            cursor: pointer; 
            color: #555; 
            display: flex; 
            align-items: center; 
            justify-content: center;
            transition: 0.2s;
            padding: 0;
            padding-bottom: 4px; /* 記号の垂直位置微調整 */
        }
        .count-btn:active { background: #f0f0f0; border-color: #bbb; }
        
        .count-val { 
            font-size: 48px; 
            font-weight: bold; 
            min-width: 60px; 
            text-align: center; 
        }
        
        .add-cart-btn { 
            width: 100%; 
            padding: 20px; 
            background: #FF6900; 
            color: white; 
            border: none; 
            border-radius: 40px; 
            font-size: 20px; 
            font-weight: bold; 
            cursor: pointer; 
            transition: 0.2s; 
            box-shadow: 0 6px 15px rgba(255, 105, 0, 0.3); 
        }
        .add-cart-btn:active { transform: scale(0.98); }
    </style>
</head>
<body>

    <div class="modal-card">
        <div class="img-area">
            <img src="${pageContext.request.contextPath}/image/product/${product.image}" alt="商品画像" onerror="this.style.display='none'">
        </div>
        
        <div class="info-area">
            <a href="${pageContext.request.contextPath}/OrderHome" class="close-btn">×</a>
            
            <div>
                <div class="p-title">${product.productName}</div>
                <div class="p-price">¥ <fmt:formatNumber value="${product.price}" /></div>
            </div>

            <form action="${pageContext.request.contextPath}/OrderCart" method="post">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="productId" value="${product.productId}">
                
                <div class="counter-container">
                    <button type="button" class="count-btn" onclick="updateCount(-1)">－</button>
                    <span id="displayCount" class="count-val">1</span>
                    <button type="button" class="count-btn" onclick="updateCount(1)">＋</button>
                </div>
                
                <input type="hidden" id="quantityInput" name="quantity" value="1">
                
                <button type="submit" class="add-cart-btn">カゴに追加する</button>
            </form>
        </div>
    </div>

    <script>
        let count = 1;
        const max = 10;
        const min = 1;

        function updateCount(diff) {
            count += diff;
            if (count < min) count = min;
            if (count > max) count = max;
            
            document.getElementById('displayCount').innerText = count;
            document.getElementById('quantityInput').value = count;
        }
    </script>
</body>
</html>