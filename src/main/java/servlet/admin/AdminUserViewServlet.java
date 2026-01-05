package servlet.admin;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import control.admin.AdminUserView;
import control.admin.AdminUserViewResult;

@WebServlet("/AdminUserView")
public class AdminUserViewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        
        try {
            // コントローラを実行して結果を取得
            AdminUserView control = new AdminUserView();
            AdminUserViewResult result = control.execute();

            // JSPへ渡す
            request.setAttribute("result", result);
            
            // パスはプロジェクト構成に合わせてください
            request.getRequestDispatcher("/WEB-INF/admin/admin_user.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Admin Error");
        }
    }
}