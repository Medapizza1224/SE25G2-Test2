<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/User" />
</c:if>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ホーム - 焼肉〇〇</title>
    <script>
        window.addEventListener('pageshow', function(event) {
            // "event.persisted" は「キャッシュから表示されたか」のフラグ
            if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
                window.location.reload(); // リロードしてサーバーのチェックを走らせる
            }
        });
    </script>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            display: flex;
            justify-content: center;
        }
        .container {
            width: 100%;
            max-width: 420px;
            background: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }

        /* ヘッダー */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            background: white;
            border-bottom: 1px solid #eee;
        }
        .header-title { font-weight: bold; font-size: 16px; color: #333; }
        .icon-btn { text-decoration: none; font-size: 24px; color: #333; }

        /* コンテンツ */
        .content { padding: 20px; flex: 1; display: flex; flex-direction: column; }

        /* 残高カード */
        .balance-card {
            background: linear-gradient(135deg, #FF6900 0%, #FF8800 100%);
            color: white;
            border-radius: 16px;
            padding: 25px 20px;
            margin-bottom: 30px;
            box-shadow: 0 8px 16px rgba(255, 105, 0, 0.3);
            position: relative;
        }
        .balance-label { font-size: 14px; opacity: 0.9; margin-bottom: 5px; }
        .balance-amount { font-size: 40px; font-weight: bold; letter-spacing: -1px; margin-bottom: 10px; }
        
        .point-badge {
            background: rgba(255,255,255,0.2);
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            display: inline-block;
        }

        /* チャージボタン (カード内に配置) */
        .charge-btn-mini {
            position: absolute;
            top: 25px;
            right: 20px;
            background: white;
            color: #FF6900;
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
            padding: 8px 16px;
            border-radius: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        /* メインアクション */
        .action-area {
            text-align: center;
            margin-top: 20px;
        }
        .qr-btn {
            display: block;
            width: 100%;
            background-color: #333;
            color: white;
            text-decoration: none;
            padding: 20px 0;
            border-radius: 12px;
            font-size: 18px;
            font-weight: bold;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            transition: transform 0.1s;
        }
        .qr-btn:active { transform: scale(0.98); }
        .qr-icon { font-size: 24px; vertical-align: middle; margin-right: 10px; }

        /* ユーザー名表示 */
        .welcome-msg {
            margin-bottom: 15px;
            font-weight: bold;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- ヘッダー -->
        <div class="header">
            <!-- ホームアイコン（現在の画面なのでリンクなしでもOK） -->
            <div class="icon-btn">🏠</div>
            <div class="header-title">焼肉〇〇</div>
            <!-- ログアウト -->
            <a href="${pageContext.request.contextPath}/User?action=logout" class="icon-btn" title="ログアウト">🚪</a>
        </div>

        <div class="content">
            <div class="welcome-msg">
                ようこそ、<c:out value="${user.userName}"/> さん
            </div>

            <!-- 残高カード -->
            <div class="balance-card">
                <div class="balance-label">残高</div>
                <div class="balance-amount">¥<fmt:formatNumber value="${user.balance}" /></div>
                
                <div class="point-badge">
                    P <fmt:formatNumber value="${user.point}" /> pt
                </div>

                <!-- チャージ画面へのリンク -->
                <a href="${pageContext.request.contextPath}/UserCharge" class="charge-btn-mini">
                    + チャージ
                </a>
            </div>

            <!-- QRスキャンボタン -->
            <div class="action-area">
                <p style="color:#666; margin-bottom:10px; font-size:14px;">お会計はこちらから</p>
                <a href="${pageContext.request.contextPath}/user_qr_scan" class="qr-btn">
                    <span class="qr-icon">📷</span>QRコードを読み取る
                </a>
            </div>
        </div>
    </div>
</body>
</html>