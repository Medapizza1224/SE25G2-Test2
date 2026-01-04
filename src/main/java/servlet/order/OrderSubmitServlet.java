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

        OrderRegisterControl control = new OrderRegisterControl();
        OrderRegisterResult result = control.execute(order, cart);

        if (result.isSuccess()) {
            cart.clear(); // カートを空にする
            // 完了画面へリダイレクト
            response.sendRedirect(request.getContextPath() + "/OrderComplete");
        } else {
            // エラー時はメニューへ戻る（エラーメッセージ付き）
            request.setAttribute("errorMessage", result.getMessage());
            request.getRequestDispatcher("/WEB-INF/order/menu.jsp").forward(request, response);
        }
    }
}