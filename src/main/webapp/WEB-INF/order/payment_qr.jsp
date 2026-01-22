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
    <title>お会計</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <style>
        :root {
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        body { 
            margin: 0; 
            font-family: "Helvetica Neue", Arial, sans-serif; 
            background: #fff; 
            height: 100vh; 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            justify-content: center; 
        }
        
        /* 全体のコンテナ */
        .container { 
            display: flex;
            flex-direction: column; /* 縦並びに変更 */
            justify-content: center; 
            width: 95%; 
            max-width: 1400px;
            height: 90vh; /* 高さを確保 */
            border-radius: 8px;
            padding: 40px;
            box-sizing: border-box;
        }

        /* メインコンテンツ（QRと画像）を横並びにするラッパー */
        .content-wrapper {
            flex: 1; /* 余ったスペースを埋める */
            display: flex;
            flex-direction: row;
            align-items: center;
            justify-content: center;
            gap: 100px;
            width: 100%;
        }
        
        /* 左側：QRコードエリア */
        .qr-section { 
            flex: 1;
            display: flex; 
            flex-direction: column; 
            align-items: flex-end; /* 中央寄り（右） */
            justify-content: center;
            background: #fff; 
        }
        
        #qrcode { 
            margin: 0; 
        }
        
        /* 右側：操作説明画像エリア */
        .guide-section { 
            flex: 1;
            display: flex;
            justify-content: flex-start; /* 中央寄り（左） */
            align-items: center;
        }
        
        .guide-img {
            max-width: 100%;
            height: auto;
            max-height: 60vh; /* 画面高さの60%までに制限してはみ出し防止 */
            object-fit: contain;
        }

        /* フッターエリア（戻るボタン用） */
        .footer-section {
            width: 100%;
            display: flex;
            justify-content: flex-start; /* 左寄せ */
            padding-top: 20px;
        }
        
        /* 戻るボタン（絶対配置をやめて通常の配置に） */
        .back-btn { 
            display: inline-block; 
            padding: 5px 50px; 
            background: #000; /* 黒背景 */
            color: white; 
            text-decoration: none; 
            border-radius: 50px; 
            font-weight: bold; 
            font-size: 18px; 
            transition: opacity 0.2s;
            /* マージンで位置を微調整 */
            margin-left: 180px; 
            margin-bottom: 20px;
        }
        .back-btn:hover {
            opacity: 0.8;
        }
    </style>
</head>
<body>

    <div class="container">
        <!-- 上段：コンテンツ -->
        <div class="content-wrapper">
            <!-- 左側：QRコード -->
            <div class="qr-section">
                <div id="qrcode"></div>
            </div>

            <!-- 右側：操作画像 -->
            <div class="guide-section">
                <img src="${pageContext.request.contextPath}/image/system/QR操作.svg" alt="操作方法" class="guide-img">
            </div>
        </div>

        <!-- 下段：ボタン -->
        <div class="footer-section">
            <a href="${pageContext.request.contextPath}/OrderHome" class="back-btn">戻る</a>
        </div>
    </div>

    <script>
        const paymentUrl = "${qrResult.paymentUrl}";
        const orderId = "${qrResult.orderId}";
        
        if (paymentUrl) {
            // QRコード生成サイズ (450x450)
            new QRCode(document.getElementById("qrcode"), {
                text: paymentUrl,
                width: 350,
                height: 350,
                colorDark : "#000000",
                colorLight : "#ffffff",
                correctLevel : QRCode.CorrectLevel.H
            });
        } else {
            document.getElementById("qrcode").innerText = "エラー: URLが取得できませんでした";
        }

        if (orderId) {
            const checkUrl = '${pageContext.request.contextPath}/CheckPaymentStatus?orderId=' + orderId;
            const intervalId = setInterval(() => {
                fetch(checkUrl)
                    .then(response => response.json())
                    .then(data => {
                        if (data.isPaid) {
                            clearInterval(intervalId);
                            window.location.href = '${pageContext.request.contextPath}/OrderComplete';
                        }
                    })
                    .catch(error => { console.error("Status check failed:", error); });
            }, 3000);
        }
    </script>
</body>
</html>