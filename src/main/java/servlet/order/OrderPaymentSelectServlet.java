package servlet.order;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.OrderItemDao;
import entity.Order;
import entity.OrderItem;
import util.AppConfig;

@WebServlet("/PaymentSelect")
public class OrderPaymentSelectServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("order");

        if (order == null || session.getAttribute("tableNumber") == null) {
            response.sendRedirect("Order");
            return;
        }

        try {
            OrderItemDao dao = new OrderItemDao();
            // ★未提供品があるかチェック
            boolean hasUnserved = dao.hasUnservedItems(order.getOrderId().toString());

            if (hasUnserved) {
                // 未提供がある場合は、警告専用フラグを立ててJSPへ
                request.setAttribute("blockPayment", true);
            } else {
                // すべて提供済みなら通常通りデータ取得
                List<OrderItem> items = dao.findByOrderId(order.getOrderId().toString());
                int total = items.stream().mapToInt(i -> i.getPrice() * i.getQuantity()).sum();
                order.setTotalAmount(total);
                request.setAttribute("items", items);
                request.setAttribute("totalAmount", total);
                request.setAttribute("paymentMethods", AppConfig.load(getServletContext()).getPaymentMethods());
            }

            request.getRequestDispatcher("/WEB-INF/order/payment_select.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("OrderHome");
        }
    }
}