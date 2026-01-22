package servlet;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.DBInspectorControl;
import control.DBInspectorResult;

@WebServlet("/db-inspector")
public class DBInspectorServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 独立したシステムツールとして動作させるため、セッションチェックは行わない
        DBInspectorControl control = new DBInspectorControl();
        DBInspectorResult result = control.execute();

        request.setAttribute("result", result);
        request.getRequestDispatcher("/WEB-INF/db_inspector.jsp").forward(request, response);
    }
}