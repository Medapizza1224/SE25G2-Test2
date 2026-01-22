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
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>QRスキャン</title>
    <!-- jsQRライブラリの読み込み (CDN) -->
    <script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.min.js"></script>
        <script>
        window.addEventListener('pageshow', function(event) {
            if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
                window.location.reload();
            }
        });
    </script>
    <style>
        body {
            font-family: -apple-system, sans-serif;
            background-color: #222;
            margin: 0;
            display: flex;
            justify-content: center;
            height: 100vh;
            overflow: hidden;
        }
        .container {
            width: 100%;
            max-width: 480px;
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        /* カメラ映像を表示するCanvas */
        #canvas {
            width: 100%;
            height: 100%;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
            z-index: 1;
        }

        /* スキャン枠のデザイン */
        .scan-overlay {
            position: relative;
            z-index: 2;
            width: 70%;
            max-width: 300px;
            aspect-ratio: 1 / 1;
            border: 4px solid #FF6900;
            border-radius: 20px;
            box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.5); /* 枠外を暗くする */
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .scan-line {
            width: 90%;
            height: 2px;
            background: #FF6900;
            animation: scanAnim 2s infinite linear;
            box-shadow: 0 0 4px #FF6900;
        }

        @keyframes scanAnim {
            0% { transform: translateY(-100px); opacity: 0; }
            50% { opacity: 1; }
            100% { transform: translateY(100px); opacity: 0; }
        }

        .msg-box {
            position: absolute;
            bottom: 50px;
            z-index: 3;
            color: white;
            text-align: center;
            font-weight: bold;
            background: rgba(0,0,0,0.6);
            padding: 10px 20px;
            border-radius: 30px;
        }

        .back-btn {
            position: absolute;
            top: 30px;
            left: 20px;
            z-index: 3;
            color: white;
            text-decoration: none;
            font-size: 16px;
            background: rgba(0,0,0,0.5);
            padding: 8px 16px;
            border-radius: 20px;
        }

        /* デバッグ用入力エリア (カメラが動かない場合用) */
        #debug-input {
            position: absolute;
            bottom: 10px;
            z-index: 4;
            opacity: 0.3;
        }
        #debug-input:hover { opacity: 1; }
    </style>
</head>
<body>
    <div class="container">
        <a href="${pageContext.request.contextPath}/user_home" class="back-btn">✕ 閉じる</a>

        <!-- 映像処理用キャンバス -->
        <canvas id="canvas"></canvas>

        <!-- UIオーバーレイ -->
        <div class="scan-overlay">
            <div class="scan-line"></div>
        </div>

        <div class="msg-box" id="statusMsg">カメラを起動中...</div>
        
        <!-- 非表示のデバッグ用フォーム（どうしてもカメラが使えない環境用） -->
        <div id="debug-input">
            <form action="${pageContext.request.contextPath}/UserPayment" method="get">
                 <input type="text" name="orderId" placeholder="OrderID">
                 <button>Go</button>
            </form>
        </div>
    </div>

    <script>
        const canvas = document.getElementById("canvas");
        const ctx = canvas.getContext("2d");
        const statusMsg = document.getElementById("statusMsg");
        
        // 遷移先のベースURL
        const targetUrl = "${pageContext.request.contextPath}/UserPayment?orderId=";
        
        let isRedirecting = false;

        // カメラ起動
        // facingMode: "environment" でスマホの背面カメラを指定
        navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } })
        .then(function(stream) {
            const video = document.createElement("video");
            video.srcObject = stream;
            video.setAttribute("playsinline", true); // iOS対応
            video.play();
            requestAnimationFrame(() => tick(video));
            statusMsg.innerText = "QRコードを枠内に入れてください";
        })
        .catch(function(err) {
            console.error(err);
            statusMsg.innerText = "カメラの起動に失敗しました";
            statusMsg.style.color = "#ff4444";
        });

        function tick(video) {
            if (isRedirecting) return; // 読み取り成功後は処理停止

            if (video.readyState === video.HAVE_ENOUGH_DATA) {
                // キャンバスのサイズを映像に合わせる
                canvas.height = video.videoHeight;
                canvas.width = video.videoWidth;
                
                // 映像を描画
                ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
                
                // QRコード解析
                // 読み取り範囲を全域にするか、中央に絞るか。ここでは全域を解析
                const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
                const code = jsQR(imageData.data, imageData.width, imageData.height, {
                    inversionAttempts: "dontInvert",
                });

                // ... 前略 ...

            if (code) {
                const rawData = code.data;
                console.log("QR Found: ", rawData);

                // ★★★ ここから修正・追加 ★★★
                
                // 1. 読み取ったデータから「orderId」だけを抽出する
                let orderId = rawData;
                
                // もしQRコードが "http://.../UserPayment?orderId=xxxxx" というURL形式だった場合
                try {
                    // 文字列の中に "orderId=" があるか探す
                    if (rawData.indexOf("orderId=") !== -1) {
                        // "orderId=" の後ろの部分を取り出す
                        orderId = rawData.split("orderId=")[1];
                        
                        // もし後ろに "&" などで他のパラメータが続いていたらカットする
                        if (orderId.indexOf("&") !== -1) {
                            orderId = orderId.split("&")[0];
                        }
                    }
                } catch (e) {
                    console.error("ID extraction failed", e);
                }

                // 2. IDがある程度の長さ（UUIDなら36文字）かチェック
                if (orderId && orderId.length > 10) { 
                    isRedirecting = true;
                    statusMsg.innerText = "読み取り成功！遷移中...";
                    statusMsg.style.background = "#00aa00";
                    
                    ctx.strokeStyle = "#FF3B58";
                    ctx.lineWidth = 4;
                    ctx.strokeRect(code.location.topLeftCorner.x, code.location.topLeftCorner.y, code.width, code.height);

                    setTimeout(() => {
                        // ★重要: 現在のコンテキスト（ログイン状態）を維持したまま、IDだけを付与して遷移
                        // rawData (全URL) ではなく、抽出した orderId を使うのがポイント
                        window.location.href = targetUrl + encodeURIComponent(orderId);
                    }, 300);
                    return;
                }
                // ★★★ 修正ここまで ★★★
            }

            // ... 後略 ...
            }
            requestAnimationFrame(() => tick(video));
        }
    </script>
</body>
</html>