<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新規登録</title>
    <style>
        /* ログイン画面(user_signin.jsp)と同じ基本デザイン */
        body { font-family: "Yu Gothic", "YuGothic", sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background-color: #fff; }
        .container { width: 320px; display: flex; flex-direction: column; align-items: center; padding-bottom: 50px; }
        .logo { width: 160px; height: auto; margin-bottom: 40px; }
        h2 { display: none; }

        form { width: 100%; display: flex; flex-direction: column; gap: 15px; }
        .input-group { margin: 0; padding: 0; display: flex; flex-direction: column; position: relative; }
        .input-label { font-size: 15px; font-weight: bold; color: #000; margin-bottom: 6px; display: block; }
        
        /* 入力フィールドのスタイル統一 */
        input[type="text"], input[type="password"], input[type="email"] { 
            width: 100%; 
            height: 40px; 
            box-sizing: border-box; 
            border: 2px solid #BFBFBF; /* 元のsignupは1px solid #cccでしたが、ログイン画面に合わせて統一 */
            border-radius: 25px; 
            padding: 0 20px; 
            font-size: 16px; 
            font-weight: bold; 
            font-family: inherit; 
            outline: none; 
            color: #555; 
        }
        input::placeholder { color: #ccc; }
        
        .eye-icon { position: absolute; right: 15px; top: 38px; width: 20px; cursor: pointer; pointer-events: auto; }

        /* ボタンのスタイル統一 */
        button[type="submit"] { width: 100%; height: 50px; background-color: #000000; color: #FFFFFF; border: none; border-radius: 25px; font-size: 18px; font-weight: bold; cursor: pointer; font-family: inherit; margin-top: 20px; }
        button[type="submit"]:hover { opacity: 0.8; }

        .link-area { margin-top: 25px; font-size: 12px; font-weight: bold; text-align: center; }
        .link-area a { color: #0070C0; text-decoration: none; border-bottom: 1px solid #0070C0; }

        /* エラー表示スタイル */
        .error-container { display: flex; align-items: flex-start; gap: 5px; color: #FF0000; font-size: 10px; font-weight: bold; margin-top: 5px; margin-left: 5px; }
        .error-icon { width: 12px; height: 12px; margin-top: 1px; }
        
        /* ヘルプメッセージ（通常時の注釈） */
        .help-text { font-size: 10px; color: #A6A6A6; margin-top: 5px; margin-left: 5px; }
    </style>
    <script>
        function togglePassword(id) {
            const input = document.getElementById(id);
            if (input.type === "password") {
                input.type = "text";
            } else {
                input.type = "password";
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <!-- ロゴエリア -->
        <img class="logo" src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" alt="ロゴ">
        <h2>新規登録</h2>
        
        <form action="user_signup" method="post">
            
            <!-- ユーザー名 (メールアドレス) -->
            <div class="input-group">
                <span class="input-label">メールアドレス</span>
                <input type="email" name="userName" value="${not empty userName ? userName : ''}" placeholder="example@gmail.com" required>
                
                <c:choose>
                    <c:when test="${not empty errorUserName}">
                        <div class="error-container">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg" class="error-icon">
                            <span>${errorUserName}</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="help-text">半角8~32桁。英大小文字、数字、記号のうち2種類以上。</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- パスワード -->
            <div class="input-group">
                <span class="input-label">パスワード</span>
                <input type="password" name="password" id="regPass" placeholder="abcd1234" required>
                <img src="${pageContext.request.contextPath}/image/system/password.svg" class="eye-icon" onclick="togglePassword('regPass')" alt="表示切替">
                
                <c:choose>
                    <c:when test="${not empty errorPassword}">
                        <div class="error-container">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg" class="error-icon">
                            <span>${errorPassword}</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="help-text">半角8~32桁。英大小文字、数字、記号のうち2種類以上。</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- パスワード（確認） -->
            <div class="input-group">
                <span class="input-label">パスワード（確認）</span>
                <input type="password" name="passwordConfirm" id="regPassConf" placeholder="abcd1234" required>
                <img src="${pageContext.request.contextPath}/image/system/password.svg" class="eye-icon" onclick="togglePassword('regPassConf')" alt="表示切替">
                
                <c:choose>
                    <c:when test="${not empty errorPasswordConfirm}">
                        <div class="error-container">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg" class="error-icon">
                            <span>${errorPasswordConfirm}</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="help-text">半角8~32桁。英大小文字、数字、記号のうち2種類以上。</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- セキュリティコード -->
            <div class="input-group">
                <span class="input-label">セキュリティコード</span>
                <input type="text" name="securityCode" value="${not empty securityCode ? securityCode : ''}" placeholder="1234" required maxlength="4">
                
                <c:choose>
                    <c:when test="${not empty errorSecurityCode}">
                        <div class="error-container">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg" class="error-icon">
                            <span>${errorSecurityCode}</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="help-text">4桁の数字のみ。</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <button type="submit">新規登録</button>
        </form>

        <div class="link-area">
            すでにアカウントをお持ちの場合：
            <a href="${pageContext.request.contextPath}/User">ログイン</a>
        </div>
    </div>
</body>
</html>