<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="util.AppConfig" %>
<%
    // ★設定を読み込み
    AppConfig conf = AppConfig.load(application);
    request.setAttribute("conf", conf);
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>テーブル設定</title>
    <style>
        /* ★テーマカラー定義 */
        :root {
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }

        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; background-color: #f5f5f5; color: #333; }
        .header { background: #333; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; }
        .header h1 { margin: 0; font-size: 20px; }
        .logout-btn { color: #fff; text-decoration: none; font-weight: bold; border: 1px solid #fff; padding: 5px 15px; border-radius: 20px; }
        
        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; display: flex; flex-direction: column; gap: 40px; }
        
        .card { background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        /* 左のアクセント線をテーマカラーに変更 */
        .card-title { font-size: 20px; font-weight: bold; border-left: 5px solid var(--main-color); padding-left: 15px; margin-bottom: 25px; }

        .new-form { display: flex; gap: 15px; align-items: flex-start; }
        .input-wrapper { flex: 1; display: flex; flex-direction: column; }
        .input-box { padding: 15px; font-size: 18px; border: 2px solid #ddd; border-radius: 8px; font-weight: bold; width: 100%; box-sizing: border-box; }
        
        /* 黒ボタンはそのまま維持 */
        .start-btn { background: #000; color: white; border: none; padding: 15px 40px; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; height: 56px; }
        .start-btn:hover { opacity: 0.8; }

        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 15px; background: #f9f9f9; color: #666; font-size: 14px; border-bottom: 2px solid #eee; }
        td { padding: 15px; border-bottom: 1px solid #eee; vertical-align: middle; }
        .table-no { font-size: 24px; font-weight: bold; color: #333; }
        /* 復旧ボタンをテーマカラーに変更 */
        .recover-btn { background: var(--main-color); color: white; border: none; padding: 10px 20px; border-radius: 30px; font-weight: bold; cursor: pointer; }

        .error-text {
            color: #FF0000; font-size: 14px; font-weight: bold; margin-top: 8px; 
            display: flex; align-items: center; gap: 5px;
        }
        .error-icon { width: 16px; height: 16px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>注文端末：設定</h1>
        <a href="Order" class="logout-btn">ログアウト</a>
    </div>

    <div class="container">
        <!-- 1. 新規テーブル設定 -->
        <div class="card">
            <div class="card-title">新規テーブル設定</div>
            <form action="OrderSetup" method="post" class="new-form">
                <input type="hidden" name="action" value="new">
                
                <div class="input-wrapper">
                    <input type="text" name="tableNumber" class="input-box" placeholder="テーブル番号 (例: 0001)" required pattern="\d{4}" maxlength="4">
                    
                    <c:if test="${not empty error}">
                        <div class="error-text">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg" class="error-icon" alt="!">
                            <span>${error}</span>
                        </div>
                    </c:if>
                </div>

                <button type="submit" class="start-btn">開始する</button>
            </form>
        </div>

        <!-- 2. 稼働中テーブル一覧 (復旧) -->
        <div class="card">
            <div class="card-title">稼働中テーブル (復旧)</div>
            <c:if test="${not empty result.activeOrders}">
                <table>
                    <thead>
                        <tr><th>テーブル</th><th>来店日時</th><th>現在の金額</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="order" items="${result.activeOrders}">
                            <tr>
                                <td><span class="table-no">${order.tableNumber}</span></td>
                                <td><fmt:formatDate value="${order.visitAt}" pattern="MM/dd HH:mm" timeZone="Asia/Tokyo" /></td>
                                <td><fmt:formatNumber value="${order.totalAmount}" /></td>
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
            <c:if test="${empty result.activeOrders}">
                <p style="color:#999; text-align:center; padding:20px;">現在稼働中のテーブルはありません。</p>
            </c:if>
        </div>
    </div>
</body>
</html>