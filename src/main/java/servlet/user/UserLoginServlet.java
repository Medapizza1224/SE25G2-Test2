package servlet.user;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import control.user.UserLogin;
import control.user.UserLoginResult;
import modelUtil.Failure;

@WebServlet("/user_signin")
public class UserLoginServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/user/user_signin.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String pass = request.getParameter("password");

        try {
            UserLogin control = new UserLogin();
            UserLoginResult result = control.execute(name, pass);

            // セッションにユーザーを保存
            HttpSession session = request.getSession();
            session.setAttribute("user", result.getUser());

            // ホーム画面へリダイレクト
            response.sendRedirect(request.getContextPath() + "/user_home");

        } catch (Failure e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/user/user_signin.jsp").forward(request, response);
        }
    }
}