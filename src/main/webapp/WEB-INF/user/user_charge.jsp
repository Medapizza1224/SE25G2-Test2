<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>チャージ</title>
    <style>
        body {
            font-family: "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
            background-color: #F8F7F5; /* SVGの背景色 */
            margin: 0;
            display: flex;
            justify-content: center;
            color: #333;
        }
        .container {
            width: 100%;
            max-width: 480px; /* SVGの幅感に合わせて調整 */
            background: transparent;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        
        /* 青いバーはSVGデザインにないため非表示 */
        .blue-bar { display: none; }

        /* ヘッダー: SVGの上部エリアを再現 */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 25px;
            background-color: #F8F7F5;
            border: none;
            margin-bottom: 10px;
        }
        .header a {
            text-decoration: none;
            color: #333;
            font-size: 24px;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .header-title { 
            font-weight: bold; 
            font-size: 18px; 
            letter-spacing: 1px;
        }
        /* アイコンの見た目をSVG風に（絵文字をCSSで調整） */
        .icon-home::before { content: "‹"; font-size: 40px; font-weight: 300; position: relative; top: -2px; }
        .icon-close::before { content: "×"; font-size: 32px; font-weight: 300; }
        
        /* 元のアイコン・テキストを隠すハック */
        .header a div { display: none; }
        .header a.home-link::after { content: "‹"; font-size: 40px; font-family: sans-serif; font-weight: lighter; margin-top: -5px; margin-left: -10px;}
        .header a.logout-link::after { content: "×"; font-size: 30px; font-family: sans-serif; font-weight: lighter; }


        /* コンテンツエリア: SVGの白いカード部分 */
        .content { 
            background: white;
            margin: 0 15px 30px 15px;
            padding: 30px 25px;
            border-radius: 24px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            flex: 1;
        }

        /* 残高カード: SVGのオレンジ部分 */
        .balance-card {
            background-color: #FF6900;
            color: white;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 5px 15px rgba(255, 105, 0, 0.3);
            position: relative;
        }
        .balance-label { font-size: 13px; margin-bottom: 8px; opacity: 0.9; }
        .balance-amount { font-size: 32px; font-weight: bold; letter-spacing: 0.5px; font-family: Arial, sans-serif; }
        /* SVGにある更新マーク風の装飾 */
        .balance-card::after {
            content: "↻";
            position: absolute;
            top: 20px;
            right: 20px;
            font-size: 20px;
            opacity: 0.8;
            font-weight: bold;
        }

        /* 入力エリア */
        .label { 
            font-weight: bold; 
            margin-bottom: 12px; 
            display: block; 
            font-size: 15px; 
            color: #333;
        }
        .input-box {
            width: 100%;
            padding: 12px;
            font-size: 28px;
            font-weight: bold;
            border: none;
            border-bottom: 1px solid #ddd;
            border-radius: 0;
            text-align: right;
            box-sizing: border-box;
            margin-bottom: 25px;
            background: transparent;
            font-family: Arial, sans-serif;
            color: #333;
        }
        .input-box:focus { outline: none; border-bottom: 2px solid #FF6900; }

        /* クイックボタン: SVGのグレー/赤ボタン */
        .quick-buttons {
            display: flex;
            gap: 12px;
            margin-bottom: 40px;
        }
        .q-btn {
            flex: 1;
            padding: 14px 0;
            background-color: #F5F5F5; /* SVGの非選択色 #F8F7F5に近いグレー */
            border: 1px solid #F5F5F5;
            color: #999;
            border-radius: 8px;
            font-weight: bold;
            font-size: 14px;
            cursor: pointer;
            text-align: center;
            transition: all 0.2s;
        }
        /* 選択状態: SVGの真ん中のボタンスタイル */
        .q-btn.selected {
            background-color: #FFF5F5; /* 薄い赤 */
            color: #FF0000;
            border: 2px solid #FF0000;
            position: relative; /* ボーダー分ずれないように調整 */
        }

        /* チャージ方法: SVGの下部カード */
        .method-box {
            border: 2px solid #FF0000;
            background-color: #FFF5F5; /* 薄い赤背景 */
            border-radius: 12px;
            padding: 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 50px;
        }
        .card-icon { font-size: 24px; margin-right: 15px; }
        .card-info { flex: 1; font-weight: bold; font-size: 15px; color: #333; }
        .card-sub { font-size: 12px; color: #666; display: block; margin-top: 2px; }
        .check-circle {
            width: 22px; height: 22px;
            border-radius: 50%;
            background-color: #FF0000; /* 赤丸 */
            position: relative;
        }
        /* チェックマーク */
        .check-circle::after {
            content: "";
            position: absolute;
            left: 7px; top: 3px;
            width: 6px; height: 10px;
            border: solid white;
            border-width: 0 2px 2px 0;
            transform: rotate(45deg);
        }

        /* チャージボタン: SVGの一番下の赤いボタン */
        .charge-btn {
            width: 100%;
            padding: 20px;
            background-color: #FF6900;
            color: white;
            border: none;
            border-radius: 35px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 8px 20px rgba(255, 0, 0, 0.3);
            transition: opacity 0.2s;
        }
        .charge-btn:active { opacity: 0.8; }
        
        .error-msg { color: #FF0000; font-weight: bold; margin-bottom: 20px; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <!-- 青いバー (SVGに無いため非表示) -->
        <div class="blue-bar">チャージ画面</div>

        <!-- ヘッダー -->
        <div class="header">
            <!-- 戻るボタンとして機能させる -->
            <a href="${pageContext.request.contextPath}/user_home" class="home-link">
                <!-- 元のアイコンはCSSで非表示にし、疑似要素で「‹」を表示 -->
                <div>🏠</div>
                <div>ホーム</div>
            </a>
            
            <div class="header-title">チャージ</div>
            
            <!-- 閉じるボタンとして機能させる -->
            <a href="${pageContext.request.contextPath}User" class="logout-link">
                <!-- 元のアイコンはCSSで非表示にし、疑似要素で「×」を表示 -->
                <div>🚪</div>
                <div>ログアウト</div>
            </a>
        </div>

        <div class="content">
            <!-- 残高表示 -->
            <div class="balance-card">
                <div class="balance-label">残高</div>
                <div class="balance-amount">¥ <fmt:formatNumber value="${user.balance}" /></div>
            </div>

            <!-- エラーメッセージ -->
            <c:if test="${not empty error}">
                <div class="error-msg">${error}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/UserCharge" method="post">
                <!-- チャージ金額入力 -->
                <label class="label">チャージ金額</label>
                <input type="number" id="chargeInput" name="amount" class="input-box" value="5000" placeholder="¥ 0">

                <!-- クイックボタン -->
                <div class="quick-buttons">
                    <button type="button" class="q-btn" onclick="selectAmount(this, 1000)">+1,000</button>
                    <button type="button" class="q-btn selected" onclick="selectAmount(this, 5000)">+5,000</button>
                    <button type="button" class="q-btn" onclick="selectAmount(this, 10000)">+10,000</button>
                </div>

                <!-- チャージ方法 (SVGのデザインに合わせて固定表示) -->
                <label class="label">チャージ方法</label>
                <div class="method-box">
                    <div class="card-icon">💳</div> <!-- SVG内のVISAロゴ等の代用 -->
                    <div class="card-info">
                        クレジットカード
                        <span class="card-sub">VISA **** 5678</span>
                    </div>
                    <div class="check-circle"></div>
                </div>

                <!-- ボタン -->
                <button type="submit" class="charge-btn">チャージする</button>
            </form>
        </div>
    </div>

    <script>
        const input = document.getElementById('chargeInput');

        // ロジックは変えずに、SVGの見た目（選択状態のスタイル切り替え）を実現するための処理を追加
        function selectAmount(btn, val) {
            // 金額セット (元のロジック: setAmount相当の動作 + スタイル更新)
            // 元のコードには addAmount と setAmount があったが、
            // SVGのデザイン（3つの選択肢から選ぶUI）に合わせるため、ここではセット動作を基本とする。
            // ※もし「加算」ロジックが必要ならここを修正してください。今回はSVGのラジオボタン的な見た目を優先してセットにします。
            
            // 元のロジックを保持するため、既存の動きを踏襲しつつ値をセット
            input.value = val;
            
            // 全ボタンの選択状態を解除
            document.querySelectorAll('.q-btn').forEach(b => b.classList.remove('selected'));
            // クリックされたボタンを選択状態に
            btn.classList.add('selected');
        }

        // 互換性のため元の関数名も残すが、今回はUIに合わせて selectAmount をメインで使用
        function addAmount(val) {
            let current = parseInt(input.value) || 0;
            input.value = current + val;
            // 自由入力になった場合はボタン選択を外す
            document.querySelectorAll('.q-btn').forEach(b => b.classList.remove('selected'));
        }

        function setAmount(val) {
            input.value = val;
            updateBtnStyle(val);
        }

        function updateBtnStyle(val) {
            // 値に応じてボタンのスタイルを更新する処理があればここに記述
        }
        
        // 入力欄を手動変更した時の処理
        input.addEventListener('input', function() {
            document.querySelectorAll('.q-btn').forEach(b => b.classList.remove('selected'));
        });
    </script>
</body>
</html>