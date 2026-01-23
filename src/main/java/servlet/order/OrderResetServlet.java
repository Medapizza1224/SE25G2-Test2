package servlet.order;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/OrderReset")
public class OrderResetServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String tableNo = (String) session.getAttribute("tableNumber");
            // ★ terminalSetupAuth を確実に引き継ぐ
            Object terminalAuth = session.getAttribute("terminalSetupAuth");
            
            session.removeAttribute("order");
            session.removeAttribute("cart");
            
            session.setAttribute("tableNumber", tableNo);
            session.setAttribute("terminalSetupAuth", terminalAuth);
        }
        response.sendRedirect(request.getContextPath() + "/CustomerCount");
    }
}