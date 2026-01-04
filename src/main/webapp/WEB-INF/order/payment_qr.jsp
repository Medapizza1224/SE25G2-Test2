<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${empty sessionScope.tableNumber}">
    <c:redirect url="/Order" />
</c:if>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>お会計</title>
    <!-- QRコード生成ライブラリ (CDN) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <style>
        body { margin: 0; font-family: sans-serif; background: #fff; height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; }
        
        .container { display: flex; align-items: center; gap: 60px; max-width: 900px; width: 90%; }
        
        .qr-section { display: flex; flex-direction: column; align-items: center; background: #fff; padding: 40px; border: 4px solid #333; border-radius: 20px; }
        .qr-title { font-weight: bold; font-size: 20px; margin-bottom: 20px; }
        #qrcode { margin: 10px; }
        
        .guide-section { flex: 1; }
        .guide-title { font-size: 24px; font-weight: bold; margin-bottom: 30px; border-bottom: 2px solid #FF6900; display: inline-block; padding-bottom: 5px; }
        
        .step { display: flex; align-items: center; gap: 15px; margin-bottom: 25px; font-size: 18px; color: #333; }
        .icon { font-size: 24px; width: 40px; text-align: center; }
        
        .back-btn { margin-top: 40px; display: inline-block; padding: 15px 40px; background: #333; color: white; text-decoration: none; border-radius: 50px; font-weight: bold; font-size: 16px; }
    </style>
</head>
<body>

    <div class="container">
        <!-- QRコード表示部 -->
        <div class="qr-section">
            <div class="qr-title">お会計QRコード</div>
            <!-- ここにJSでQRが描画されます -->
            <div id="qrcode"></div>
        </div>

        <!-- 案内文 -->
        <div class="guide-section">
            <div class="guide-title">お支払い手順</div>
            
            <div class="step">
                <span class="icon">📱</span>
                <span>お客様のスマートフォンで専用アプリを開く</span>
            </div>
            <div class="step">
                <span class="icon">📷</span>
                <span>「QR読取」をタップし、左のコードを読み取る</span>
            </div>
            <div class="step">
                <span class="icon">🔢</span>
                <span>表示された金額を確認し、パスコードを入力</span>
            </div>
            <div class="step">
                <span class="icon">✅</span>
                <span>決済完了画面が表示されたらお会計終了です</span>
            </div>

            <a href="${pageContext.request.contextPath}/OrderHome" class="back-btn">メニューに戻る</a>
        </div>
    </div>

    <script>
        // ControlResultから渡された値
        const paymentUrl = "${qrResult.paymentUrl}";
        const orderId = "${qrResult.orderId}";
        
        // --- QRコード生成 ---
        if (paymentUrl) {
            new QRCode(document.getElementById("qrcode"), {
                text: paymentUrl,
                width: 250,
                height: 250,
                colorDark : "#000000",
                colorLight : "#ffffff",
                correctLevel : QRCode.CorrectLevel.H
            });
        } else {
            document.getElementById("qrcode").innerText = "エラー: URLが取得できませんでした";
        }

        // --- ★追加: 定期的に決済状況を確認する (ポーリング) ---
        if (orderId) {
            const checkUrl = '${pageContext.request.contextPath}/CheckPaymentStatus?orderId=' + orderId;
            
            const intervalId = setInterval(() => {
                fetch(checkUrl)
                    .then(response => response.json())
                    .then(data => {
                        console.log("Payment status:", data.isPaid);
                        if (data.isPaid) {
                            // 決済済みならループを止めて完了画面へ
                            clearInterval(intervalId);
                            window.location.href = '${pageContext.request.contextPath}/OrderComplete';
                        }
                    })
                    .catch(error => {
                        console.error("Status check failed:", error);
                    });
            }, 3000); // 3000ミリ秒 = 3秒ごとに確認
        }
    </script>
</body>
</html>