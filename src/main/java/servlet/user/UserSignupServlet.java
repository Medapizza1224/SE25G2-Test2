package servlet.user;

import java.io.IOException;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import entity.User;
import util.MailUtil;
import util.PendingUserStore;

@WebServlet("/user_signup")
public class UserSignupServlet extends HttpServlet {
    
    // 入力画面表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/user/user_signup.jsp").forward(request, response);
    }

    // フォーム送信処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String securityCode = request.getParameter("securityCode");

        // 簡易バリデーション
        if (email == null || password == null || securityCode == null) {
            request.setAttribute("error", "全ての項目を入力してください");
            doGet(request, response);
            return;
        }

        try {
            // ユーザーオブジェクトを一時作成（まだDBには入れない）
            User user = new User();
            user.setUserId(UUID.randomUUID()); // 新しいID
            user.setUserName(email);           // ユーザー名はメールアドレス
            user.setUserPassword(password);    // 平文保存
            user.setSecurityCode(securityCode); // 平文保存(前回の要件通り)
            user.setBalance(10000);            // 初回特典: 残高1万円
            user.setPoint(0);
            user.setLoginAttemptCount(0);
            user.setLockout(false);

            // 認証用トークン生成
            String token = UUID.randomUUID().toString();

            // メモリに一時保存
            PendingUserStore.add(token, user);

            // 認証URL作成
            String baseUrl = request.getScheme() + "://" + request.getServerName() 
                           + ":" + request.getServerPort() + request.getContextPath();
            String authUrl = baseUrl + "/UserVerify?token=" + token;

            // メール送信
            MailUtil.sendAuthMail(email, authUrl);

            // 「メールを確認してください」画面へ
            request.getRequestDispatcher("/WEB-INF/user/user_signup_sent.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "メール送信に失敗しました: " + e.getMessage());
            doGet(request, response);
        }
    }
}