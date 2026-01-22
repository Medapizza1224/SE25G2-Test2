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
    <title>決済画面</title>
        <script>
        window.addEventListener('pageshow', function(event) {
            if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
                window.location.reload();
            }
        });
    </script>
    <style>
        /* ベーススタイル */
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            display: flex;
            justify-content: center;
            height: 100vh;
            color: #333;
        }

        .mobile-container {
            width: 100%;
            max-width: 420px;
            background-color: #fff;
            height: 100%;
            display: flex;
            flex-direction: column;
            position: relative;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
            overflow: hidden; /* 画面切り替え用 */
        }

        /* ヘッダー */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            background: #fff;
        }
        .header-title { font-weight: bold; font-size: 16px; }
        .icon-btn { font-size: 20px; text-decoration: none; color: #333; cursor: pointer; }

        /* コンテンツエリア */
        .content {
            flex: 1;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            overflow-y: auto;
        }

        /* --- 画面1: 金額入力エリア --- */
        #view-payment {
            width: 100%;
            display: flex; /* 初期表示 */
            flex-direction: column;
            align-items: center;
            transition: transform 0.3s ease;
        }

        .total-box {
            background-color: #000;
            color: #fff;
            width: 100%;
            border-radius: 12px;
            padding: 30px 20px;
            text-align: center;
            margin-bottom: 25px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
        .total-label { font-size: 12px; margin-bottom: 5px; opacity: 0.8; }
        .total-amount { font-size: 42px; font-weight: bold; letter-spacing: -1px; }

        .input-group { width: 100%; margin-bottom: 20px; }
        .input-label { font-size: 14px; font-weight: bold; margin-bottom: 8px; display: block; }
        
        /* ポイント入力 */
        .point-input-wrapper {
            position: relative;
            width: 100%;
        }
        .point-input {
            width: 100%;
            padding: 15px 15px 15px 40px; /* Pのアイコン分空ける */
            font-size: 18px;
            border: 2px solid #ddd;
            border-radius: 12px;
            box-sizing: border-box;
            outline: none;
            font-weight: bold;
        }
        .point-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            font-weight: bold;
            color: #888;
        }

        /* 残高エリア */
        .balance-card {
            background-color: #f9f9f9;
            width: 100%;
            border-radius: 12px;
            padding: 20px;
            box-sizing: border-box;
            margin-bottom: 30px;
        }
        .balance-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .balance-value { font-size: 24px; font-weight: bold; }
        .charge-btn {
            background-color: #ff0033;
            color: #fff;
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            text-decoration: none;
        }
        .available-point { font-size: 13px; color: #666; display: flex; justify-content: space-between; }

        /* エラーメッセージ */
        .error-msg {
            color: #ff0033;
            font-size: 12px;
            margin-top: 5px;
            display: none; /* JSで制御 */
        }

        /* 共通ボタン */
        .main-btn {
            width: 80%;
            padding: 16px;
            background-color: #FF6900;
            color: white;
            border: none;
            border-radius: 30px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 4px 6px rgba(255, 105, 0, 0.3);
            text-align: center;
            margin-top: auto; /* 下部に配置 */
        }
        .main-btn:disabled { background-color: #ccc; box-shadow: none; }

        /* --- 画面2: セキュリティコード --- */
        #view-security {
            width: 100%;
            height: 100%;
            position: absolute;
            top: 0;
            left: 0;
            background: #fff;
            display: flex;
            flex-direction: column;
            align-items: center;
            transform: translateY(100%); /* 初期は下に隠す */
            transition: transform 0.3s ease-in-out;
            z-index: 10;
        }
        #view-security.active {
            transform: translateY(0);
        }

        .security-title {
            margin-top: 80px;
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 30px;
        }
        
        /* インジケーター（● ● ● ●） */
        .indicator-box {
            display: flex;
            gap: 15px;
            margin-bottom: 60px;
        }
        .dot {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            border: 2px solid #FF6900;
            background-color: #fff;
            transition: background-color 0.1s;
        }
        .dot.filled {
            background-color: #FF6900;
        }

        /* キーパッド */
        .keypad {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            width: 80%;
            max-width: 300px;
        }
        .key-btn {
            background-color: #e0e0e0;
            border: none;
            border-radius: 50%;
            width: 70px;
            height: 70px;
            font-size: 24px;
            font-weight: bold;
            color: #333;
            cursor: pointer;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0 auto;
            transition: background-color 0.1s;
        }
        .key-btn:active { background-color: #ccc; }
        .key-btn.transparent { background: transparent; pointer-events: none; }

        .backspace-icon {
            font-size: 20px;
        }

        /* メッセージトースト */
        .toast {
            position: absolute;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            background-color: #0099ff;
            color: #fff;
            padding: 10px 20px;
            font-size: 12px;
            border-radius: 4px;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .toast.show { opacity: 1; }

    </style>
</head>
<body>

    <div class="mobile-container">
        
        <!-- 実際の送信フォーム（非表示） -->
        <form id="paymentForm" action="${pageContext.request.contextPath}/UserPayment" method="post">
            <input type="hidden" name="orderId" value="${orderId}">
            <!-- 支払い金額（合計 - ポイント利用分） -->
            <input type="hidden" id="hiddenAmount" name="amount" value="">
            <!-- セキュリティコード -->
            <input type="hidden" id="hiddenSecurityCode" name="securityCode" value="">
        </form>

        <!-- === VIEW 1: 決済金額・ポイント入力 === -->
        <div id="view-payment">
            <div class="header" style="width:100%; box-sizing:border-box;">
                <a href="${pageContext.request.contextPath}/user_home" class="icon-btn">🏠</a>
                <div class="header-title">焼肉〇〇</div>
                <a href="${pageContext.request.contextPath}/User?action=logout" class="icon-btn" title="ログアウト">🚪</a>
            </div>

            <div class="content" style="width:100%; box-sizing:border-box;">
                <!-- 合計金額 -->
                <div class="total-box">
                    <div class="total-label">合計金額</div>
                    <div class="total-amount">¥<fmt:formatNumber value="${order.totalAmount}" /></div>
                </div>

                <!-- ポイント入力 -->
                <div class="input-group">
                    <label class="input-label">ポイントを使う</label>
                    <div class="point-input-wrapper">
                        <span class="point-icon">P</span>
                        <input type="number" id="usePoints" class="point-input" placeholder="0" min="0">
                    </div>
                    <div id="pointError" class="error-msg">ポイントが不足しています</div>
                </div>

                <!-- 残高情報 -->
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

                <!-- 決済ボタン -->
                <button type="button" id="toSecurityBtn" class="main-btn">決 済</button>
            </div>
        </div>

        <!-- === VIEW 2: セキュリティコード入力 === -->
        <div id="view-security">
            <div class="header" style="width:100%; box-sizing:border-box;">
                <!-- 戻るボタン -->
                <div class="icon-btn" onclick="toggleView(false)">←</div>
                <div class="header-title">焼肉〇〇</div>
                <div class="icon-btn" style="visibility:hidden">?</div>
            </div>

            <div class="security-title">セキュリティコードを入力</div>

            <!-- インジケーター -->
            <div class="indicator-box">
                <div class="dot" id="dot-0"></div>
                <div class="dot" id="dot-1"></div>
                <div class="dot" id="dot-2"></div>
                <div class="dot" id="dot-3"></div>
            </div>

            <!-- キーパッド -->
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

        </div>

    </div>

    <script>
        // --- データ定義 (JSP変数からJSへ渡す) ---
        const totalAmount = ${order.totalAmount}; // 注文合計
        const userBalance = ${user.balance};      // 所持金
        const userPoints = ${user.point};         // 所持ポイント

        // --- 状態管理 ---
        let finalPayAmount = totalAmount; // 実際に支払う金額（合計 - ポイント）
        let securityCode = "";
        const MAX_CODE_LENGTH = 4;

        // --- DOM要素 ---
        const usePointsInput = document.getElementById('usePoints');
        const pointError = document.getElementById('pointError');
        const balanceError = document.getElementById('balanceError');
        const toSecurityBtn = document.getElementById('toSecurityBtn');
        const hiddenAmount = document.getElementById('hiddenAmount');
        const hiddenSecurityCode = document.getElementById('hiddenSecurityCode');
        const paymentForm = document.getElementById('paymentForm');

        // --- 初期化 ---
        usePointsInput.addEventListener('input', validateAmount);
        toSecurityBtn.addEventListener('click', () => {
            if(validateAmount()) {
                // 送信金額を確定してセット
                hiddenAmount.value = finalPayAmount;
                toggleView(true);
            }
        });

        // --- 自動チェックロジック ---
        function validateAmount() {
            let inputPoints = parseInt(usePointsInput.value) || 0;

            // 1. ポイント上限チェック
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

            // 2. 残高不足チェック
            // 支払い金額 = 合計 - ポイント利用
            finalPayAmount = totalAmount - inputPoints;

            if (finalPayAmount > userBalance) {
                balanceError.style.display = 'block';
                toSecurityBtn.disabled = true;
                return false;
            } else {
                balanceError.style.display = 'none';
            }

            // 正常
            toSecurityBtn.disabled = false;
            return true;
        }

        // --- 画面切り替え ---
        function toggleView(showSecurity) {
            const secView = document.getElementById('view-security');
            if (showSecurity) {
                secView.classList.add('active');
                // セキュリティコードリセット
                securityCode = "";
                updateDots();
            } else {
                secView.classList.remove('active');
            }
        }

        // --- キーパッド操作 ---
        function inputDigit(num) {
            if (securityCode.length < MAX_CODE_LENGTH) {
                securityCode += num;
                updateDots();
                
                // 4桁入力完了時の処理
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

        // --- 決済実行 ---
        function submitPayment() {
            // トースト表示（演出）
            const toast = document.getElementById('completeToast');
            toast.classList.add('show');

            // フォームに値をセット
            hiddenSecurityCode.value = securityCode;

            // 少し待ってから送信（演出のため）
            setTimeout(() => {
                paymentForm.submit();
            }, 500);
        }
    </script>
</body>
</html>