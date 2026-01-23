package control.system;

import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.Base64;
import java.util.Random;
import java.util.UUID;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import dao.ConnectionCloser;
import dao.DataSourceHolder;
import entity.Order;
import entity.Setup;
import entity.User;
import servlet.system.PaymentSystem;

public class PaymentSetup {

    private static final String APP_MASTER_KEY = "12345678901234567890123456789012";

    // ★戻り値を PaymentSetupResult に変更
    public PaymentSetupResult execute() throws Exception {
        javax.sql.DataSource dataSource = new DataSourceHolder().dataSource;
        ConnectionCloser closer = new ConnectionCloser();
        Connection con = null;

        try {
            Random rand = new SecureRandom();

            // 1. Userエンティティ生成
            User user = new User();
            user.setUserId(UUID.randomUUID());
            user.setUserName("user" + String.format("%04d", rand.nextInt(10000)));
            
            String rawSecurityCode = String.format("%04d", rand.nextInt(10000));
            String securityCodeHash = PaymentSystem.calculateHash(rawSecurityCode);
            user.setSecurityCode(securityCodeHash);

            int paymentAmount = (rand.nextInt(91) + 10) * 100; 
            int initialBalance = paymentAmount + (rand.nextInt(46) + 5) * 1000;
            
            user.setBalance(initialBalance);
            user.setPoint(rand.nextInt(1000) * 10);
            user.setLoginAttemptCount(0);
            user.setLockout(false);
            user.setUserPassword("dummy_pass");

            // 2. Orderエンティティ生成
            Order order = new Order();
            order.setOrderId(UUID.randomUUID());
            order.setTableNumber("0001");
            order.setAdultCount(1);
            order.setChildCount(0);
            order.setPaymentCompleted(false);
            order.setVisitAt(new Timestamp(System.currentTimeMillis()));
            order.setTotalAmount(paymentAmount);

            // 3. 暗号化キー生成
            KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
            keyGen.initialize(2048);
            KeyPair pair = keyGen.generateKeyPair();
            PrivateKey priv = pair.getPrivate();
            PublicKey pub = pair.getPublic();

            SecretKeySpec skeySpec = new SecretKeySpec(APP_MASTER_KEY.getBytes(StandardCharsets.UTF_8), "AES");
            Cipher cipher = Cipher.getInstance("AES");
            cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
            byte[] encryptedPrivBytes = cipher.doFinal(priv.getEncoded());
            
            String encryptedPrivateKeyStr = Base64.getEncoder().encodeToString(encryptedPrivBytes);
            String publicKeyStr = Base64.getEncoder().encodeToString(pub.getEncoded());

            // 4. DB登録
            con = dataSource.getConnection();
            con.setAutoCommit(false);

            String sqlUser = "INSERT INTO users (user_id, user_name, user_password, security_code, balance, point, login_attempt_count, is_lockout, encrypted_private_key, public_key) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sqlUser)) {
                ps.setString(1, user.getUserId().toString());
                ps.setString(2, user.getUserName());
                ps.setString(3, user.getUserPassword());
                ps.setString(4, user.getSecurityCode());
                ps.setInt(5, user.getBalance());
                ps.setInt(6, user.getPoint());
                ps.setInt(7, user.getLoginAttemptCount());
                ps.setBoolean(8, user.isLockout());
                ps.setString(9, encryptedPrivateKeyStr);
                ps.setString(10, publicKeyStr);
                ps.executeUpdate();
            }

            String sqlOrder = "INSERT INTO orders (order_id, table_number, adult_count, child_count, is_payment_completed, visit_at) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sqlOrder)) {
                ps.setString(1, order.getOrderId().toString());
                ps.setString(2, order.getTableNumber());
                ps.setInt(3, order.getAdultCount());
                ps.setInt(4, order.getChildCount());
                ps.setBoolean(5, order.isPaymentCompleted());
                ps.setTimestamp(6, order.getVisitAt());
                ps.executeUpdate();
            }

            String sqlItem = "INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at) VALUES (?, ?, 'P001', 1, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sqlItem)) {
                ps.setString(1, UUID.randomUUID().toString());
                ps.setString(2, order.getOrderId().toString());
                ps.setInt(3, order.getTotalAmount()); 
                ps.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
                ps.executeUpdate();
            }

            con.commit();

            // 5. Setupエンティティを作成し、Resultでラップして返す
            Setup setup = new Setup(user, order, rawSecurityCode);
            return new PaymentSetupResult(setup);

        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ex) {}
            throw e;
        } finally {
            closer.closeConnection(con);
        }
    }
}