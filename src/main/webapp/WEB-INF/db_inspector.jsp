<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>DB Inspector</title>
    <style>
        /* 既存のアプリケーション(admin_style等)に近いシンプルなデザイン */
        body { 
            margin: 0; padding: 0; 
            font-family: "Helvetica Neue", Arial, sans-serif; 
            background-color: #f5f5f5; 
            color: #333; 
        }
        
        /* 独立したツール用のヘッダー */
        .header { 
            background: #fff; 
            padding: 20px 40px; 
            border-bottom: 1px solid #ddd;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .app-title { font-size: 20px; font-weight: bold; display: flex; align-items: center; gap: 10px; }
        .sub-title { color: #666; font-size: 14px; margin-left: 10px; }

        /* スクロール追従ナビゲーション */
        .sticky-nav {
            position: sticky;
            top: 0;
            background: #fff;
            padding: 10px 40px;
            border-bottom: 1px solid #ddd;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            display: flex;
            gap: 15px;
            overflow-x: auto;
            z-index: 100;
        }
        .nav-link {
            text-decoration: none;
            color: #666;
            font-weight: bold;
            font-size: 13px;
            padding: 8px 16px;
            border-radius: 20px;
            background: #f0f0f0;
            white-space: nowrap;
            transition: all 0.2s;
        }
        .nav-link:hover { background: #e0e0e0; }
        
        /* アクティブなナビゲーション */
        .nav-link.active {
            background: #FF6900;
            color: white;
            box-shadow: 0 2px 5px rgba(255, 105, 0, 0.3);
        }

        /* コンテンツエリア */
        .container { padding: 40px; max-width: 1200px; margin: 0 auto; }

        /* 各テーブルセクション */
        .section {
            background: white;
            border-radius: 8px;
            padding: 30px;
            margin-bottom: 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            scroll-margin-top: 80px; /* スクロール時の位置調整 */
        }

        .section-header {
            border-left: 5px solid #FF6900;
            padding-left: 15px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .section-title { font-size: 20px; font-weight: bold; }
        .record-count { font-size: 14px; color: #888; background: #eee; padding: 4px 10px; border-radius: 10px; }

        /* テーブルスタイル */
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th { 
            background: #f9f9f9; 
            text-align: left; 
            padding: 12px 15px; 
            border-bottom: 2px solid #eee; 
            font-size: 13px; 
            color: #555; 
            white-space: nowrap;
        }
        td { 
            padding: 12px 15px; 
            border-bottom: 1px solid #eee; 
            font-size: 13px; 
            vertical-align: middle;
            color: #333;
        }
        tr:last-child td { border-bottom: none; }
        
        /* データがない場合 */
        .no-data {
            text-align: center;
            padding: 30px;
            color: #999;
            font-size: 14px;
        }

        /* 値の装飾 */
        .uuid { font-family: monospace; color: #666; font-size: 11px; }
        .hash { font-family: monospace; color: #888; font-size: 10px; display:inline-block; max-width:100px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        .price { font-weight: bold; color: #333; }
    </style>
</head>
<body>

    <div class="header">
        <div class="app-title">
            DB Inspector
            <span class="sub-title">データベース全件表示ツール</span>
        </div>
        <div style="font-size:12px; color:#999;">
            Last Updated: 
        <fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy/MM/dd HH:mm:ss" timeZone="Asia/Tokyo" />
</div>
    </div>

    <!-- ナビゲーションバー -->
    <div class="sticky-nav">
        <a href="#users" class="nav-link">Users</a>
        <a href="#admins" class="nav-link">Admins</a>
        <a href="#products" class="nav-link">Products</a>
        <a href="#orders" class="nav-link">Orders</a>
        <a href="#order_items" class="nav-link">Order Items</a>
        <a href="#payments" class="nav-link">Payments</a>
        <a href="#ledger" class="nav-link">Ledger</a>
        <a href="#analysis" class="nav-link">Analysis</a>
    </div>

    <div class="container">

        <!-- 1. USERS -->
        <div id="users" class="section">
            <div class="section-header">
                <div class="section-title">Users</div>
                <div class="record-count">${fn:length(result.users)} records</div>
            </div>
            <div class="table-wrap">
                <c:choose>
                    <c:when test="${empty result.users}">
                        <div class="no-data">データがありません</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr><th>User ID</th><th>Name</th><th>Pass</th><th>Code</th><th>Balance</th><th>Point</th><th>Lock</th></tr>
                            <c:forEach var="u" items="${result.users}">
                                <tr>
                                    <td class="uuid">${u.userId}</td>
                                    <td>${u.userName}</td>
                                    <td>***</td>
                                    <td>***</td>
                                    <td class="price">¥ <fmt:formatNumber value="${u.balance}" /></td>
                                    <td>${u.point} pt</td>
                                    <td>${u.lockout ? '<span style="color:red">Yes</span>' : 'No'}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 2. ADMINS -->
        <div id="admins" class="section">
            <div class="section-header">
                <div class="section-title">Admins</div>
                <div class="record-count">${fn:length(result.admins)} records</div>
            </div>
            <div class="table-wrap">
                <c:choose>
                    <c:when test="${empty result.admins}">
                        <div class="no-data">データがありません</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr><th>Admin Name</th><th>Password</th></tr>
                            <c:forEach var="a" items="${result.admins}">
                                <tr>
                                    <td>${a.adminName}</td>
                                    <td>${a.adminPassword}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 3. PRODUCTS -->
        <div id="products" class="section">
            <div class="section-header">
                <div class="section-title">Products</div>
                <div class="record-count">${fn:length(result.products)} records</div>
            </div>
            <div class="table-wrap">
                <c:choose>
                    <c:when test="${empty result.products}">
                        <div class="no-data">データがありません</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr><th>ID</th><th>Name</th><th>Category</th><th>Price</th><th>Status</th><th>Image</th><th>Update</th></tr>
                            <c:forEach var="p" items="${result.products}">
                                <tr>
                                    <td>${p.productId}</td>
                                    <td>${p.productName}</td>
                                    <td>${p.category}</td>
                                    <td class="price">¥ <fmt:formatNumber value="${p.price}" /></td>
                                    <td>${p.salesStatus}</td>
                                    <td>${p.image}</td>
                                    <td style="font-size:11px; color:#888;">${p.updateAt}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 4. ORDERS -->
        <div id="orders" class="section">
            <div class="section-header">
                <div class="section-title">Orders</div>
                <div class="record-count">${fn:length(result.orders)} records</div>
            </div>
            <div class="table-wrap">
                <c:choose>
                    <c:when test="${empty result.orders}">
                        <div class="no-data">データがありません</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr><th>Order ID</th><th>Table</th><th>Adult</th><th>Child</th><th>Payment</th><th>Visit At</th></tr>
                            <c:forEach var="o" items="${result.orders}">
                                <tr>
                                    <td class="uuid">${o.orderId}</td>
                                    <td>${o.tableNumber}</td>
                                    <td>${o.adultCount}</td>
                                    <td>${o.childCount}</td>
                                    <td>${o.paymentCompleted ? 'Done' : 'Pending'}</td>
                                    <td style="font-size:11px;">${o.visitAt}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 5. ORDER ITEMS -->
        <div id="order_items" class="section">
            <div class="section-header">
                <div class="section-title">Order Items</div>
                <div class="record-count">${fn:length(result.orderItems)} records</div>
            </div>
            <div class="table-wrap">
                <c:choose>
                    <c:when test="${empty result.orderItems}">
                        <div class="no-data">データがありません</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr><th>Item ID</th><th>Order ID</th><th>Product ID</th><th>Qty</th><th>Price</th><th>Status</th><th>Added</th></tr>
                            <c:forEach var="oi" items="${result.orderItems}">
                                <tr>
                                    <td class="uuid">${oi.orderItemId}</td>
                                    <td class="uuid">${oi.orderId}</td>
                                    <td>${oi.productId}</td>
                                    <td>${oi.quantity}</td>
                                    <td>${oi.price}</td>
                                    <td>${oi.orderStatus}</td>
                                    <td style="font-size:11px;">${oi.addOrderAt}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 6. PAYMENTS -->
        <div id="payments" class="section">
            <div class="section-header">
                <div class="section-title">Payments</div>
                <div class="record-count">${fn:length(result.payments)} records</div>
            </div>
            <div class="table-wrap">
                <c:choose>
                    <c:when test="${empty result.payments}">
                        <div class="no-data">データがありません</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr><th>Order ID</th><th>User ID</th><th>Used Pt</th><th>Earned Pt</th><th>Completed At</th></tr>
                            <c:forEach var="pay" items="${result.payments}">
                                <tr>
                                    <td class="uuid">${pay.orderId}</td>
                                    <td class="uuid">${pay.userId}</td>
                                    <td>${pay.usedPoints}</td>
                                    <td>${pay.earnedPoints}</td>
                                    <td style="font-size:11px;">${pay.paymentCompletedAt}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 7. LEDGER -->
        <div id="ledger" class="section">
            <div class="section-header">
                <div class="section-title">Ledger (Blockchain)</div>
                <div class="record-count">${fn:length(result.ledgers)} records</div>
            </div>
            <div class="table-wrap">
                <c:choose>
                    <c:when test="${empty result.ledgers}">
                        <div class="no-data">データがありません</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr><th>Height</th><th>Prev Hash</th><th>Curr Hash</th><th>Sender</th><th>Amount</th><th>Created</th></tr>
                            <c:forEach var="l" items="${result.ledgers}">
                                <tr>
                                    <td>${l.height}</td>
                                    <td><span class="hash">${l.prevHash}</span></td>
                                    <td><span class="hash" style="font-weight:bold; color:#333;">${l.currHash}</span></td>
                                    <td class="uuid">${l.senderId}</td>
                                    <td>${l.amount}</td>
                                    <td style="font-size:11px;">${l.createdAt}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 8. ANALYSIS -->
        <div id="analysis" class="section">
            <div class="section-header">
                <div class="section-title">Analysis (Last 7 Days)</div>
                <div class="record-count">${fn:length(result.analysis)} records</div>
            </div>
            <div class="table-wrap">
                <c:choose>
                    <c:when test="${empty result.analysis}">
                        <div class="no-data">データがありません</div>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <tr>
                                <th>Date</th><th>Product ID</th>
                                <th>Single</th><th>Pair</th><th>Family</th><th>Adult Grp</th><th>Group</th>
                            </tr>
                            <c:forEach var="an" items="${result.analysis}">
                                <tr>
                                    <td>${an.analysisDate}</td>
                                    <td>${an.productId}</td>
                                    <td>${an.countSingle}</td>
                                    <td>${an.countPair}</td>
                                    <td>${an.countFamily}</td>
                                    <td>${an.countAdultGroup}</td>
                                    <td>${an.countGroup}</td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

    </div>

    <!-- スクロール追従スクリプト -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const sections = document.querySelectorAll(".section");
            const navLinks = document.querySelectorAll(".nav-link");

            window.addEventListener("scroll", () => {
                let current = "";
                
                // 現在表示されているセクションを特定
                sections.forEach((section) => {
                    const sectionTop = section.offsetTop;
                    const sectionHeight = section.clientHeight;
                    // ヘッダー分(150px)程度オフセットして判定
                    if (window.scrollY >= (sectionTop - 150)) {
                        current = section.getAttribute("id");
                    }
                });

                // ナビゲーションのクラスを切り替え
                navLinks.forEach((link) => {
                    link.classList.remove("active");
                    if (link.getAttribute("href") === "#" + current) {
                        link.classList.add("active");
                    }
                });
            });
        });
    </script>
</body>
</html>