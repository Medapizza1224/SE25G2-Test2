package servlet.order;

import java.io.IOException;
import java.util.ArrayList;
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
            // 1. 注文履歴（明細）を取得
            OrderItemDao dao = new OrderItemDao();
            List<OrderItem> items = dao.findByOrderId(order.getOrderId().toString());
            
            // 2. 合計金額を計算（念のため再計算）
            int total = items.stream().mapToInt(i -> i.getPrice() * i.getQuantity()).sum();
            order.setTotalAmount(total); // セッションのOrderも更新しておく
            
            // 3. 決済方法設定を取得
            AppConfig config = AppConfig.load(getServletContext());

            request.setAttribute("items", items);
            request.setAttribute("totalAmount", total);
            request.setAttribute("paymentMethods", config.getPaymentMethods());

            request.getRequestDispatcher("/WEB-INF/order/payment_select.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("OrderHome");
        }
    }
}