<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>管理者ログイン</title>
    <style>
        /* 全体のリセットとフォント設定 */
        body {
            margin: 0;
            padding: 0;
            font-family: "Helvetica Neue", Arial, sans-serif;
            background-color: #fff;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        /* 外枠のコンテナ（グレーの枠線） */
        .container {
            width: 900px;
            height: 600px;
            border: 4px solid #ccc;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        /* ログインフォームの中央エリア */
        .login-box {
            text-align: left;
            width: 300px;
        }

        /* 牛のアイコンと店名 */
        .brand {
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 40px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }
        .icon-cow {
            font-size: 30px; /* 絵文字で代用 */
        }

        /* 入力ラベル */
        label {
            display: block;
            font-size: 12px;
            font-weight: bold;
            margin-bottom: 5px;
            margin-top: 20px;
        }

        /* 入力フィールド */
        .input-group {
            position: relative;
        }
        
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 20px; /* 角丸 */
            box-sizing: border-box;
            font-size: 14px;
            outline: none;
            padding-right: 35px; /* アイコン分の余白 */
        }

        /* パスワード表示切替の目玉アイコン */
        .toggle-password {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #999;
            font-size: 16px;
        }

        /* ログインボタン */
        .btn-login {
            display: block;
            width: 100%;
            background-color: #000; /* 黒 */
            color: #fff;
            padding: 12px;
            border: none;
            border-radius: 25px; /* 完全な角丸 */
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 30px;
            transition: opacity 0.2s;
        }
        .btn-login:hover {
            opacity: 0.8;
        }

        /* エラーメッセージ */
        .error-msg {
            color: red;
            font-size: 12px;
            text-align: center;
            margin-top: 10px;
            min-height: 18px;
        }

    </style>
    <script>
        // パスワードの表示・非表示切り替え
        function togglePassword() {
            const passwordInput = document.getElementById("password");
            if (passwordInput.type === "password") {
                passwordInput.type = "text";
            } else {
                passwordInput.type = "password";
            }
        }
    </script>
</head>
<body>
    
    <div class="container">
        <div class="login-box">
            <!-- ロゴ -->
            <div class="brand">
                <span class="icon-cow">🐄</span> 焼肉〇〇
            </div>

            <form action="${pageContext.request.contextPath}/AdminLogin" method="post">
                <!-- 管理者名 -->
                <label for="adminName">管理者名</label>
                <div class="input-group">
                    <%-- 初期値を削除し、エラー時の再表示のみ残しています --%>
                    <input type="text" id="adminName" name="adminName" 
                           value="${not empty adminName ? adminName : ''}">
                </div>

                <!-- パスワード -->
                <label for="password">パスワード</label>
                <div class="input-group">
                    <input type="password" id="password" name="password">
                    <span class="toggle-password" onclick="togglePassword()">👁</span>
                </div>

                <!-- エラー表示エリア -->
                <div class="error-msg">
                    <c:if test="${not empty error}">
                        <c:out value="${error}" />
                    </c:if>
                </div>

                <!-- ボタン -->
                <button type="submit" class="btn-login">ログイン</button>
            </form>
        </div>
    </div>

</body>
</html>