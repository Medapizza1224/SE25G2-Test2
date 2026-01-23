package servlet.user;

import java.io.IOException;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.UserDao;
import entity.User;
import util.AppConfig;
import util.MailUtil;
import util.PendingUserStore;

@WebServlet("/user_signup")
public class UserSignupServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/user/user_signup.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String userName = request.getParameter("userName");
        String password = request.getParameter("password");
        String passwordConfirm = request.getParameter("passwordConfirm");
        String securityCode = request.getParameter("securityCode");

        boolean hasError = false;

        // --- バリデーション ---
        if (userName == null || userName.isEmpty() || !userName.contains("@")) {
            request.setAttribute("errorUserName", "正しいメールアドレスの形式で入力してください。");
            hasError = true;
        } else {
            try {
                UserDao dao = new UserDao();
                if (dao.findByName(userName) != null) {
                    request.setAttribute("errorUserName", "そのユーザー名は既に使用されています。");
                    hasError = true;
                }
            } catch (Exception e) {
                e.printStackTrace();
                hasError = true;
            }
        }
        if (password == null || !isValidFormat(password)) {
            request.setAttribute("errorPassword", "半角8~32桁。英大小文字、数字、記号のうち2種類以上。");
            hasError = true;
        }
        if (passwordConfirm == null || !passwordConfirm.equals(password)) {
            request.setAttribute("errorPasswordConfirm", "パスワードが一致しません。");
            hasError = true;
        }
        if (securityCode == null || !securityCode.matches("^\\d{4}$")) {
            request.setAttribute("errorSecurityCode", "半角4桁。数字のみ。");
            hasError = true;
        }

        if (hasError) {
            request.setAttribute("userName", userName);
            request.setAttribute("securityCode", securityCode);
            request.getRequestDispatcher("/WEB-INF/user/user_signup.jsp").forward(request, response);
            return;
        }

        // --- 正常処理 ---
        try {
            User user = new User();
            user.setUserId(UUID.randomUUID());
            user.setUserName(userName);
            user.setUserPassword(password);
            user.setSecurityCode(securityCode);
            String hashedCode = servlet.system.PaymentSystem.calculateHash(securityCode);
            user.setSecurityCode(hashedCode);
            user.setBalance(10000); // 初回特典
            user.setPoint(0);
            user.setLoginAttemptCount(0);
            user.setLockout(false);

            String token = UUID.randomUUID().toString();
            PendingUserStore.add(token, user);

            String baseUrl = request.getScheme() + "://" + request.getServerName() 
                           + ":" + request.getServerPort() + request.getContextPath();
            String authUrl = baseUrl + "/UserVerify?token=" + token;

            // ★修正: 設定ファイルからメール設定を読み込む
            AppConfig config = AppConfig.load(getServletContext());
            
            // 店舗名の取得
            String storeName = config.getStoreName();
            if (storeName == null || storeName.isEmpty()) storeName = "焼肉〇〇";

            // 件名内の {store} を店舗名に置換
            String subject = config.getMailSubject().replace("{store}", storeName);
            
            // 本文内の {link} をURLに置換、{store} を店舗名に置換
            String bodyTemplate = config.getMailBody();
            String body = bodyTemplate.replace("{link}", authUrl).replace("{store}", storeName);

            // 設定された内容で送信（第4引数に差出人名）
            System.out.println("Auth URL: " + authUrl);
            MailUtil.sendMail(userName, subject, body, storeName); 

            request.getRequestDispatcher("/WEB-INF/user/user_signup_sent.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("globalError", "システムエラーが発生しました: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/user/user_signup.jsp").forward(request, response);
        }
    }

    private boolean isValidFormat(String input) {
        if (input == null || input.length() < 8 || input.length() > 32) return false;
        int types = 0;
        if (input.matches(".*[a-z].*")) types++;
        if (input.matches(".*[A-Z].*")) types++;
        if (input.matches(".*[0-9].*")) types++;
        if (input.matches(".*[ -/:-@\\[-\\`\\{-\\~].*")) types++;
        return types >= 2;
    }
}