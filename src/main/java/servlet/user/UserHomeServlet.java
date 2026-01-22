package servlet.user;

import java.io.IOException;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.UserDao;
import entity.User;

@WebServlet("/user_home")
public class UserHomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");

        // 1. ログインチェック
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/User");
            return;
        }

        try {
            // 2. 最新のユーザー情報をDBから取得
            // (セッションの情報は古くなっている可能性があるため)
            UserDao dao = new UserDao();
            User latestUser = dao.findById(sessionUser.getUserId());

            if (latestUser != null) {
                // セッション情報も更新しておく
                session.setAttribute("user", latestUser);
                // 表示用にリクエストスコープにもセット
                request.setAttribute("user", latestUser);
            }

            // 3. 画面表示
            request.getRequestDispatcher("/WEB-INF/user/user_home.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            // エラー時はログイン画面へ戻すなどの安全策
            response.sendRedirect(request.getContextPath() + "/User");
        }
    }
}