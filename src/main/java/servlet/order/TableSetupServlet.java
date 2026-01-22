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

    // 設定画面表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 認証チェック
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminAuthForSetup") == null) {
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
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // 開始・復旧処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        // 認証チェック
        if (session == null || session.getAttribute("adminAuthForSetup") == null) {
            response.sendRedirect("Order");
            return;
        }

        String action = request.getParameter("action");
        TableSetupControl control = new TableSetupControl();

        try {
            if ("new".equals(action)) {
                // --- 新規開始 ---
                String tableNum = request.getParameter("tableNumber");
                
                // チェック実行
                control.checkNewTable(tableNum);

                // セッションをクリアして再作成（前の情報を消す）
                session.invalidate();
                session = request.getSession(true);
                
                // テーブル番号をセットして人数選択へ
                session.setAttribute("tableNumber", tableNum);
                response.sendRedirect("CustomerCount");

            } else if ("recover".equals(action)) {
                // --- 復旧 ---
                String orderId = request.getParameter("orderId");
                
                // 注文情報取得
                Order order = control.recoverOrder(orderId);

                // セッションをクリアして再作成
                session.invalidate();
                session = request.getSession(true);

                // 情報を復元
                session.setAttribute("tableNumber", order.getTableNumber());
                session.setAttribute("order", order); // 確定済みOrder
                session.setAttribute("cart", new Cart()); // カートは空で開始

                // メニュー画面へ直行（人数選択はスキップ）
                response.sendRedirect("OrderHome");
            }

        } catch (Failure e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response); // 画面再表示
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "システムエラー");
            doGet(request, response);
        }
    }
}