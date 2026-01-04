package servlet.order;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import control.order.TableInitControl;
import modelUtil.Failure;

@WebServlet("/Order") // URLマッピングはそのまま
public class TableInitServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 画面表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
    }

    // 設定処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // フォームから値を取得
        String user = request.getParameter("adminName");
        String pass = request.getParameter("password");
        String tableNum = request.getParameter("tableNumber");

        try {
            // コントロール実行 (DB認証 + 形式チェック)
            TableInitControl control = new TableInitControl();
            control.execute(user, pass, tableNum);

            // -------------------------------------------------
            // 成功時の処理
            // -------------------------------------------------
            
            // 古いセッションがあれば破棄し、新しく作り直す（セキュリティ対策）
            HttpSession session = request.getSession();
            session.invalidate();
            session = request.getSession(true);
            
            // テーブル番号をセッションに保存
            session.setAttribute("tableNumber", tableNum);

            // 次の「人数選択画面」へリダイレクト
            response.sendRedirect(request.getContextPath() + "/CustomerCount");

        } catch (Failure e) {
            // 入力ミスや認証失敗の場合
            request.setAttribute("error", e.getMessage());
            // 入力値を保持してあげる（パスワード以外）
            request.setAttribute("adminName", user);
            request.setAttribute("tableNumber", tableNum);
            
            request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
            
        } catch (Exception e) {
            // DBエラーなどのシステム障害
            e.printStackTrace();
            request.setAttribute("error", "システムエラーが発生しました");
            request.getRequestDispatcher("/WEB-INF/order/table_init.jsp").forward(request, response);
        }
    }
}