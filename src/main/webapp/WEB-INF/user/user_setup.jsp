<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>セットアップ完了</title>
    <style>
        body { font-family: -apple-system, sans-serif; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 500px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #FF6900; padding-bottom: 10px; font-size: 20px; }
        
        .info-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .info-table th { text-align: left; padding: 10px; color: #666; font-size: 14px; border-bottom: 1px solid #eee; }
        .info-table td { text-align: right; padding: 10px; font-weight: bold; font-size: 16px; border-bottom: 1px solid #eee; }
        
        .highlight { color: #e74c3c; font-size: 18px; }

        .btn { 
            display: block; width: 100%; text-align: center; background-color: #FF6900; color: white; 
            padding: 15px 0; text-decoration: none; border-radius: 30px; font-weight: bold; 
            margin-top: 25px; box-shadow: 0 4px 6px rgba(255, 105, 0, 0.2);
            transition: opacity 0.3s;
        }
        .btn:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="container">
        <h1>✅ データ生成完了</h1>
        <p style="font-size:14px; color:#555;">以下のランダムデータでログインしました。</p>

        <table class="info-table">
            <tr>
                <th>ユーザー名</th>
                <!-- result -> setup -> user -> userName -->
                <td>${result.setup.user.userName}</td>
            </tr>
            <tr>
                <th>セキュリティコード</th>
                <!-- result -> setup -> rawSecurityCode -->
                <td class="highlight">${result.setup.rawSecurityCode}</td>
            </tr>
            <tr>
                <th>所持金</th>
                <td>¥ <fmt:formatNumber value="${result.setup.user.balance}" /></td>
            </tr>
            <tr>
                <th>ポイント</th>
                <td><fmt:formatNumber value="${result.setup.user.point}" /> pt</td>
            </tr>
            <tr>
                <th>今回の請求額</th>
                <td>¥ <fmt:formatNumber value="${result.setup.order.totalAmount}" /></td>
            </tr>
        </table>

        <!-- result -> setup -> order -> orderId -->
        <a href="${pageContext.request.contextPath}/UserPayment?orderId=${result.setup.order.orderId}" class="btn">
            決済画面へ進む
        </a>
    </div>
</body>
</html>