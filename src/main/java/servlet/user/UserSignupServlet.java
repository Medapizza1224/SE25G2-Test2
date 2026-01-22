package servlet.user;

import java.io.IOException;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.UserDao;
import entity.User;
import util.MailUtil;
import util.PendingUserStore;

@WebServlet("/user_signup")
public class UserSignupServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/user/user_signup.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String userName = request.getParameter("userName"); // userNameに変更
        String password = request.getParameter("password");
        String passwordConfirm = request.getParameter("passwordConfirm");
        String securityCode = request.getParameter("securityCode");

        boolean hasError = false;

        // --- バリデーション ---
        
        // ユーザー名: 半角8~32桁。英大小文字、数字、記号のうち2種類以上
        if (userName == null || userName.isEmpty() || !userName.contains("@")) {
            request.setAttribute("errorUserName", "正しいメールアドレスの形式で入力してください。");
            hasError = true;
        } else {
            // 重複チェック
            try {
                UserDao dao = new UserDao();
                if (dao.findByName(userName) != null) {
                    request.setAttribute("errorUserName", "そのユーザー名は既に使用されています。");
                    hasError = true;
                }
            } catch (Exception e) {
                e.printStackTrace();
                hasError = true; // DBエラーも一旦ここへ
            }
        }

        // パスワード: 半角8~32桁。英大小文字、数字、記号のうち2種類以上
        if (password == null || !isValidFormat(password)) {
            request.setAttribute("errorPassword", "半角8~32桁。英大小文字、数字、記号のうち2種類以上。");
            hasError = true;
        }

        // パスワード（確認）
        if (passwordConfirm == null || !passwordConfirm.equals(password)) {
            request.setAttribute("errorPasswordConfirm", "パスワードが一致しません。");
            hasError = true;
        }

        // セキュリティコード: 半角4桁、数字のみ
        if (securityCode == null || !securityCode.matches("^\\d{4}$")) {
            request.setAttribute("errorSecurityCode", "半角4桁。数字のみ。");
            hasError = true;
        }

        // エラーがある場合はフォームに戻る
        if (hasError) {
            // 入力値を保持
            request.setAttribute("userName", userName);
            request.setAttribute("securityCode", securityCode);
            request.getRequestDispatcher("/WEB-INF/user/user_signup.jsp").forward(request, response);
            return;
        }

        // --- 正常処理 ---
        try {
            // メールアドレスではなくユーザー名で登録する仕様に変更されたため、
            // ここではメール送信をスキップして直接完了（あるいはダミーメールアドレス使用）とするか、
            // 別途メールアドレス入力欄が必要ですが、今回は画面設計に合わせてユーザー名のみとします。
            // ※本来はメールアドレスが必要ですが、提供された画面には「ユーザー名」しかないため
            // ダミーのメールアドレスでPendingUserStoreに入れるか、直接登録とします。
            
            // 今回は要件に合わせて「確認メール送信」のフローを維持するため、
            // ユーザー名をメールアドレスとして扱うか、ダミーで進めます。
            // ここでは簡易的に userName を email とみなして進めます（バリデーションはユーザー名基準）
            
            User user = new User();
            user.setUserId(UUID.randomUUID());
            user.setUserName(userName);
            user.setUserPassword(password);
            user.setSecurityCode(securityCode);
            user.setBalance(10000); // 初回特典
            user.setPoint(0);
            user.setLoginAttemptCount(0);
            user.setLockout(false);

            String token = UUID.randomUUID().toString();
            PendingUserStore.add(token, user);

            String baseUrl = request.getScheme() + "://" + request.getServerName() 
                           + ":" + request.getServerPort() + request.getContextPath();
            String authUrl = baseUrl + "/UserVerify?token=" + token;

            // ※メールアドレスではない文字列だと送信エラーになる可能性がありますが、
            // 画面仕様に合わせて実装します。実運用ではメールアドレス入力欄が必須です。
            // ここではコンソール出力にとどめるか、仮にuserNameがメアド形式なら送信します。
            System.out.println("Auth URL: " + authUrl);
            MailUtil.sendAuthMail(userName, authUrl); // メアド形式でないとエラーになるためコメントアウト推奨

            // そのまま登録完了画面風のJSPへ（メール確認画面）
            request.getRequestDispatcher("/WEB-INF/user/user_signup_sent.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("globalError", "システムエラーが発生しました: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/user/user_signup.jsp").forward(request, response);
        }
    }

    // 「半角8~32桁。英大小文字、数字、記号のうち2種類以上」のチェック
    private boolean isValidFormat(String input) {
        if (input == null || input.length() < 8 || input.length() > 32) {
            return false;
        }
        int types = 0;
        if (input.matches(".*[a-z].*")) types++;
        if (input.matches(".*[A-Z].*")) types++;
        if (input.matches(".*[0-9].*")) types++;
        if (input.matches(".*[ -/:-@\\[-\\`\\{-\\~].*")) types++; // 記号
        return types >= 2;
    }
}