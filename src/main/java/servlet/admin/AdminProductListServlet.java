package servlet.admin;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import control.admin.AdminProductListControl;
import control.admin.AdminProductListResult;

@WebServlet("/AdminProductList")
public class AdminProductListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // セッションチェック
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        // コントローラ実行
        AdminProductListControl control = new AdminProductListControl();
        AdminProductListResult result = control.execute();
        
        // 結果をリクエストスコープにセット
        request.setAttribute("result", result);
        
        // JSPへフォワード
        request.getRequestDispatcher("/WEB-INF/admin/product_list.jsp").forward(request, response);
    }
}