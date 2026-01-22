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

@WebServlet("/User")
public class UserLoginServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if ("logout".equals(request.getParameter("action"))) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate(); // セッション破棄
            }
            // ログイン画面へリダイレクト（URLパラメータを消すため）
            response.sendRedirect(request.getContextPath() + "/User");
            return;
        }
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
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
            // ★変更: 共通エラー画面へ遷移
            request.setAttribute("errorMessage", e.getMessage());
            request.setAttribute("nextUrl", "/User"); // 戻る先
            request.setAttribute("nextLabel", "ログイン画面へ戻る");
            request.getRequestDispatcher("/WEB-INF/common_error.jsp").forward(request, response);
        }
    }
}