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
        User sessionUser = (User) session.getAttribute("user");
        
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/user_signin");
            return;
        }

        String amountStr = request.getParameter("amount");
        
        try {
            // ★変更点: Controlクラス経由で実行
            UserCharge control = new UserCharge();
            UserChargeResult result = control.execute(sessionUser.getUserId(), amountStr);

            // 成功時: セッションの残高情報を更新
            sessionUser.setBalance(result.getNewBalance()); 
            session.setAttribute("user", sessionUser);
            
            // 結果をリクエストスコープに入れて完了画面へ
            request.setAttribute("result", result);
            request.getRequestDispatcher("/WEB-INF/user/user_charge_complete.jsp").forward(request, response);

        } catch (Failure e) {
            // 失敗時: エラーメッセージを表示して入力画面に戻る
            request.setAttribute("error", e.getMessage());
            // 入力画面の再表示 (doGetと同じ処理をしてデータを渡す)
            doGet(request, response);
        }
    }
}