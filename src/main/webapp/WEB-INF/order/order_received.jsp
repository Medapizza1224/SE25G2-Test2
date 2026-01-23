<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="3;URL=${pageContext.request.contextPath}/OrderHome">
    <title>注文受理</title>
    <style>
        body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f5f5f5; }
        .card { background: white; padding: 40px; border-radius: 20px; text-align: center; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <div class="card">
        <div style="font-size:50px; color:#4CAF50;">✓</div>
        <h2>注文を承りました</h2>
        <p>料理到着までしばらくお待ちください。</p>
        <p style="font-size:12px; color:#999;">3秒後にメニューへ戻ります...</p>
    </div>
</body>
</html>