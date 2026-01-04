package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.TableInitControl;
import modelUtil.Failure;

@WebServlet("/Order") //AdminTableInit
public class TableInitServlet extends HttpServlet {
    // 画面表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
    }

    // 設定処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String user = request.getParameter("adminName");
        String pass = request.getParameter("password");
        String tableNum = request.getParameter("tableNumber");

        try {
            TableInitControl control = new TableInitControl();
            control.execute(user, pass, tableNum);

            // 認証OKなら、既存セッションを破棄して新しくテーブル番号を保存
            HttpSession session = request.getSession();
            session.invalidate();
            session = request.getSession(true);
            session.setAttribute("tableNumber", tableNum);

            // 次の「人数選択画面」へリダイレクト
            response.sendRedirect(request.getContextPath() + "/CustomerCount");

        } catch (Failure e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
        }
    }
}