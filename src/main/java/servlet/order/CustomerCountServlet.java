
package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.CustomerCountControl;
import entity.Order;
import modelUtil.Failure;

@WebServlet("/CustomerCount")
public class CustomerCountServlet extends HttpServlet {
    // 画面表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        // テーブル番号が未設定なら初期設定へ戻す
        if (session.getAttribute("tableNumber") == null) {
            response.sendRedirect("Order"); //AdminTableInit
            return;
        }
        request.getRequestDispatcher("/WEB-INF/order/customer_count.jsp").forward(request, response);
    }

    // 登録処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String tableNumber = (String) session.getAttribute("tableNumber");
        String adult = request.getParameter("adult");
        String child = request.getParameter("child");

        try {
            CustomerCountControl control = new CustomerCountControl();
            // DB保存実行
            Order order = control.execute(tableNumber, adult, child);
            
            // 作成された伝票情報をセッションに保存（以降の注文で使用）
            session.setAttribute("order", order);
            
            // メニュー画面へ
            response.sendRedirect("OrderHome");

        } catch (Failure e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        }
    }
}