package servlet.user;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.UserDao;
import entity.User;
import util.PendingUserStore;

@WebServlet("/UserVerify")
public class UserVerifyServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");

        // トークンを使って一時保存データを取得
        User user = PendingUserStore.getAndRemove(token);

        if (user == null) {
            // トークンが無効または期限切れ
            response.getWriter().write("無効なリンクです。");
            return;
        }

        try {
            // ★DBに正式登録
            UserDao dao = new UserDao();
            dao.register(user); // ※UserDaoに追加が必要

            // 登録完了画面へ
            request.setAttribute("user", user);
            request.getRequestDispatcher("/WEB-INF/user/user_verify_success.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("登録処理に失敗しました。");
        }
    }
}