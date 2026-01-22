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
    <title>注文端末：履歴</title>
    <style>
        :root {
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        body { margin: 0; padding: 0; font-family: sans-serif; background: #f5f5f5; color: #333; }
        
        .container { max-width: 800px; margin: 40px auto; background: #fff; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); padding: 30px; }
        
        /* ボーダー色変更 */
        .header-area { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid var(--main-color); padding-bottom: 15px; }
        h1 { margin: 0; font-size: 24px; }
        .back-btn { background: #333; color: #fff; padding: 10px 20px; border-radius: 30px; text-decoration: none; font-weight: bold; font-size: 14px; }

        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; color: #888; padding: 10px; font-size: 14px; border-bottom: 1px solid #eee; }
        td { padding: 15px 10px; border-bottom: 1px solid #f0f0f0; font-size: 16px; }
        
        .status-badge { padding: 5px 10px; border-radius: 4px; font-size: 12px; font-weight: bold; color: #fff; background: #ccc; }
        /* 調理中バッジ色変更 */
        .status-cooking { background: var(--main-color); } 
        .status-served { background: #4CAF50; } 

        .total-area { margin-top: 30px; text-align: right; }
        .total-label { font-size: 16px; color: #666; margin-right: 15px; }
        .total-val { font-size: 32px; font-weight: bold; color: #333; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header-area">
            <h1>📜 注文履歴</h1>
            <a href="OrderHome" class="back-btn">メニューに戻る</a>
        </div>

        <table>
            <thead>
                <tr>
                    <th>状態</th>
                    <th>商品ID / 商品名</th>
                    <th style="text-align:center;">数量</th>
                    <th style="text-align:right;">小計</th>
                </tr>
            </thead>
            <tbody>
                <c:if test="${empty historyResult.historyList}">
                    <tr><td colspan="4" style="text-align:center; padding:30px;">まだ注文がありません。</td></tr>
                </c:if>

                <c:forEach var="item" items="${historyResult.historyList}">
                    <tr>
                        <td>
                            <c:choose>
                                <c:when test="${item.orderStatus == '調理中'}">
                                    <span class="status-badge status-cooking">調理中</span>
                                </c:when>
                                <c:when test="${item.orderStatus == '提供済'}">
                                    <span class="status-badge status-served">提供済</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge">${item.orderStatus}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div style="font-weight:bold;">${item.productId}</div>
                            <c:if test="${not empty item.productName}">
                                <div style="font-size:14px; color:#666;">${item.productName}</div>
                            </c:if>
                        </td>
                        <td style="text-align:center;">${item.quantity}</td>
                        <td style="text-align:right; font-weight:bold;">
                            ¥ <fmt:formatNumber value="${item.price * item.quantity}" />
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div class="total-area">
            <span class="total-label">合計金額 (注文済)</span>
            <span class="total-val">¥ <fmt:formatNumber value="${historyResult.totalAmount}" /></span>
        </div>
    </div>
</body>
</html>