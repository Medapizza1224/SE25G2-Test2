<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="control.ProductViewTestResult" %>
<%@ page import="entity.Product" %>
<%@ page import="java.util.List" %>
<%
    ProductViewTestResult result = (ProductViewTestResult) request.getAttribute("result");
    List<Product> list = null;
    
    if (result != null) {
        list = result.getProductList();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>商品一覧</title>
    <style>
        body {
            font-family: sans-serif; padding: 20px;
        }
        .error {
            color: red; font-weight: bold;
        }
        table {
            width: 100%; border-collapse: collapse; margin-top: 15px;
        }
        th, td {
            border: 1px solid #ddd; padding: 10px; text-align: left;
        }
        th {
            background-color: #f4f4f4;
        }
        .price {
            text-align: right;
        }
    </style>
</head>
<body>
    <h2>商品メニュー一覧</h2>

    <%-- 失敗した場合のエラーメッセージ表示 --%>
    <% if (!result.isSuccess()) { %>
        <p class="error"><%= result.getErrorMessage() %></p>
    <% } %>

    <%-- データがある場合のみテーブル表示 --%>
    <% if (result.isSuccess() && list.size() > 0) { %>
        <table>
            <thead>
                <tr>
                    <th style="width: 10%;">ID</th>
                    <th style="width: 15%;">画像</th> <!-- 画像列 -->
                    <th style="width: 25%;">商品名</th>
                    <th style="width: 15%;">カテゴリ</th>
                    <th style="width: 10%;">価格</th>
                    <th style="width: 10%;">状況</th>
                    <th style="width: 15%;">更新日時</th>
                </tr>
            </thead>
            <tbody>
                <% for (Product p : list) { %>
                <tr>
                    <td><%= p.getProductId() %></td>
                    
                    <!-- 画像表示ロジック -->
                    <td style="text-align: center;">
                        <% if(p.getImage() != null && !p.getImage().isEmpty()) { %>
                            <%-- 画像ファイル名がある場合: /image/product/ファイル名 を参照 --%>
                            <img src="${pageContext.request.contextPath}/image/product/<%= p.getImage() %>" 
                                 alt="<%= p.getProductName() %>" 
                                 width="80" height="80" class="product-img">
                        <% } else { %>
                            <%-- 画像がない場合 --%>
                            <span class="no-image">No Image</span>
                        <% } %>
                    </td>

                    <td><%= p.getProductName() %></td>
                    <td><%= p.getCategory() %></td>
                    <td class="price"><%= String.format("%,d", p.getPrice()) %> 円</td>
                    
                    <!-- 販売状況ロジック -->
                    <td style="text-align: center;">
                        <% if("ON_SALE".equals(p.getSalesStatus())) { %>
                            <span class="status-on">販売中</span>
                        <% } else { %>
                            <span class="status-off">売切</span>
                        <% } %>
                    </td>
                    
                    <td><%= p.getUpdateAt() %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    <% } else if (result.isSuccess()) { %>
        <p>登録されている商品はありません。</p>
    <% } %>

</body>
</html>