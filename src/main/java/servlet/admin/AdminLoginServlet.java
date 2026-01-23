package servlet.admin;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.admin.AdminLoginControl;
import control.admin.AdminLoginResult;

@WebServlet("/Admin")
public class AdminLoginServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if ("logout".equals(request.getParameter("action"))) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.removeAttribute("adminNameManagement");
            }
            response.sendRedirect(request.getContextPath() + "/Admin");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/admin/admin_login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String adminName = request.getParameter("adminName");
        String password = request.getParameter("password");
        try {
            AdminLoginControl control = new AdminLoginControl();
            AdminLoginResult result = control.execute(adminName, password);
            HttpSession session = request.getSession(true);
            session.setAttribute("adminNameManagement", result.getAdmin());
            response.sendRedirect(request.getContextPath() + "/AdminKitchen");
        } catch (Exception e) {
            request.setAttribute("error", "管理者用IDまたはパスワードが違います");
            request.getRequestDispatcher("/WEB-INF/admin/admin_login.jsp").forward(request, response);
        }
    }
}