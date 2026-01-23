<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="util.AppConfig" %>
<%
    AppConfig conf = AppConfig.load(application);
    request.setAttribute("conf", conf);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>お会計完了</title>
    <style>
        :root { --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'}; }
        body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f5f5f5; }
        .card { background: white; padding: 60px 40px; border-radius: 24px; text-align: center; box-shadow: 0 10px 25px rgba(0,0,0,0.05); width: 80%; max-width: 600px; }
        #cleaning-area { margin-top: 40px; padding: 25px; border: 2px dashed var(--main-color); border-radius: 15px; background: #fff5f0; display: none; }
        .btn { background: #000; color: #fff; padding: 15px 40px; border: none; border-radius: 30px; font-weight: bold; font-size: 18px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="card">
        <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" style="height:40px; margin-bottom:30px;">
        <div style="font-size:60px; margin-bottom:20px;">😊</div>
        <h2>お会計が完了しました</h2>
        <p>ご来店誠にありがとうございました。<br>またのお越しをお待ちしております。</p>

        <div id="cleaning-area">
            <p style="color:#e65e00; font-weight:bold; margin-bottom:15px;">【店員用操作】清掃完了確認</p>
            <form action="${pageContext.request.contextPath}/OrderReset" method="post">
                <button type="submit" class="btn">清掃完了（次のお客様を迎える）</button>
            </form>
        </div>
    </div>
    <script>
        // 10秒経過後に清掃完了ボタンを表示
        setTimeout(() => {
            document.getElementById('cleaning-area').style.display = 'block';
        }, 10000);
    </script>
</body>
</html>