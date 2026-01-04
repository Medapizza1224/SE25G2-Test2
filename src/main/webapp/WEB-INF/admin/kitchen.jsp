<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>注文状況 | キッチン</title>
    <style>
        /* 共通レイアウト */
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; display: flex; height: 100vh; background-color: #f5f5f5; color: #333; }
        a { text-decoration: none; }
        
        /* サイドバー */
        .sidebar { width: 240px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; }
        .brand { font-size: 20px; font-weight: bold; padding: 0 25px 30px; display: flex; align-items: center; gap: 10px; }
        .sidebar-item { display: flex; align-items: center; padding: 15px 25px; color: #666; font-weight: bold; font-size: 16px; transition: 0.2s; }
        .sidebar-item:hover { background-color: #f9f9f9; color: #333; }
        .sidebar-item.active { background-color: #fff5f0; color: #FF6900; border-right: 4px solid #FF6900; }
        .icon { width: 30px; text-align: center; margin-right: 10px; font-size: 20px; }

        /* コンテンツ */
        .content { flex: 1; padding: 40px; overflow-y: auto; }
        .page-header { border-left: 5px solid #FF6900; padding-left: 15px; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: bold; }

        /* --- キッチン固有スタイル --- */
        .order-container { display: flex; flex-wrap: wrap; gap: 20px; }
        
        .order-card { 
            background: #fff; width: 300px; border-radius: 8px; overflow: hidden; 
            box-shadow: 0 4px 10px rgba(0,0,0,0.05); display: flex; flex-direction: column;
        }
        
        .card-header { 
            background: #f9f9f9; padding: 15px; border-bottom: 1px solid #eee; 
            display: flex; justify-content: space-between; align-items: center; font-weight: bold;
        }
        
        .timer { color: #FF6900; display: flex; align-items: center; gap: 5px; font-size: 14px; }
        
        .card-body { padding: 0; flex: 1; }
        
        .order-item { 
            padding: 15px; border-bottom: 1px solid #f5f5f5; display: flex; align-items: center; 
            background-color: #ffeaea; /* 未提供カラー */
        }
        
        .qty-badge { 
            background: #FF0000; color: white; width: 28px; height: 28px; border-radius: 50%; 
            display: flex; justify-content: center; align-items: center; font-weight: bold; margin-right: 10px; font-size: 14px;
        }
        
        .item-name { font-weight: bold; font-size: 16px; }

        .card-footer { padding: 15px; }
        
        .done-btn { 
            width: 100%; padding: 12px; border: none; border-radius: 30px; 
            background: #FF6900; color: white; font-weight: bold; cursor: pointer; font-size: 16px;
            box-shadow: 0 4px 6px rgba(255, 105, 0, 0.2); transition: 0.2s;
        }
        .done-btn:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand">🐄 焼肉〇〇</div>
        <a href="AdminKitchen" class="sidebar-item active"><span class="icon">🍳</span> 注文状況</a>
        <a href="AdminAnalysis" class="sidebar-item"><span class="icon">📊</span> 分析</a>
        <a href="AdminUserView" class="sidebar-item"><span class="icon">👤</span> ユーザー</a>
        <a href="AdminProductList" class="sidebar-item"><span class="icon">🍽</span> 商品</a>
        <a href="AdminLogin" class="sidebar-item" style="margin-top:auto;"><span class="icon">🚪</span> ログアウト</a>
    </div>

    <div class="content">
        <div class="page-header">
            <div class="page-title">注文状況（未提供）</div>
        </div>

        <div class="order-container">
            <c:if test="${empty result.unservedList}">
                <p style="color:#666; font-size:18px;">現在、未提供の注文はありません。</p>
            </c:if>

            <c:forEach var="item" items="${result.unservedList}">
                <div class="order-card">
                    <div class="card-header">
                        <span>ORDER ID: ...${item.orderId.toString().substring(0,4)}</span>
                        
                        <!-- ★修正: サーバー側で計算せず、注文時刻(ミリ秒)を属性に持たせる -->
                        <span class="timer" data-start-time="${item.addOrderAt.time}">
                            ⏱ 計算中...
                        </span>
                    </div>

                    <div class="card-body">
                        <div class="order-item">
                            <span class="qty-badge">${item.quantity}</span>
                            <span class="item-name">
                                <c:out value="${item.productName != null ? item.productName : item.productId}" />
                            </span>
                        </div>
                    </div>

                    <div class="card-footer">
                        <form action="AdminKitchen" method="post">
                            <input type="hidden" name="orderItemId" value="${item.orderItemId}">
                            <button type="submit" class="done-btn">提供済み</button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- ★追加: リアルタイム更新用スクリプト -->
    <script>
        function updateTimers() {
            const now = new Date().getTime(); // 現在時刻(ミリ秒)
            const timers = document.querySelectorAll('.timer');

            timers.forEach(timer => {
                const startTime = parseInt(timer.getAttribute('data-start-time'));
                if (!isNaN(startTime)) {
                    // 経過秒数を計算
                    let diffSeconds = Math.floor((now - startTime) / 1000);
                    
                    // サーバー時刻とのズレ等でマイナスにならないように調整
                    if (diffSeconds < 0) diffSeconds = 0;
                    
                    // 表示更新
                    timer.textContent = '⏱ ' + diffSeconds + 's';
                    
                    // (オプション) 10分(600秒)以上経過したら赤字で強調
                    if (diffSeconds > 600) {
                        timer.style.color = '#FF0000';
                        timer.style.fontWeight = 'bold';
                    }
                }
            });
        }

        // 1. 画面表示時に即実行
        updateTimers();

        // 2. その後、1秒ごとに実行（これで数字が進みます）
        setInterval(updateTimers, 1000);

        // 3. 【重要】新規注文を取り込むため、30秒ごとにページ自体をリロード
        setTimeout(function() {
            location.reload();
        }, 30000);
    </script>
</body>
</html>