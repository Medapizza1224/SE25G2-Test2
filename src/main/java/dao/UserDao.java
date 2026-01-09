package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.security.KeyPair; // 鍵ペア生成用
import java.util.Base64;      // 公開鍵エンコード用

import dto.UserViewDTO;
import entity.User;
import servlet.system.PaymentSystem;

public class UserDao {

    private final DataSourceHolder dbHolder;
    private final ConnectionCloser connectionCloser;

    public UserDao() {
        this.dbHolder = new DataSourceHolder();
        this.connectionCloser = new ConnectionCloser();
    }

    /**
     * IDからユーザー情報を取得
     */
    public User findById(UUID userId) throws Exception {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            String sql = "SELECT * FROM users WHERE user_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, userId.toString());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setUserId(UUID.fromString(rs.getString("user_id")));
                user.setUserName(rs.getString("user_name"));
                user.setBalance(rs.getInt("balance"));
                user.setPoint(rs.getInt("point"));
                user.setSecurityCode(rs.getString("security_code"));
                user.setLockout(rs.getBoolean("is_lockout"));
                return user;
            }
            return null;
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    /**
     * ユーザー名からユーザー情報を検索する（ログイン用）
     */
    public User findByName(String userName) throws Exception {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            String sql = "SELECT * FROM users WHERE user_name = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, userName);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setUserId(UUID.fromString(rs.getString("user_id")));
                user.setUserName(rs.getString("user_name"));
                user.setUserPassword(rs.getString("user_password")); 
                user.setBalance(rs.getInt("balance"));
                user.setPoint(rs.getInt("point"));
                user.setSecurityCode(rs.getString("security_code"));
                user.setLoginAttemptCount(rs.getInt("login_attempt_count"));
                user.setLockout(rs.getBoolean("is_lockout"));
                return user;
            }
            return null;
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    /**
     * 決済処理（実ロジック版：署名・ハッシュ計算あり）
     */
    public int userPayment(UUID userId, UUID orderId, int amount, String inputSecurityCode) throws DaoException {
        Connection con = null;

        try {
            con = dbHolder.getConnection();
            con.setAutoCommit(false);

            // 1. ユーザー取得（排他ロック）
            String sqlUser = "SELECT * FROM users WHERE user_id = ? FOR UPDATE";
            PreparedStatement psUser = con.prepareStatement(sqlUser);
            psUser.setString(1, userId.toString());
            ResultSet rsUser = psUser.executeQuery();

            if (!rsUser.next()) throw new DaoException("ユーザー不在");
            
            // 2. セキュリティコード検証
            String dbCode = rsUser.getString("security_code");
            if (!inputSecurityCode.equals(dbCode)) {
                throw new DaoException("認証失敗: セキュリティコードが違います");
            }

            // 3. 残高チェック
            int currentBalance = rsUser.getInt("balance");
            if (currentBalance < amount) throw new DaoException("残高不足です");

            // 4. Ledgerのハッシュチェーン取得
            Statement stmt = con.createStatement();
            ResultSet rsLedger = stmt.executeQuery("SELECT * FROM ledger ORDER BY height DESC LIMIT 1");
            String prevHash = "GENESIS";
            if (rsLedger.next()) {
                prevHash = rsLedger.getString("curr_hash");
            }

            // 5. 電子署名とハッシュ計算（実際の鍵を使用）
            String encPrivKey = rsUser.getString("encrypted_private_key");
            
            // DBの値が不正(ダミー文字列等)だとここで復号エラーになります
            var privKey = PaymentSystem.decryptPrivateKey(encPrivKey);
            
            // 署名対象データ
            String signPayload = userId.toString() + "PAYMENT" + amount;
            String signature = PaymentSystem.signData(signPayload, privKey);

            // ブロックハッシュ計算
            String blockData = userId.toString() + amount + prevHash + signature;
            String currHash = PaymentSystem.calculateHash(blockData);

            // 6. DB更新
            // Ledger
            String sqlLedger = "INSERT INTO ledger (prev_hash, curr_hash, sender_id, amount, signature) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement psL = con.prepareStatement(sqlLedger);
            psL.setString(1, prevHash);
            psL.setString(2, currHash);
            psL.setString(3, userId.toString());
            psL.setInt(4, amount);
            psL.setString(5, signature);
            psL.executeUpdate();

            // ユーザー残高更新
            int newBalance = currentBalance - amount;
            int earnedPoints = (int)(amount * 0.01);
            String sqlUpdUser = "UPDATE users SET balance = ?, point = point + ? WHERE user_id = ?";
            PreparedStatement psU = con.prepareStatement(sqlUpdUser);
            psU.setInt(1, newBalance);
            psU.setInt(2, earnedPoints);
            psU.setString(3, userId.toString());
            psU.executeUpdate();

            // 注文ステータス更新
            String sqlUpdOrder = "UPDATE orders SET is_payment_completed = TRUE WHERE order_id = ?";
            PreparedStatement psO = con.prepareStatement(sqlUpdOrder);
            psO.setString(1, orderId.toString());
            psO.executeUpdate();

            // 決済履歴
            String sqlInsPay = "INSERT INTO payments (order_id, user_id, used_points, earned_points) VALUES (?, ?, 0, ?)";
            PreparedStatement psP = con.prepareStatement(sqlInsPay);
            psP.setString(1, orderId.toString());
            psP.setString(2, userId.toString());
            psP.setInt(3, earnedPoints);
            psP.executeUpdate();

            con.commit();
            return newBalance;

        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            throw new DaoException("決済エラー: " + e.getMessage());
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    /**
     * チャージ処理（実ロジック版：署名・ハッシュ計算あり）
     */
    public int userCharge(UUID userId, int amount) throws DaoException {
        Connection con = null;

        try {
            con = dbHolder.getConnection();
            con.setAutoCommit(false);

            // 1. ユーザーロック
            String sqlUser = "SELECT * FROM users WHERE user_id = ? FOR UPDATE";
            PreparedStatement psUser = con.prepareStatement(sqlUser);
            psUser.setString(1, userId.toString());
            ResultSet rsUser = psUser.executeQuery();

            if (!rsUser.next()) throw new DaoException("ユーザーが見つかりません");
            int currentBalance = rsUser.getInt("balance");

            // 2. Ledgerチェック
            Statement stmt = con.createStatement();
            ResultSet rsLedger = stmt.executeQuery("SELECT * FROM ledger ORDER BY height DESC LIMIT 1");
            
            String prevHash = "GENESIS";
            if (rsLedger.next()) {
                prevHash = rsLedger.getString("curr_hash");
            }

            // 3. データ作成（実際の鍵を使用）
            String encPrivKey = rsUser.getString("encrypted_private_key");
            
            // DBの値が不正だとここでエラー（Base64デコード失敗など）になります
            var privKey = PaymentSystem.decryptPrivateKey(encPrivKey);
            
            String signPayload = userId.toString() + "CHARGE" + amount;
            String signature = PaymentSystem.signData(signPayload, privKey);

            String blockData = userId.toString() + amount + prevHash + signature;
            String currHash = PaymentSystem.calculateHash(blockData);

            // 4. DB更新
            // Ledger
            String sqlLedger = "INSERT INTO ledger (prev_hash, curr_hash, sender_id, amount, signature) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement psL = con.prepareStatement(sqlLedger);
            psL.setString(1, prevHash);
            psL.setString(2, currHash);
            psL.setString(3, userId.toString());
            psL.setInt(4, amount);
            psL.setString(5, signature);
            psL.executeUpdate();

            // User Balance
            String sqlUpdUser = "UPDATE users SET balance = ? WHERE user_id = ?";
            PreparedStatement psU = con.prepareStatement(sqlUpdUser);
            psU.setInt(1, currentBalance + amount); // 現在残高 + チャージ額
            psU.setString(2, userId.toString());
            psU.executeUpdate();

            con.commit();
            return currentBalance + amount;

        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            throw new DaoException("チャージ処理に失敗しました: " + e.getMessage());
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    public List<UserViewDTO> findAllWithStatus() throws DaoException {
        List<UserViewDTO> list = new ArrayList<>();
        Connection con = null;

        try {
            con = dbHolder.getConnection();

            String sql = "SELECT u.*, "
                       + "(SELECT COUNT(*) FROM payments p WHERE p.user_id = u.user_id) > 0 AS is_paid "
                       + "FROM users u "
                       + "ORDER BY u.user_name ASC";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                User user = new User();
                try {
                    user.setUserId(UUID.fromString(rs.getString("user_id")));
                    user.setUserName(rs.getString("user_name"));
                    user.setBalance(rs.getInt("balance"));
                    user.setPoint(rs.getInt("point"));
                    user.setLoginAttemptCount(rs.getInt("login_attempt_count"));
                    user.setLockout(rs.getBoolean("is_lockout"));
                } catch (Exception e) {
                    e.printStackTrace();
                    continue; 
                }

                boolean isPaid = rs.getBoolean("is_paid");
                list.add(new UserViewDTO(user, isPaid));
            }
        } catch (Exception e) {
            throw new DaoException("一覧取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }
    
    public void unlockUser(UUID userId) throws DaoException {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            con.setAutoCommit(false); 

            String sql = "UPDATE users SET is_lockout = FALSE, login_attempt_count = 0 WHERE user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, userId.toString());
                ps.executeUpdate();
            }

            con.commit();
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (SQLException ex) {}
            throw new DaoException("ロック解除エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    /**
     * 新規ユーザー登録（★実ロジック：鍵ペア生成・暗号化）
     */
    public void register(User user) throws Exception {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            
            // 1. 鍵ペア作成（実ロジック）
            KeyPair keyPair = PaymentSystem.createKeyPair();
            
            // 2. 秘密鍵を暗号化して文字列化（Base64形式になるはず）
            String encPrivKey = PaymentSystem.encryptPrivateKey(keyPair.getPrivate());
            
            // 3. 公開鍵をBase64文字列化
            String pubKey = Base64.getEncoder().encodeToString(keyPair.getPublic().getEncoded());

            // 4. DBへ保存
            String sql = "INSERT INTO users (user_id, user_name, user_password, security_code, balance, point, login_attempt_count, is_lockout, encrypted_private_key, public_key) VALUES (?, ?, ?, ?, ?, ?, 0, FALSE, ?, ?)";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, user.getUserId().toString());
            ps.setString(2, user.getUserName());
            ps.setString(3, user.getUserPassword());
            ps.setString(4, user.getSecurityCode());
            ps.setInt(5, user.getBalance());
            ps.setInt(6, user.getPoint());
            
            // 正しい鍵データをセット
            ps.setString(7, encPrivKey);
            ps.setString(8, pubKey);
            
            ps.executeUpdate();
        } finally {
            connectionCloser.closeConnection(con);
        }
    }
}