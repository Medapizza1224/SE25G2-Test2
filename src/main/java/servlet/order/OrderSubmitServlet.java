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
            response.sendRedirect(request.getContextPath() + "/OrderComplete");
        } else {
            // ★変更: 共通エラー画面へ遷移
            request.setAttribute("errorMessage", result.getMessage());
            request.setAttribute("nextUrl", "/OrderHome"); // メニューへ戻る
            request.setAttribute("nextLabel", "メニューへ戻る");
            request.getRequestDispatcher("/WEB-INF/common_error.jsp").forward(request, response);
        }
    }
}