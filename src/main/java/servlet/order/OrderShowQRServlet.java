package servlet.order;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.OrderShowQR;
import control.order.OrderShowQRResult;
import entity.Order;

@WebServlet("/ShowQr")
public class OrderShowQRServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("order");

        // ベースURLの構築
        String baseUrl = request.getScheme() + "://" + request.getServerName() 
                        + ":" + request.getServerPort() + request.getContextPath();

        OrderShowQR control = new OrderShowQR();
        OrderShowQRResult result = control.execute(order, baseUrl);

        request.setAttribute("qrResult", result);
        request.getRequestDispatcher("/WEB-INF/order/payment_qr.jsp").forward(request, response);
    }
}