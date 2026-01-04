package servlet.order;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.OrderHome;
import control.order.OrderHomeResult;
import modelUtil.Cart;

@WebServlet("/OrderHome")
public class OrderHomeServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // カートのセッション確認（なければ作成）
        HttpSession session = request.getSession();
        if (session.getAttribute("cart") == null) {
            session.setAttribute("cart", new Cart());
        }

        // Control呼び出し
        String category = request.getParameter("category");
        OrderHome control = new OrderHome();
        OrderHomeResult result = control.execute(category);

        // ResultをセットしてJSPへ
        request.setAttribute("menuResult", result);
        request.getRequestDispatcher("/WEB-INF/order/menu.jsp").forward(request, response);
    }
}