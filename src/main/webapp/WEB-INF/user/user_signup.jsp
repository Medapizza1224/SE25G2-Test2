<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新規登録</title>
    <style>
        body { font-family: "Yu Gothic", "YuGothic", sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background-color: #fff; }
        .container { width: 320px; display: flex; flex-direction: column; align-items: center; padding-bottom: 50px;}
        
        .logo-area { display: flex; align-items: center; gap: 10px; margin-bottom: 40px; }
        .cow-icon { font-size: 30px; }
        .brand-name { font-size: 20px; font-weight: normal; }

        form { width: 100%; display: flex; flex-direction: column; gap: 25px; }
        .input-group { margin: 0; padding: 0; display: flex; flex-direction: column; position: relative; }
        
        .input-label { font-size: 16px; font-weight: bold; color: #000; margin-bottom: 8px; display: block; }
        
        /* 入力欄のデザイン（画像の丸みを再現） */
        input { 
            width: 100%; height: 45px; 
            box-sizing: border-box; 
            border: 1px solid #ccc; /* 通常時はグレー */
            border-radius: 25px; 
            padding: 0 20px; 
            font-size: 16px; 
            font-weight: bold; 
            outline: none; 
            color: #555;
        }
        input::placeholder { color: #ccc; }

        /* エラー時の注釈 */
        .msg-error {
            color: #FF0000; font-size: 10px; font-weight: bold; margin-top: 5px; 
            display: flex; align-items: center; gap: 4px;
        }
        .msg-error img { width: 12px; height: 12px; }

        /* 通常時の注釈 */
        .msg-help {
            color: #A6A6A6; font-size: 10px; margin-top: 5px; margin-left: 5px;
        }

        .eye-icon { position: absolute; right: 15px; top: 42px; width: 20px; cursor: pointer; }

        /* 登録ボタン */
        button[type="submit"] { 
            width: 100%; height: 50px; 
            background-color: #000000; color: #FFFFFF; 
            border: none; border-radius: 25px; 
            font-size: 18px; font-weight: bold; 
            cursor: pointer; margin-top: 20px; 
        }
        button[type="submit"]:hover { opacity: 0.8; }
    </style>
    <script>
        function togglePassword(id) {
            const input = document.getElementById(id);
            if (input.type === "password") input.type = "text";
            else input.type = "password";
        }
    </script>
</head>
<body>
    <div class="container">
        <!-- ロゴエリア（画像のイメージ） -->
        <div class="logo-area">
            <span class="cow-icon">🐄</span>
            <span class="brand-name">焼肉〇〇</span>
        </div>
        
        <form action="user_signup" method="post">
            
            <!-- ユーザー名 -->
            <div class="input-group">
                <label class="input-label">ユーザー名</label>
                <input type="text" name="userName" value="${not empty userName ? userName : ''}" placeholder="Hazelwb2025" required>
                
                <c:choose>
                    <c:when test="${not empty errorUserName}">
                        <div class="msg-error">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg">
                            <span>${errorUserName}</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="msg-help">半角8~32桁。英大小文字、数字、記号のうち2種類以上。</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- パスワード -->
            <div class="input-group">
                <label class="input-label">パスワード</label>
                <input type="password" name="password" id="regPass" placeholder="GakugeiN106" required>
                <img src="${pageContext.request.contextPath}/image/system/password.svg" class="eye-icon" onclick="togglePassword('regPass')">
                
                <c:choose>
                    <c:when test="${not empty errorPassword}">
                        <div class="msg-error">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg">
                            <span>${errorPassword}</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="msg-help">半角8~32桁。英大小文字、数字、記号のうち2種類以上。</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- パスワード（確認） -->
            <div class="input-group">
                <label class="input-label">パスワード（確認）</label>
                <input type="password" name="passwordConfirm" id="regPassConf" placeholder="Hazelwb2025" required>
                <img src="${pageContext.request.contextPath}/image/system/password.svg" class="eye-icon" onclick="togglePassword('regPassConf')">
                
                <c:choose>
                    <c:when test="${not empty errorPasswordConfirm}">
                        <div class="msg-error">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg">
                            <span>${errorPasswordConfirm}</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="msg-help">半角8~32桁。英大小文字、数字、記号のうち2種類以上。</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- セキュリティコード -->
            <div class="input-group">
                <label class="input-label">セキュリティコード</label>
                <input type="text" name="securityCode" value="${not empty securityCode ? securityCode : ''}" placeholder="1126" required maxlength="4">
                
                <c:choose>
                    <c:when test="${not empty errorSecurityCode}">
                        <div class="msg-error">
                            <img src="${pageContext.request.contextPath}/image/system/エラー.svg">
                            <span>${errorSecurityCode}</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="msg-help">4桁の数字のみ。</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <button type="submit">新規登録</button>
        </form>
    </div>
</body>
</html>