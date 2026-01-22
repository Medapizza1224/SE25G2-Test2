package servlet.user;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.UUID;

import control.user.UserPayment;
import control.user.UserPaymentResult;
import entity.User;
import entity.Order;
import dao.OrderDao;
import dao.UserDao;
import modelUtil.Failure;

@WebServlet("/UserPayment")
public class UserPaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * 【画面表示用】
     * 決済画面を表示するための準備を行います。
     * URL例: /UserPayment?orderId=xxxxx-xxxx...
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");
        // 1. ログインチェック
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user_signin");
            return;
        }

        // 2. パラメータ取得
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            // 注文IDがない場合はホームへ戻す等のエラー処理
            response.sendRedirect(request.getContextPath() + "/PaymentSetup");
            return;
        }

        try {
            UUID userId = sessionUser.getUserId();
            UUID orderId = UUID.fromString(orderIdStr);

            // 3. データの準備（DAOを使ってDBから取得）
            
            // A. 最新のユーザー情報を取得（残高・ポイントを表示するため）
            // ※セッションの情報は古い可能性があるため、DBから再取得推奨
            UserDao userDao = new UserDao();
            User latestUser = userDao.findById(userId); 
            
            // B. 注文情報を取得（合計金額を表示するため）
            OrderDao orderDao = new OrderDao();
            Order order = orderDao.findById(orderId);

            // 注文が存在しない、または他人の注文などのチェック
            if (order == null) {
                throw new Failure("注文が見つかりません。");
            }
            if (order.isPaymentCompleted()) {
                throw new Failure("この注文は既に決済済みです。");
            }

            // 4. JSPへの値渡し
            // JSPの ${user.balance}, ${order.totalAmount}, ${orderId} に対応
            request.setAttribute("user", latestUser); // 最新のユーザー情報で上書き
            request.setAttribute("order", order);
            request.setAttribute("orderId", orderIdStr);

            // 5. 画面表示*/
            request.getRequestDispatcher("/WEB-INF/user/user_payment.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            // エラー時はエラー画面へ、またはホームへ
            response.sendRedirect(request.getContextPath() + "/user_home");
        }
    }

    // UserPaymentServlet.java

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/User");
            return;
        }

        String amountStr = request.getParameter("amount");
        String securityCode = request.getParameter("securityCode");
        String orderIdStr = request.getParameter("orderId");

        try {
            UserPayment control = new UserPayment();
            UserPaymentResult result = control.execute(user.getUserId(), orderIdStr, amountStr, securityCode);

            request.setAttribute("result", result);
            request.setAttribute("successMessage", true);
            request.getRequestDispatcher("/WEB-INF/user/user_payment_success.jsp").forward(request, response);

        } catch (Failure e) {
            // ★変更: 共通エラー画面へ遷移（残高不足、セキュリティコード違いなど）
            request.setAttribute("errorMessage", e.getMessage());
            
            // 決済画面に戻れるようにURLを構築
            String nextUrl = "/UserPayment";
            if (orderIdStr != null) {
                nextUrl += "?orderId=" + orderIdStr;
            }
            
            request.setAttribute("nextUrl", nextUrl);
            request.setAttribute("nextLabel", "決済画面へ戻る");
            request.getRequestDispatcher("/WEB-INF/common_error.jsp").forward(request, response);
        }
    }
}