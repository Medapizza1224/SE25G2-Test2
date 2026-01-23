package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.TerminalAdminDao;

@WebServlet("/Order")
public class TableInitServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // すでに認証済みなら設定画面へ
        if (session != null && session.getAttribute("terminalSetupAuth") != null) {
            response.sendRedirect(request.getContextPath() + "/OrderSetup");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("adminName");
        String pass = request.getParameter("password");

        try {
            TerminalAdminDao dao = new TerminalAdminDao();
            if (dao.authenticate(id, pass)) {
                // セッションを新規作成または取得
                HttpSession session = request.getSession(true);
                // ★名前を terminalSetupAuth に統一
                session.setAttribute("terminalSetupAuth", true);
                response.sendRedirect(request.getContextPath() + "/OrderSetup");
            } else {
                request.setAttribute("error", "端末設定用の認証情報が正しくありません");
                request.setAttribute("adminName", id);
                request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500);
        }
    }
}