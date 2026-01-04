<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><title>人数選択</title></head>
<body>
    <h2>人数を選択してください</h2>
    <form action="CustomerCount" method="post">
        大人: <input type="number" name="adult" value="1" min="1" max="8"><br>
        子供: <input type="number" name="child" value="0" min="0" max="7"><br>
        <button type="submit">メニューへ進む</button>
    </form>
</body>
</html>