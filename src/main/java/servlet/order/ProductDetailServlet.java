package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.ProductDao;
import entity.Product;

@WebServlet("/ProductDetail")
public class ProductDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String productId = request.getParameter("id");
        
        try {
            ProductDao dao = new ProductDao();
            Product p = dao.findById(productId);
            
            if (p == null) {
                // 商品が見つからない場合はホームへ戻る
                response.sendRedirect(request.getContextPath() + "/OrderHome");
                return;
            }

            request.setAttribute("product", p);
            request.getRequestDispatcher("/WEB-INF/order/product_detail.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "システムエラーが発生しました");
        }
    }
}