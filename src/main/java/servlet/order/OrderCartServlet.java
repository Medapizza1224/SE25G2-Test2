package servlet.order;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.OrderCart;
import control.order.OrderCartResult;
import modelUtil.Cart;

@WebServlet("/OrderCart")
public class OrderCartServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        
        String action = request.getParameter("action");
        String productId = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        OrderCart control = new OrderCart();
        OrderCartResult result = control.execute(cart, action, productId, quantityStr);
        
        response.sendRedirect(result.getRedirectUrl());
    }
}