<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>テーブル設定</title>
    <style>
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; background-color: #f5f5f5; color: #333; }
        .header { background: #333; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; }
        .header h1 { margin: 0; font-size: 20px; }
        .logout-btn { color: #fff; text-decoration: none; font-weight: bold; border: 1px solid #fff; padding: 5px 15px; border-radius: 20px; }
        
        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; display: flex; flex-direction: column; gap: 40px; }
        
        /* カード共通 */
        .card { background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .card-title { font-size: 20px; font-weight: bold; border-left: 5px solid #FF6900; padding-left: 15px; margin-bottom: 25px; }

        /* 新規作成フォーム */
        .new-form { display: flex; gap: 15px; align-items: center; }
        .input-box { flex: 1; padding: 15px; font-size: 18px; border: 2px solid #ddd; border-radius: 8px; font-weight: bold; }
        .start-btn { background: #000; color: white; border: none; padding: 15px 40px; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; }
        .start-btn:hover { opacity: 0.8; }

        /* 復旧リスト */
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 15px; background: #f9f9f9; color: #666; font-size: 14px; border-bottom: 2px solid #eee; }
        td { padding: 15px; border-bottom: 1px solid #eee; vertical-align: middle; }
        
        .table-no { font-size: 24px; font-weight: bold; color: #333; }
        .time-info { color: #666; font-size: 14px; }
        
        .recover-btn { background: #FF6900; color: white; border: none; padding: 10px 20px; border-radius: 30px; font-weight: bold; cursor: pointer; }
        .recover-btn:hover { opacity: 0.8; }

        .error-msg { background: #ffe0e0; color: #d00; padding: 15px; border-radius: 8px; font-weight: bold; text-align: center; }
    </style>
</head>
<body>
    <div class="header">
        <h1>注文端末セットアップ</h1>
        <a href="Order" class="logout-btn">ログアウト</a>
    </div>

    <div class="container">
        
        <c:if test="${not empty error}">
            <div class="error-msg">⚠️ ${error}</div>
        </c:if>

        <!-- 1. 新規テーブル設定 -->
        <div class="card">
            <div class="card-title">新規テーブル設定</div>
            <form action="OrderSetup" method="post" class="new-form">
                <input type="hidden" name="action" value="new">
                <input type="text" name="tableNumber" class="input-box" placeholder="テーブル番号 (例: 0001)" required pattern="\d{4}" maxlength="4">
                <button type="submit" class="start-btn">開始する</button>
            </form>
        </div>

        <!-- 2. 稼働中テーブル一覧 (復旧) -->
        <div class="card">
            <div class="card-title">稼働中テーブル (復旧)</div>
            
            <c:if test="${empty result.activeOrders}">
                <p style="color:#999; text-align:center; padding:20px;">現在稼働中のテーブルはありません。</p>
            </c:if>

            <c:if test="${not empty result.activeOrders}">
                <table>
                    <thead>
                        <tr>
                            <th>テーブル</th>
                            <th>来店日時</th>
                            <th>現在の金額</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="order" items="${result.activeOrders}">
                            <tr>
                                <td><span class="table-no">${order.tableNumber}</span></td>
                                <td>
                                    <span class="time-info">
                                        <fmt:formatDate value="${order.visitAt}" pattern="MM/dd HH:mm" timeZone="Asia/Tokyo" />
                                    </span>
                                </td>
                                <td>
                                    <!-- 合計金額が表示されていれば分かりやすい -->
                                    <%-- DAOのfindActiveOrdersでは計算していない場合は0になる可能性があります --%>
                                    <%-- 必要ならDAOで計算するか、ここでは表示しない --%>
                                    <c:choose>
                                        <c:when test="${order.totalAmount > 0}">
                                            ¥ <fmt:formatNumber value="${order.totalAmount}" />
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align:right;">
                                    <form action="OrderSetup" method="post">
                                        <input type="hidden" name="action" value="recover">
                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                        <button type="submit" class="recover-btn">復旧して再開</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>

    </div>
</body>
</html>