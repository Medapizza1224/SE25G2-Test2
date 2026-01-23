package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.OrderItemDao;
import control.order.OrderShowQR;
import control.order.OrderShowQRResult;
import entity.Order;

@WebServlet("/ShowQr")
public class OrderShowQRServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("order");

        if (order == null) {
            response.sendRedirect("OrderHome");
            return;
        }

        try {
            // 二重チェック：未提供品があれば戻す
            OrderItemDao dao = new OrderItemDao();
            if (dao.hasUnservedItems(order.getOrderId().toString())) {
                response.sendRedirect("PaymentSelect");
                return;
            }

            String baseUrl = request.getScheme() + "://" + request.getServerName() 
                            + ":" + request.getServerPort() + request.getContextPath();

            OrderShowQR control = new OrderShowQR();
            OrderShowQRResult result = control.execute(order, baseUrl);

            request.setAttribute("qrResult", result);
            request.getRequestDispatcher("/WEB-INF/order/payment_qr.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("OrderHome");
        }
    }
}