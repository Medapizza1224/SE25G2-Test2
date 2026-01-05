package servlet.admin;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import control.admin.AdminUserUnlock;

@WebServlet("/AdminUserUnlock")
public class AdminUserUnlockServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        
        try {
            String userIdStr = request.getParameter("userId");
            
            // ロック解除コントロールを実行
            AdminUserUnlock control = new AdminUserUnlock();
            control.execute(userIdStr);

            // 一覧画面へリダイレクト
            response.sendRedirect(request.getContextPath() + "/AdminUserView");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unlock Error");
        }
    }
}