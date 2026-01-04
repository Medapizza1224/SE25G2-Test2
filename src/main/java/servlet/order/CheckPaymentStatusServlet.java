package servlet.order;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.OrderDao;
import entity.Order;

@WebServlet("/CheckPaymentStatus")
public class CheckPaymentStatusServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String orderIdStr = request.getParameter("orderId");
        boolean isPaid = false;

        if (orderIdStr != null) {
            try {
                OrderDao dao = new OrderDao();
                Order order = dao.findById(UUID.fromString(orderIdStr));
                if (order != null) {
                    isPaid = order.isPaymentCompleted();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // JSON形式で返す {"isPaid": true}
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"isPaid\": " + isPaid + "}");
        out.flush();
    }
}