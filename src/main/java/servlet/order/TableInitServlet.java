package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.TableInitControl;
import control.order.TableInitResult;

@WebServlet("/Order")
public class TableInitServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("adminAuthForSetup") != null) {
            response.sendRedirect("OrderSetup");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("adminName");
        String pass = request.getParameter("password");

        // Control呼び出し
        TableInitControl control = new TableInitControl();
        TableInitResult result = control.execute(name, pass);

        if (result.isSuccess()) {
            HttpSession session = request.getSession(true);
            session.setAttribute("adminAuthForSetup", true);
            response.sendRedirect("OrderSetup");
        } else {
            request.setAttribute("error", result.getErrorMessage());
            request.setAttribute("adminName", name);
            doGet(request, response);
        }
    }
}