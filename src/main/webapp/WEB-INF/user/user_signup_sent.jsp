<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>送信完了</title>
    <style>
        body { 
            font-family: "Helvetica Neue", Arial, sans-serif; 
            background-color: #fff;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: #333;
        }
        .container { 
            width: 100%;
            max-width: 360px;
            padding: 40px 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        
        .mail-icon {
            font-size: 80px;
            margin-bottom: 30px;
            animation: float 2s ease-in-out infinite;
        }
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
            100% { transform: translateY(0px); }
        }

        h2 { 
            font-size: 24px; 
            font-weight: bold;
            margin-bottom: 20px; 
        }
        p {
            font-size: 15px;
            line-height: 1.8;
            color: #666;
            margin-bottom: 50px;
        }
        
        /* 黒いボタン */
        .btn {
            display: block;
            width: 100%;
            padding: 16px 0;
            background-color: #000; /* 黒 */
            color: #fff;
            text-decoration: none;
            border-radius: 30px;
            font-weight: bold;
            font-size: 16px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            transition: opacity 0.2s, transform 0.1s;
        }
        .btn:hover { opacity: 0.8; }
        .btn:active { transform: scale(0.98); }
        
    </style>
</head>
<body>
    <div class="container">
        
        <div class="mail-icon">📩</div>

        <h2>確認メールを送信しました</h2>
        
        <p>
            ご入力いただいたアドレス宛に認証用メールを送信しました。<br>
            メール内のリンクをクリックして登録を完了させてください。
        </p>
        
        <a href="${pageContext.request.contextPath}/User" class="btn">ログイン画面へ戻る</a>
    </div>
</body>
</html>