package servlet.order;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.OrderRegisterControl;
import control.order.OrderRegisterResult;
import entity.Order;
import modelUtil.Cart;

@WebServlet("/OrderRegister")
public class OrderRegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("order");
        Cart cart = (Cart) session.getAttribute("cart");

        OrderRegisterControl control = new OrderRegisterControl();
        OrderRegisterResult result = control.execute(order, cart);

        if (result.isSuccess()) {
            cart.clear(); // カートを空にする
            response.sendRedirect("OrderHistory"); // 履歴画面へ
        } else {
            // エラー時
            request.setAttribute("errorMessage", result.getMessage());
            request.getRequestDispatcher("/Menu").forward(request, response);
        }
    }
}