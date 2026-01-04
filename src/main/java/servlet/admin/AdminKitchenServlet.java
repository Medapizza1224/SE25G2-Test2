package servlet.admin;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.admin.AdminKitchenControl;
import control.admin.AdminKitchenResult;
import control.admin.AdminKitchenUpdateControl;

@WebServlet("/AdminKitchen")
public class AdminKitchenServlet extends HttpServlet {
    
    // 画面表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        AdminKitchenControl control = new AdminKitchenControl();
        AdminKitchenResult result = control.execute();
        
        request.setAttribute("result", result);
        request.getRequestDispatcher("/WEB-INF/admin/kitchen.jsp").forward(request, response);
    }

    // 提供完了処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String itemId = request.getParameter("orderItemId");
        
        AdminKitchenUpdateControl control = new AdminKitchenUpdateControl();
        control.execute(itemId);
        
        response.sendRedirect("AdminKitchen");
    }
}