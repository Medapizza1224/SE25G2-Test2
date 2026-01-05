<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>]

<c:if test="${empty sessionScope.adminNameManagement}">
    <c:redirect url="/AdminLogin" />
</c:if>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>ユーザー管理</title>
    <style>
        /* レイアウトのスタイル */
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; display: flex; height: 100vh; background-color: #f5f5f5; color: #333; }
        a { text-decoration: none; }
        .sidebar { width: 240px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; }
        .brand { font-size: 20px; font-weight: bold; padding: 0 25px 30px; display: flex; align-items: center; gap: 10px; }
        .sidebar-item { display: flex; align-items: center; padding: 15px 25px; color: #666; font-weight: bold; font-size: 16px; transition: 0.2s; }
        .sidebar-item:hover { background-color: #f9f9f9; color: #333; }
        .sidebar-item.active { background-color: #fff5f0; color: #FF6900; border-right: 4px solid #FF6900; }
        .icon { width: 30px; text-align: center; margin-right: 10px; font-size: 20px; }
        .content { flex: 1; padding: 40px; overflow-y: auto; }
        .page-header { border-left: 5px solid #FF6900; padding-left: 15px; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: bold; }

        /* テーブルスタイル */
        .table-container { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #fff; text-align: left; padding: 20px; border-bottom: 2px solid #ccc; font-size: 14px; font-weight: bold; color: #000; }
        td { padding: 20px; border-bottom: 1px solid #eee; vertical-align: middle; font-size: 14px; }

        /* バッジとボタンのスタイル */
        .badge-active { background-color: #00A0E9; color: white; padding: 8px 0; border-radius: 20px; font-weight: bold; font-size: 12px; display: inline-block; text-align: center; width: 100px; }
        .badge-lock { background-color: #FF0000; color: white; padding: 8px 0; border-radius: 20px; font-weight: bold; font-size: 12px; display: inline-block; text-align: center; width: 100px; }
        .btn-unlock { background-color: #000; color: white; padding: 8px 20px; border-radius: 6px; font-size: 12px; font-weight: bold; border: none; cursor: pointer; transition: 0.2s; }
        .btn-unlock:hover { opacity: 0.8; }
        .uuid-text { font-family: monospace; color: #444; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand">🐄 焼肉〇〇</div>
        <a href="AdminKitchen" class="sidebar-item"><span class="icon">🍳</span> 注文状況</a>
        <a href="AdminAnalysis" class="sidebar-item"><span class="icon">📊</span> 分析</a>
        <a href="AdminUserView" class="sidebar-item active"><span class="icon">👤</span> ユーザー</a>
        <a href="AdminProductList" class="sidebar-item"><span class="icon">🍽</span> 商品</a>
        <a href="admin-setup" class="sidebar-item"><span class="icon">あ</span> 設定</a>
        <a href="AdminLogin" class="sidebar-item" style="margin-top:auto;"><span class="icon">🚪</span> ログアウト</a>
    </div>

    <div class="content">
        <div class="page-header">
            <div class="page-title">ユーザー</div>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th style="width: 80px; padding-left: 30px;">整理番号</th>
                        <th>UUID</th>
                        <th>ユーザー名</th>
                        <th style="text-align: center;">ユーザー状況</th>
                        <th style="text-align: center;">ロックアウト</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- ★動いているコードと同じ書き方★ -->
                    <c:forEach var="dto" items="${result.list}" varStatus="status">
                        <tr>
                            <!-- 整理番号 -->
                            <td style="padding-left: 30px;">${status.count}</td>
                            
                            <!-- UUID -->
                            <td class="uuid-text"><c:out value="${dto.user.userId}" /></td>
                            
                            <!-- ユーザー名 -->
                            <td><c:out value="${dto.user.userName}" /></td>
                            
                            <!-- ユーザー状況 (画像のデザインに合わせる) -->
                            <td style="text-align: center;">
                                <%-- 動いているコードの dto.user.lockout を使用 --%>
                                <c:choose>
                                    <c:when test="${dto.user.lockout}">
                                        <span class="badge-lock">ロックアウト</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-active">アクティブ</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            
                            <!-- 操作ボタン -->
                            <td style="text-align: center;">
                                <%-- 動いているコードと同じIF条件 --%>
                                <c:if test="${dto.user.lockout}">
                                    <%-- 動いているコードと同じフォームの書き方 --%>
                                    <form action="${pageContext.request.contextPath}/AdminUserUnlock" method="post">
                                        <input type="hidden" name="userId" value="${dto.user.userId}">
                                        <button type="submit" class="btn-unlock">解除</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>