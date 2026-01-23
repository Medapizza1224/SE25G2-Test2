package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.OrderRegisterControl;
import control.order.OrderRegisterResult;
import entity.Order;
import modelUtil.Cart;

@WebServlet("/OrderSubmit")
public class OrderSubmitServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("order");
        Cart cart = (Cart) session.getAttribute("cart");

        if (session.getAttribute("tableNumber") == null) {
            response.sendRedirect(request.getContextPath() + "/Order");
            return;
        }

        OrderRegisterControl control = new OrderRegisterControl();
        OrderRegisterResult result = control.execute(order, cart);

        if (result.isSuccess()) {
            cart.clear();
            // ★修正: OrderComplete ではなく、新設する OrderReceived へ遷移
            response.sendRedirect(request.getContextPath() + "/OrderReceived");
        } else {
            request.setAttribute("errorTitle", "注文エラー");
            request.setAttribute("errorMessage", result.getMessage());
            request.setAttribute("nextUrl", "/OrderHome");
            request.setAttribute("nextLabel", "メニューへ戻る");
            request.getRequestDispatcher("/WEB-INF/common_error.jsp").forward(request, response);
        }
    }
}