package servlet.user;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import control.user.UserCharge;
import control.user.UserChargeResult;
import dao.UserDao;
import entity.User;
import modelUtil.Failure;

@WebServlet("/UserCharge")
public class UserChargeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 画面表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        // セッションチェック
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/User");
            return;
        }
        
        User sessionUser = (User) session.getAttribute("user");

        try {
            // 最新の残高を表示するために取得
            UserDao dao = new UserDao();
            User latestUser = dao.findById(sessionUser.getUserId());
            request.setAttribute("user", latestUser);
            
            request.getRequestDispatcher("/WEB-INF/user/user_charge.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user_home");
        }
    }

    // チャージ実行
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        
        // セッションチェック
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/User");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        String amountStr = request.getParameter("amount");
        
        try {
            UserCharge control = new UserCharge();
            UserChargeResult result = control.execute(sessionUser.getUserId(), amountStr);

            // セッション情報を更新
            sessionUser.setBalance(result.getNewBalance()); 
            session.setAttribute("user", sessionUser);
            
            // --- ★ここから修正: 戻り先のURLを動的に決定 ---
            String returnTo = request.getParameter("returnTo");
            String orderId = request.getParameter("orderId");
            String nextUrl;
            String nextLabel;

            if ("payment".equals(returnTo) && orderId != null && !orderId.isEmpty()) {
                // 決済画面から来た場合 -> 決済画面へ戻す
                nextUrl = request.getContextPath() + "/UserPayment?orderId=" + orderId;
                nextLabel = "決済画面に戻る";
            } else {
                // 通常 -> ホームへ
                nextUrl = request.getContextPath() + "/user_home";
                nextLabel = "ホームに戻る";
            }

            request.setAttribute("result", result);
            request.setAttribute("nextUrl", nextUrl);     // 自動遷移・ボタン用URL
            request.setAttribute("nextLabel", nextLabel); // ボタンのラベル

            request.getRequestDispatcher("/WEB-INF/user/user_charge_complete.jsp").forward(request, response);
            // --- ★修正ここまで ---

        } catch (Failure e) {
            // エラー時: 共通エラー画面へ遷移
            request.setAttribute("errorTitle", "注文エラー");
            request.setAttribute("errorMessage", e.getMessage());
            
            // エラーから戻る際も、パラメータを維持できるようにURLを構築
            String returnTo = request.getParameter("returnTo");
            String orderId = request.getParameter("orderId");
            String errorReturnUrl = "/UserCharge";
            
            if (returnTo != null) {
                errorReturnUrl += "?returnTo=" + returnTo;
                if (orderId != null) {
                    errorReturnUrl += "&orderId=" + orderId;
                }
            }

            request.setAttribute("nextUrl", errorReturnUrl); // チャージ画面へ戻る
            request.setAttribute("nextLabel", "チャージ画面へ戻る");
            request.getRequestDispatcher("/WEB-INF/common_error.jsp").forward(request, response);
        }
    }
}