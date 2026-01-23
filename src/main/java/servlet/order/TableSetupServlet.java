package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.TableSetupControl;
import control.order.TableSetupResult;
import entity.Order;
import modelUtil.Cart;
import modelUtil.Failure;

@WebServlet("/OrderSetup")
public class TableSetupServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // ★ adminAuthForSetup から terminalSetupAuth に変更
        if (session == null || session.getAttribute("terminalSetupAuth") == null) {
            response.sendRedirect("Order");
            return;
        }

        try {
            TableSetupControl control = new TableSetupControl();
            TableSetupResult result = control.getInitData();
            request.setAttribute("result", result);
            request.getRequestDispatcher("/WEB-INF/order/table_setup.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("terminalSetupAuth") == null) {
            response.sendRedirect("Order");
            return;
        }

        String action = request.getParameter("action");
        TableSetupControl control = new TableSetupControl();

        try {
            if ("new".equals(action)) {
                String tableNum = request.getParameter("tableNumber");
                control.checkNewTable(tableNum);

                // セッションを一度リセット（ただし管理セッションを消さないよう属性削除で対応）
                String adminMgmt = (String) session.getAttribute("adminNameManagement");
                Object setupAuth = session.getAttribute("terminalSetupAuth");
                
                session.removeAttribute("tableNumber");
                session.removeAttribute("order");
                session.removeAttribute("cart");
                
                // 必要情報を再セット
                session.setAttribute("tableNumber", tableNum);
                session.setAttribute("terminalSetupAuth", setupAuth);
                if (adminMgmt != null) session.setAttribute("adminNameManagement", adminMgmt);
                
                response.sendRedirect("CustomerCount");

            } else if ("recover".equals(action)) {
                String orderId = request.getParameter("orderId");
                Order order = control.recoverOrder(orderId);

                session.setAttribute("tableNumber", order.getTableNumber());
                session.setAttribute("order", order);
                session.setAttribute("cart", new Cart());

                response.sendRedirect("OrderHome");
            }
        } catch (Failure e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            doGet(request, response);
        }
    }
}