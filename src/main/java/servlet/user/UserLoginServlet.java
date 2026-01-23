package servlet.user;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.user.UserLogin;
import control.user.UserLoginResult;
import modelUtil.Failure;

@WebServlet("/User")
public class UserLoginServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if ("logout".equals(request.getParameter("action"))) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.removeAttribute("user");
            }
            response.sendRedirect(request.getContextPath() + "/User");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/user/user_signin.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String pass = request.getParameter("password");
        try {
            UserLogin control = new UserLogin();
            UserLoginResult result = control.execute(name, pass);
            HttpSession session = request.getSession();
            session.setAttribute("user", result.getUser());
            response.sendRedirect(request.getContextPath() + "/user_home");
        } catch (Failure e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/user/user_signin.jsp").forward(request, response);
        }
    }
}