package servlet.user;

import java.io.IOException;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import control.user.UserPayment;
import control.user.UserPaymentResult;
import dao.OrderDao;
import dao.UserDao;
import entity.Order;
import entity.User;
import modelUtil.Failure;

@WebServlet("/UserPayment")
public class UserPaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");
        
        // 1. ログインチェック
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/User");
            return;
        }

        // 2. パラメータ取得
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/user_home");
            return;
        }

        try {
            UUID userId = sessionUser.getUserId();
            UUID orderId = UUID.fromString(orderIdStr);

            // 3. データの準備
            UserDao userDao = new UserDao();
            User latestUser = userDao.findById(userId); 
            
            // ★修正: ロックアウト時は共通エラー画面へ遷移
            if (latestUser != null && latestUser.isLockout()) {
                session.invalidate(); 
                
                request.setAttribute("errorTitle", "アカウント利用停止");
                request.setAttribute("errorMessage", "お客様のアカウントはセキュリティ上の理由により\n利用が停止（ロック）されています。\n\n解除するには店舗スタッフにお問い合わせください。");
                request.setAttribute("nextUrl", "/User");
                request.setAttribute("nextLabel", "ログイン画面へ");
                
                request.getRequestDispatcher("/WEB-INF/common_error.jsp").forward(request, response);
                return;
            }
            
            OrderDao orderDao = new OrderDao();
            Order order = orderDao.findById(orderId);

            if (order == null) {
                throw new Failure("注文が見つかりません。");
            }
            if (order.isPaymentCompleted()) {
                throw new Failure("この注文は既に決済済みです。");
            }

            request.setAttribute("user", latestUser);
            request.setAttribute("order", order);
            request.setAttribute("orderId", orderIdStr);

            request.getRequestDispatcher("/WEB-INF/user/user_payment.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user_home");
        }
    }

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
            // ★修正: ロックアウト（または重大なエラー）の場合は共通エラー画面へ
            String msg = e.getMessage();
            if (msg != null && (msg.contains("ロックされました") || msg.contains("停止"))) {
                // セッションを破棄してロック画面へ
                session.invalidate();
                request.setAttribute("errorTitle", "アカウント利用停止");
                request.setAttribute("errorMessage", msg); // "3回間違えたため..."などのメッセージを表示
                request.setAttribute("nextUrl", "/User");
                request.setAttribute("nextLabel", "ログイン画面へ");
                request.getRequestDispatcher("/WEB-INF/common_error.jsp").forward(request, response);
                return;
            }

            // 通常のエラー（コード間違い等）は元の画面に戻す
            try {
                UserDao userDao = new UserDao();
                User latestUser = userDao.findById(user.getUserId());
                
                OrderDao orderDao = new OrderDao();
                Order order = orderDao.findById(UUID.fromString(orderIdStr));

                request.setAttribute("user", latestUser);
                request.setAttribute("order", order);
                request.setAttribute("orderId", orderIdStr);
                
                request.setAttribute("paymentError", e.getMessage());
                
                request.getRequestDispatcher("/WEB-INF/user/user_payment.jsp").forward(request, response);
                
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/user_home");
            }
        }
    }
}