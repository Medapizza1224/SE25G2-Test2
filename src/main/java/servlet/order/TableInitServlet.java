package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.AdminDao;
import entity.Admin;

@WebServlet("/Order")
public class TableInitServlet extends HttpServlet {
    
    // ログイン画面表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // すでに認証済みならセットアップ画面へ
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("adminAuthForSetup") != null) {
            response.sendRedirect("OrderSetup");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
    }

    // ログイン処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("adminName");
        String pass = request.getParameter("password");

        try {
            AdminDao dao = new AdminDao();
            Admin admin = dao.findByLogin(name, pass);

            if (admin != null) {
                // 認証OK -> セッションにフラグを立ててセットアップ画面へ
                HttpSession session = request.getSession(true);
                session.setAttribute("adminAuthForSetup", true);
                response.sendRedirect("OrderSetup");
            } else {
                request.setAttribute("error", "管理者名またはパスワードが違います");
                request.setAttribute("adminName", name);
                doGet(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "システムエラーが発生しました");
            doGet(request, response);
        }
    }
}