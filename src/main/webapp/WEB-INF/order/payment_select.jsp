<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
    <title>お支払い方法の選択</title>
    <style>
        :root {
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        body { 
            margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; 
            background: #f5f5f5; color: #333; height: 100vh; display: flex; flex-direction: column; 
        }
        
        /* ヘッダー */
        .header { 
            padding: 20px 40px; background: #fff; display: flex; justify-content: space-between; align-items: center; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.05); flex-shrink: 0;
        }
        .logo-area { display: flex; align-items: center; gap: 10px; font-weight: bold; font-size: 24px; }
        .logo-img { height: 35px; width: auto; }
        .back-btn { 
            background: #000; color: white; padding: 12px 40px; border-radius: 30px; 
            text-decoration: none; font-weight: bold; 
        }

        /* メインコンテンツ */
        .container { 
            flex: 1; display: flex; padding: 40px; gap: 40px; justify-content: center; overflow: hidden;
        }

        /* 左カラム：注文内容 */
        .left-col { 
            flex: 1; max-width: 500px; background: #fff; border-radius: 20px; padding: 30px; 
            display: flex; flex-direction: column; box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        .section-title { font-size: 20px; font-weight: bold; margin-bottom: 20px; }
        
        .item-list { flex: 1; overflow-y: auto; padding-right: 10px; }
        .item-row { display: flex; gap: 15px; border-bottom: 1px solid #eee; padding: 15px 0; }
        .item-img { width: 80px; height: 60px; object-fit: cover; border-radius: 8px; background: #eee; }
        .item-info { flex: 1; }
        .item-name { font-weight: bold; font-size: 16px; margin-bottom: 5px; }
        .item-meta { font-size: 12px; color: #888; }
        .item-price { font-weight: bold; color: #ff3333; font-size: 18px; text-align: right; }

        .total-area { margin-top: 20px; display: flex; justify-content: space-between; align-items: baseline; border-top: 2px solid #333; padding-top: 20px; }
        .total-label { font-size: 24px; font-weight: bold; }
        .total-val { font-size: 32px; font-weight: bold; }

        /* 右カラム：支払い方法 */
        .right-col { 
            flex: 1; max-width: 600px; background: #fff; border-radius: 20px; padding: 30px; 
            display: flex; flex-direction: column; box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        
        .payment-list { flex: 1; margin-top: 20px; }
        
        /* ラジオボタンのカスタムデザイン */
        .pay-option { display: block; margin-bottom: 15px; cursor: pointer; }
        .pay-option input { display: none; }
        
        .pay-card { 
            display: flex; align-items: center; gap: 20px; 
            padding: 20px; border: 2px solid #eee; border-radius: 50px; 
            background: #fff8e8; transition: 0.2s; 
        }
        .pay-option input:checked + .pay-card { 
            border-color: #ffcc00; 
            box-shadow: 0 0 0 2px #ffcc00; /* 強調 */
        }
        
        /* 選択マーク */
        .radio-mark { 
            width: 24px; height: 24px; border-radius: 50%; border: 3px solid #ffcc00; 
            display: flex; justify-content: center; align-items: center; 
        }
        .radio-mark::after { 
            content: ''; width: 14px; height: 14px; background: #ffcc00; border-radius: 50%; 
            display: none; 
        }
        .pay-option input:checked + .pay-card .radio-mark::after { display: block; }
        
        .pay-icon { width: 30px; height: 30px; object-fit: contain; }
        .pay-name { font-weight: bold; font-size: 20px; }

        /* 決定ボタン */
        .submit-btn { 
            display: block; width: 100%; padding: 20px; 
            background: var(--main-color); color: white; 
            border: none; border-radius: 50px; 
            font-size: 24px; font-weight: bold; cursor: pointer; 
            margin-top: 30px; box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            transition: opacity 0.2s;
        }
        .submit-btn:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo-area">
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" class="logo-img">
        </div>
        <a href="OrderHome" class="back-btn">戻る</a>
    </div>

    <div class="container">
        <!-- 左側：注文内容確認 -->
        <div class="left-col">
            <div class="section-title">ご注文内容の確認</div>
            
            <div class="item-list">
                <c:forEach var="item" items="${items}">
                    <div class="item-row">
                        <img src="${pageContext.request.contextPath}/image/product/${item.image}" class="item-img" onerror="this.src='https://placehold.jp/150x150.png?text=NoImage'">
                        <div class="item-info">
                            <div class="item-name">${item.productName}</div>
                            <div class="item-meta">
                                ¥<fmt:formatNumber value="${item.price}" /> × ${item.quantity}個
                            </div>
                            <div class="item-meta">
                                <fmt:formatDate value="${item.addOrderAt}" pattern="yyyy/MM/dd HH:mm" timeZone="Asia/Tokyo"/> に注文
                            </div>
                        </div>
                        <div class="item-price">
                            ¥<fmt:formatNumber value="${item.price * item.quantity}" />
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="total-area">
                <div class="total-label">合計金額</div>
                <div class="total-val">¥<fmt:formatNumber value="${totalAmount}" /> (税込)</div>
            </div>
        </div>

        <!-- 右側：支払い方法選択 -->
        <div class="right-col">
            <div class="section-title">お支払い方法の選択</div>
            
            <form action="ShowQr" method="get" style="flex:1; display:flex; flex-direction:column;">
                <div class="payment-list">
                    <c:forEach var="method" items="${paymentMethods}" varStatus="st">
                        <label class="pay-option">
                            <!-- 最初の一つをデフォルト選択 -->
                            <input type="radio" name="paymentMethod" value="${method.name}" ${st.first ? 'checked' : ''}>
                            <div class="pay-card">
                                <div class="radio-mark"></div>
                                <img src="${pageContext.request.contextPath}/image/system/${method.icon}" class="pay-icon" onerror="this.style.display='none'">
                                <div class="pay-name">${method.name}</div>
                            </div>
                        </label>
                    </c:forEach>
                </div>

                <button type="submit" class="submit-btn">お支払い画面へ</button>
            </form>
        </div>
    </div>
</body>
</html>