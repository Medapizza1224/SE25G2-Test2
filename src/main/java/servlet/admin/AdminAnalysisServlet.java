package servlet.admin;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.admin.AdminAnalysisControl;
import control.admin.AdminAnalysisResult;

@WebServlet("/AdminAnalysis")
public class AdminAnalysisServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // セッションチェック
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }
        
        String type = request.getParameter("type");
        
        AdminAnalysisControl control = new AdminAnalysisControl();
        AdminAnalysisResult result = control.execute(type);
        
        request.setAttribute("result", result);
        request.getRequestDispatcher("/WEB-INF/admin/analysis.jsp").forward(request, response);
    }
}