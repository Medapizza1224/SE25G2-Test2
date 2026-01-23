<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="util.AppConfig" %>
<%
    AppConfig conf = AppConfig.load(application);
    request.setAttribute("conf", conf);
%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/User" />
</c:if>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>決済画面</title>
    <script>
        window.addEventListener('pageshow', function(event) {
            if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
                window.location.reload();
            }
        });
    </script>
    <style>
        :root {
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            display: flex;
            justify-content: center;
            height: 100vh;
            color: #333;
            
            padding-top: calc(env(safe-area-inset-top) + 20px);
            padding-bottom: env(safe-area-inset-bottom);
            padding-left: env(safe-area-inset-left);
            padding-right: env(safe-area-inset-right);
        }

        .mobile-container {
            width: 100%; max-width: 420px; background-color: #fff; height: 100%;
            display: flex; flex-direction: column; position: relative;
            box-shadow: 0 0 15px rgba(0,0,0,0.1); overflow: hidden;
        }

        /* ヘッダー */
        .header {
            display: flex; justify-content: space-between; align-items: center;
            padding: 15px 20px; border-bottom: 1px solid #eee; background: #fff;
            height: 60px; box-sizing: border-box;
        }
        
        .header-logo { height: 28px; width: auto; object-fit: contain; }
        
        .icon-btn { 
            font-size: 20px; text-decoration: none; color: #333; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            width: 40px; height: 40px;
        }
        .icon-img { width: 24px; height: 24px; object-fit: contain; }

        .content {
            flex: 1; padding: 20px; display: flex; flex-direction: column; align-items: center; overflow-y: auto;
        }

        /* --- 画面1: 金額入力エリア --- */
        #view-payment {
            width: 100%; height: 100%;
            display: flex; flex-direction: column; align-items: center;
            transition: transform 0.3s ease;
        }

        .total-box {
            background-color: #000; color: #fff;
            width: 90%; border-radius: 12px; padding: 33px 20px; text-align: center;
            margin-bottom: 25px; box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
        .total-label { text-align: left; font-size: 12px; margin-bottom: 5px; opacity: 0.8; }
        .total-amount { font-size: 42px; font-weight: bold; letter-spacing: -1px; }

        .input-group { width: 100%; margin-bottom: 20px; }
        .input-label { font-size: 14px; font-weight: bold; margin-bottom: 8px; display: block; }
        
        .point-input-wrapper { position: relative; width: 100%; }
        .point-input {
            width: 100%; padding: 15px 15px 15px 40px; font-size: 18px;
            border: 2px solid #ddd; border-radius: 12px; box-sizing: border-box; outline: none; font-weight: bold;
        }
        .point-icon { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); font-weight: bold; color: #888; }

        .balance-card {
            background-color: #f9f9f9; width: 100%; border-radius: 12px;
            padding: 20px; box-sizing: border-box; margin-bottom: 30px;
        }
        .balance-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .balance-value { font-size: 24px; font-weight: bold; }
        .charge-btn {
            background-color: var(--main-color);
            color: #fff; border: none; padding: 6px 12px; border-radius: 4px;
            font-size: 12px; font-weight: bold; text-decoration: none;
        }
        .available-point { font-size: 13px; color: #666; display: flex; justify-content: space-between; }

        .error-msg { color: #ff0033; font-size: 12px; margin-top: 5px; display: none; }

        .main-btn {
            width: 80%; padding: 16px;
            background-color: var(--main-color);
            color: white; border: none; border-radius: 30px;
            font-size: 24px; font-weight: bold; cursor: pointer;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center; margin-top: 40px;
        }
        .main-btn:disabled { background-color: #ccc; box-shadow: none; }

        /* セキュリティコード画面 */
        #view-security {
            width: 100%; height: 100%; position: absolute; top: 0; left: 0;
            background: #fff; display: flex; flex-direction: column; align-items: center;
            transform: translateY(100%); transition: transform 0.3s ease-in-out; z-index: 10;
        }
        #view-security.active { transform: translateY(0); }

        .security-title { margin-top: 80px; font-size: 16px; font-weight: bold; margin-bottom: 30px; }
        
        /* エラーメッセージ用スタイル (セキュリティ画面) */
        .security-error-msg {
            color: #FF0000; font-weight: bold; font-size: 14px; 
            margin-bottom: 20px; text-align: center;
            /* 改行を反映 */
            white-space: pre-wrap; 
        }

        .indicator-box { display: flex; gap: 15px; margin-bottom: 60px; }
        .dot {
            width: 16px; height: 16px; border-radius: 50%;
            border: 2px solid var(--main-color);
            background-color: #fff; transition: background-color 0.1s;
        }
        .dot.filled { background-color: var(--main-color); }

        .keypad { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; width: 80%; max-width: 300px; }
        .key-btn {
            background-color: #e0e0e0; border: none; border-radius: 50%;
            width: 70px; height: 70px; font-size: 24px; font-weight: bold;
            color: #333; cursor: pointer; display: flex; justify-content: center;
            align-items: center; margin: 0 auto; transition: background-color 0.1s;
        }
        .key-btn:active { background-color: #ccc; }
        .key-btn.transparent { background: transparent; pointer-events: none; }

        .toast {
            position: absolute; bottom: 30px; left: 50%; transform: translateX(-50%);
            color: #ccc; padding: 10px 20px;
            font-size: 12px; border-radius: 4px; opacity: 0; transition: opacity 0.3s;
        }
        .toast.show { opacity: 1; }

    </style>
</head>
<body>

    <div class="mobile-container">
        <form id="paymentForm" action="${pageContext.request.contextPath}/UserPayment" method="post">
            <input type="hidden" name="orderId" value="${orderId}">
            <input type="hidden" id="hiddenAmount" name="amount" value="">
            <input type="hidden" id="hiddenSecurityCode" name="securityCode" value="">
        </form>

        <div id="view-payment">
            <div class="header" style="width:100%; box-sizing:border-box;">
                <a href="${pageContext.request.contextPath}/user_home" class="icon-btn">
                    <img src="${pageContext.request.contextPath}/image/system/ホーム.svg" class="icon-img" alt="ホーム">
                </a>
                
                <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="焼肉〇〇" class="header-logo">
                
                <a href="${pageContext.request.contextPath}/User?action=logout" class="icon-btn" title="ログアウト">
                    <img src="${pageContext.request.contextPath}/image/system/ログアウト.svg" class="icon-img" alt="ログアウト">
                </a>
            </div>

            <div class="content" style="width:100%; box-sizing:border-box;">
                <div class="total-box">
                    <div class="total-label">合計金額</div>
                    <div class="total-amount">¥<fmt:formatNumber value="${order.totalAmount}" /></div>
                </div>

                <div class="input-group">
                    <label class="input-label">ポイントを使う</label>
                    <div class="point-input-wrapper">
                        <span class="point-icon">P</span>
                        <input type="number" id="usePoints" class="point-input" placeholder="0" min="0">
                    </div>
                    <div id="pointError" class="error-msg">ポイントが不足しています</div>
                </div>

                <div class="balance-card">
                    <div class="total-label" style="color:#666;">残高</div>
                    <div class="balance-row">
                        <div class="balance-value">¥<fmt:formatNumber value="${user.balance}" /></div>
                        <a href="${pageContext.request.contextPath}/UserCharge?returnTo=payment&orderId=${order.orderId}" class="charge-btn">チャージ</a>
                    </div>
                    <div class="available-point">
                        <span>利用可能ポイント</span>
                        <span id="maxPointsDisplay"><fmt:formatNumber value="${user.point}" />p</span>
                    </div>
                    <div id="balanceError" class="error-msg">残高が不足しています</div>
                </div>

                <button type="button" id="toSecurityBtn" class="main-btn">決 済</button>
            </div>
        </div>

        <div id="view-security">
            <div class="header" style="width:100%; box-sizing:border-box;">
                <!-- 左矢印ボタンは、通常時は「戻る」だが、エラー後などロックされたら押させたくない場合も考慮 -->
                <div class="icon-btn" onclick="toggleView(false)" style="font-size: 24px;">←</div>
                <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="焼肉〇〇" class="header-logo">
                <div class="icon-btn" style="visibility:hidden">?</div>
            </div>

            <div class="security-title">セキュリティコードを入力</div>

            <!-- ★追加: エラーメッセージ表示エリア -->
            <c:if test="${not empty paymentError}">
                <div class="security-error-msg">${paymentError}</div>
            </c:if>

            <div class="indicator-box">
                <div class="dot" id="dot-0"></div>
                <div class="dot" id="dot-1"></div>
                <div class="dot" id="dot-2"></div>
                <div class="dot" id="dot-3"></div>
            </div>

            <div class="keypad">
                <button class="key-btn" onclick="inputDigit(1)">1</button>
                <button class="key-btn" onclick="inputDigit(2)">2</button>
                <button class="key-btn" onclick="inputDigit(3)">3</button>
                <button class="key-btn" onclick="inputDigit(4)">4</button>
                <button class="key-btn" onclick="inputDigit(5)">5</button>
                <button class="key-btn" onclick="inputDigit(6)">6</button>
                <button class="key-btn" onclick="inputDigit(7)">7</button>
                <button class="key-btn" onclick="inputDigit(8)">8</button>
                <button class="key-btn" onclick="inputDigit(9)">9</button>
                <div class="key-btn transparent"></div>
                <button class="key-btn" onclick="inputDigit(0)">0</button>
                <button class="key-btn" onclick="deleteDigit()">⌫</button>
            </div>
            
            <div id="completeToast" class="toast">処理中...</div>
        </div>
    </div>
    
    <script>
        const totalAmount = ${order.totalAmount};
        const userBalance = ${user.balance};
        const userPoints = ${user.point};
        let finalPayAmount = totalAmount;
        let securityCode = "";
        const MAX_CODE_LENGTH = 4;

        const usePointsInput = document.getElementById('usePoints');
        const pointError = document.getElementById('pointError');
        const balanceError = document.getElementById('balanceError');
        const toSecurityBtn = document.getElementById('toSecurityBtn');
        const hiddenAmount = document.getElementById('hiddenAmount');
        const hiddenSecurityCode = document.getElementById('hiddenSecurityCode');
        const paymentForm = document.getElementById('paymentForm');

        usePointsInput.addEventListener('input', validateAmount);
        toSecurityBtn.addEventListener('click', () => {
            if(validateAmount()) {
                hiddenAmount.value = finalPayAmount;
                toggleView(true);
            }
        });

        // ★追加: ページロード時にエラーがあれば、自動でセキュリティ画面を開く
        window.onload = function() {
            const hasError = "${not empty paymentError}" === "true";
            if (hasError) {
                // ポイント入力等をスキップしてセキュリティ画面へ
                // ※本来はリクエストパラメータから入力値を復元すべきだが、
                //   今回は簡易的に「全額支払い状態」として画面を開く
                hiddenAmount.value = finalPayAmount;
                toggleView(true);
            }
        };

        function validateAmount() {
            let inputPoints = parseInt(usePointsInput.value) || 0;
            if (inputPoints > userPoints) {
                pointError.style.display = 'block';
                pointError.innerText = "所持ポイントを超えています";
                toSecurityBtn.disabled = true;
                return false;
            } else if (inputPoints > totalAmount) {
                pointError.style.display = 'block';
                pointError.innerText = "支払い金額を超えています";
                toSecurityBtn.disabled = true;
                return false;
            } else {
                pointError.style.display = 'none';
            }
            finalPayAmount = totalAmount - inputPoints;
            if (finalPayAmount > userBalance) {
                balanceError.style.display = 'block';
                toSecurityBtn.disabled = true;
                return false;
            } else {
                balanceError.style.display = 'none';
            }
            toSecurityBtn.disabled = false;
            return true;
        }

        function toggleView(showSecurity) {
            const secView = document.getElementById('view-security');
            if (showSecurity) {
                secView.classList.add('active');
                // 入力はリセット
                securityCode = "";
                updateDots();
            } else {
                secView.classList.remove('active');
            }
        }

        function inputDigit(num) {
            if (securityCode.length < MAX_CODE_LENGTH) {
                securityCode += num;
                updateDots();
                if (securityCode.length === MAX_CODE_LENGTH) {
                    submitPayment();
                }
            }
        }

        function deleteDigit() {
            if (securityCode.length > 0) {
                securityCode = securityCode.slice(0, -1);
                updateDots();
            }
        }

        function updateDots() {
            for (let i = 0; i < MAX_CODE_LENGTH; i++) {
                const dot = document.getElementById('dot-' + i);
                if (i < securityCode.length) {
                    dot.classList.add('filled');
                } else {
                    dot.classList.remove('filled');
                }
            }
        }

        function submitPayment() {
            const toast = document.getElementById('completeToast');
            toast.classList.add('show');
            hiddenSecurityCode.value = securityCode;
            // 少し待って送信
            setTimeout(() => {
                paymentForm.submit();
            }, 300);
        }
    </script>
</body>
</html>