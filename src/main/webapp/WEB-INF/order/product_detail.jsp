<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>数量選択</title>
    <style>
        body { margin: 0; background: rgba(0,0,0,0.8); height: 100vh; display: flex; justify-content: center; align-items: center; font-family: sans-serif; }
        .modal-card { background: #fff; width: 90%; max-width: 800px; height: 500px; display: flex; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .img-area { flex: 1; background: #333; }
        .img-area img { width: 100%; height: 100%; object-fit: cover; }
        .info-area { flex: 1; padding: 40px; display: flex; flex-direction: column; justify-content: space-between; position: relative; }
        .close-btn { position: absolute; top: 20px; right: 20px; text-decoration: none; color: #999; font-size: 24px; font-weight: bold; width: 40px; height: 40px; background: #f0f0f0; border-radius: 50%; display: flex; justify-content: center; align-items: center; }
        .p-title { font-size: 32px; font-weight: bold; margin-bottom: 10px; color: #333; }
        .p-price { font-size: 24px; color: #FF6900; font-weight: bold; }
        .counter-box { display: flex; align-items: center; justify-content: center; gap: 30px; margin: 20px 0; }
        .count-btn { width: 60px; height: 60px; border-radius: 50%; border: none; background: #eee; font-size: 30px; cursor: pointer; color: #333; transition: 0.2s; }
        .count-btn:active { background: #ccc; }
        .count-val { font-size: 48px; font-weight: bold; width: 80px; text-align: center; }
        .add-cart-btn { width: 100%; padding: 20px; background: #FF6900; color: white; border: none; border-radius: 50px; font-size: 20px; font-weight: bold; cursor: pointer; transition: 0.2s; box-shadow: 0 4px 10px rgba(255, 105, 0, 0.4); }
        .add-cart-btn:active { transform: scale(0.98); }
    </style>
</head>
<body>
    <div class="modal-card">
        <div class="img-area">
            <!-- ★修正: 画像パス -->
            <img src="${pageContext.request.contextPath}/image/product/${product.image}" alt="商品画像" onerror="this.style.display='none'">
        </div>
        
        <div class="info-area">
            <!-- ★修正: 戻る先を OrderHome に -->
            <a href="${pageContext.request.contextPath}/OrderHome" class="close-btn">×</a>
            
            <div>
                <div class="p-title">${product.productName}</div>
                <div class="p-price">¥ ${product.price}</div>
            </div>

            <!-- ★修正: action先を OrderCart に -->
            <form action="${pageContext.request.contextPath}/OrderCart" method="post">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="productId" value="${product.productId}">
                
                <div class="counter-box">
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