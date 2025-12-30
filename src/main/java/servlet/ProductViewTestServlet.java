package servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;             // javax -> jakarta
import jakarta.servlet.annotation.WebServlet;        // javax -> jakarta
import jakarta.servlet.http.HttpServlet;             // javax -> jakarta
import jakarta.servlet.http.HttpServletRequest;      // javax -> jakarta
import jakarta.servlet.http.HttpServletResponse; 
import control.ProductViewTest;
import control.ProductViewTestResult;

@WebServlet("/product-list")
public class ProductViewTestServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Controlを呼び出す
        ProductViewTest control = new ProductViewTest();
        ProductViewTestResult result = control.getProductList();

        // 2. 結果をリクエストスコープに入れる
        // JSP側では ${result} としてアクセスできます
        request.setAttribute("result", result);

        // 3. JSPへ表示を依頼
        request.getRequestDispatcher("/WEB-INF/product_view_test.jsp").forward(request, response);
    }
}