package servlet.user;

import java.io.IOException;
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
        // キャッシュ無効化
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/User");
            return;
        }

        try {
            UserDao dao = new UserDao();
            User latestUser = dao.findById(sessionUser.getUserId());

            if (latestUser != null) {
                // ★修正: ロックアウト時は共通エラー画面へ遷移
                if (latestUser.isLockout()) {
                    session.invalidate(); // 強制ログアウト

                    request.setAttribute("errorTitle", "アカウント利用停止");
                    request.setAttribute("errorMessage", "お客様のアカウントはセキュリティ上の理由により\n利用が停止（ロック）されています。\n\n解除するには店舗スタッフにお問い合わせください。");
                    request.setAttribute("nextUrl", "/User");
                    request.setAttribute("nextLabel", "ログイン画面へ");
                    
                    request.getRequestDispatcher("/WEB-INF/common_error.jsp").forward(request, response);
                    return;
                }

                session.setAttribute("user", latestUser);
                request.setAttribute("user", latestUser);
            }

            request.getRequestDispatcher("/WEB-INF/user/user_home.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/User");
        }
    }
}