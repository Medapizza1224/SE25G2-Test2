package system;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Base64;
import java.util.UUID;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.DataSourceHolder;
import dao.ConnectionCloser;

@WebServlet("/setup")
public class PaymentSetup extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // PaymentSystemと同じマスターキーを使用
    private static final String APP_MASTER_KEY = "12345678901234567890123456789012";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        DataSourceHolder dbHolder = new DataSourceHolder();
        ConnectionCloser closer = new ConnectionCloser();
        Connection con = null;

        try {
            out.println("<html><body><h1>データセットアップ開始...</h1>");

            // ---------------------------------------------
            // 1. 暗号化データの準備 (メモリ上で計算)
            // ---------------------------------------------
            String userName = "user0001";
            String securityCodeRaw = "1234"; 
            int initialBalance = 50000;
            int initialPoint = 5000;
            UUID userId = UUID.fromString("550e8400-e29b-41d4-a716-446655440000"); // 固定ID

            // ハッシュ化
            String securityCodeHash = PaymentSystem.calculateHash(securityCodeRaw);

            // RSA鍵生成
            KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
            keyGen.initialize(2048);
            KeyPair pair = keyGen.generateKeyPair();
            PrivateKey priv = pair.getPrivate();
            PublicKey pub = pair.getPublic();

            // 秘密鍵のAES暗号化
            SecretKeySpec skeySpec = new SecretKeySpec(APP_MASTER_KEY.getBytes(StandardCharsets.UTF_8), "AES");
            Cipher cipher = Cipher.getInstance("AES");
            cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
            byte[] encryptedPrivBytes = cipher.doFinal(priv.getEncoded());
            
            String encryptedPrivateKeyStr = Base64.getEncoder().encodeToString(encryptedPrivBytes);
            String publicKeyStr = Base64.getEncoder().encodeToString(pub.getEncoded());

            out.println("<p>鍵ペア生成と暗号化完了。</p>");

            // ---------------------------------------------
            // 2. DBへの書き込み (単一ノード)
            // ---------------------------------------------
            // ★修正点: getAllConnections() ではなく getConnection() を使用
            con = dbHolder.getConnection();
            con.setAutoCommit(true);
            
            String sqlDelete = "DELETE FROM users WHERE user_id = ?";
            String sqlInsert = "INSERT INTO users (user_id, user_name, user_password, security_code, balance, point, login_attempt_count, is_lockout, encrypted_private_key, public_key) VALUES (?, ?, ?, ?, ?, ?, 0, FALSE, ?, ?)";

            // 既存があれば消す（上書き用）
            try (PreparedStatement psDel = con.prepareStatement(sqlDelete)) {
                psDel.setString(1, userId.toString());
                psDel.executeUpdate();
            }

            // 新規登録
            try (PreparedStatement psIns = con.prepareStatement(sqlInsert)) {
                psIns.setString(1, userId.toString());
                psIns.setString(2, userName);
                psIns.setString(3, "dummy_pass"); // ダミーパスワード
                psIns.setString(4, securityCodeHash);
                psIns.setInt(5, initialBalance);
                psIns.setInt(6, initialPoint);
                psIns.setString(7, encryptedPrivateKeyStr);
                psIns.setString(8, publicKeyStr);
                
                psIns.executeUpdate();
            }

            out.println("<h2>セットアップ完了！</h2>");
            out.println("<ul>");
            out.println("<li>User ID: <b>" + userId.toString() + "</b></li>");
            out.println("<li>Name: " + userName + "</li>");
            out.println("<li>Balance: " + initialBalance + "</li>");
            out.println("<li>Security Code: <b>" + securityCodeRaw + "</b></li>");
            out.println("</ul>");
            
            // 決済画面へのリンク
            out.println("<hr>");
            out.println("<a href='" + request.getContextPath() + "/UserPayment?orderId=a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11' style='font-size:20px; color:blue;'>>> 決済画面へ移動する</a>");
            
            // テスト用にセッションへ強制ログイン
            entity.User user = new entity.User();
            user.setUserId(userId);
            user.setBalance(initialBalance);
            user.setPoint(initialPoint);
            request.getSession().setAttribute("user", user);
            out.println("<p>※テスト用にセッションへログイン情報を強制セットしました。</p>");
            
            out.println("</body></html>");

        } catch (Exception e) {
            e.printStackTrace(out);
        } finally {
            // ★修正点: closer.closeConnection(con) (単数形) を使用
            try {
                if (closer != null) closer.closeConnection(con);
            } catch (Exception e) {
                // closeエラーは無視
            }
        }
    }
}