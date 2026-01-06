package servlet.admin;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import control.admin.AdminLoginControl;
import control.admin.AdminLoginResult;
import modelUtil.Failure;

@WebServlet("/Admin")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // GET: ログイン画面の表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // すでにログイン済みならメニューへ飛ばす等の処理をここに書いてもよい
        request.getRequestDispatcher("/WEB-INF/admin/admin_login.jsp").forward(request, response);
    }

    // POST: ログイン処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String adminName = request.getParameter("adminName");
        String password = request.getParameter("password");

        try {
            // コントロールの実行
            AdminLoginControl control = new AdminLoginControl();
            AdminLoginResult result = control.execute(adminName, password);

            // 認証成功：セッションに保存
            HttpSession session = request.getSession();
            session.setAttribute("adminNameManagement", result.getAdmin());

            // キッチン画面（または管理者トップ）へリダイレクト
            response.sendRedirect(request.getContextPath() + "/AdminKitchen");

        } catch (Failure e) {
            // 認証失敗（バリデーションエラー含む）
            request.setAttribute("error", e.getMessage());
            request.setAttribute("adminName", adminName); // 入力値を保持
            request.getRequestDispatcher("/WEB-INF/admin/admin_login.jsp").forward(request, response);
            
        } catch (Exception e) {
            // システムエラー
            e.printStackTrace();
            request.setAttribute("error", "システムエラーが発生しました");
            request.getRequestDispatcher("/WEB-INF/admin/admin_login.jsp").forward(request, response);
        }
    }
}