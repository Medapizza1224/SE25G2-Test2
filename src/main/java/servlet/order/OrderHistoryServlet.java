package servlet.order;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.OrderHistory;
import control.order.OrderHistoryResult;
import entity.Order;

@WebServlet("/OrderHistory")
public class OrderHistoryServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("order");

        OrderHistory control = new OrderHistory();
        OrderHistoryResult result = control.execute(order);

        request.setAttribute("historyResult", result);
        request.getRequestDispatcher("/WEB-INF/order/order_history.jsp").forward(request, response);
    }
}