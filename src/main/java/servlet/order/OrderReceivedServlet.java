package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/OrderReceived")
public class OrderReceivedServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 注文を受け付けた旨を表示するJSP（新設）へ
        request.getRequestDispatcher("/WEB-INF/order/order_received.jsp").forward(request, response);
    }
}