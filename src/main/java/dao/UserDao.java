package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

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
                // 必要なフィールドをセット
                user.setSecurityCode(rs.getString("security_code")); // チェック用
                user.setLockout(rs.getBoolean("is_lockout"));
                return user;
            }
            return null;
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    // src/main/java/dao/UserDao.java のクラス内に追加

    /**
     * ユーザー名からユーザー情報を検索する（ログイン用）
     */
    public User findByName(String userName) throws Exception {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            // ユーザー名で検索
            String sql = "SELECT * FROM users WHERE user_name = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, userName);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setUserId(UUID.fromString(rs.getString("user_id")));
                user.setUserName(rs.getString("user_name"));
                // パスワード照合のために取得
                user.setUserPassword(rs.getString("user_password")); 
                user.setBalance(rs.getInt("balance"));
                user.setPoint(rs.getInt("point"));
                user.setSecurityCode(rs.getString("security_code"));
                user.setLoginAttemptCount(rs.getInt("login_attempt_count"));
                user.setLockout(rs.getBoolean("is_lockout"));
                return user;
            }
            return null; // 見つからない場合
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    // UserDao.java の userPayment メソッド

    public int userPayment(UUID userId, UUID orderId, int amount, String inputSecurityCode) throws DaoException {
        Connection con = null;

        try {
            con = dbHolder.getConnection();
            con.setAutoCommit(false);

            // 1. ユーザー取得
            String sqlUser = "SELECT * FROM users WHERE user_id = ? FOR UPDATE";
            PreparedStatement psUser = con.prepareStatement(sqlUser);
            psUser.setString(1, userId.toString());
            ResultSet rsUser = psUser.executeQuery();

            if (!rsUser.next()) throw new DaoException("ユーザー不在");
            
            // 2. ★修正: セキュリティコードを「生データ」で比較
            String dbCode = rsUser.getString("security_code"); // SQLに入れた "1234"
            
            // ハッシュ化処理(PaymentSystem.calculateHash)を削除し、そのまま比較
            if (!inputSecurityCode.equals(dbCode)) {
                throw new DaoException("認証失敗: セキュリティコードが違います (DB:" + dbCode + " / 入力:" + inputSecurityCode + ")");
            }

            // 3. 残高チェック
            int currentBalance = rsUser.getInt("balance");
            if (currentBalance < amount) throw new DaoException("残高不足です");

            // 4. Ledgerのハッシュチェーン取得（ここは簡易的に残す）
            Statement stmt = con.createStatement();
            ResultSet rsLedger = stmt.executeQuery("SELECT * FROM ledger ORDER BY height DESC LIMIT 1");
            String prevHash = "GENESIS";
            if (rsLedger.next()) {
                prevHash = rsLedger.getString("curr_hash");
            }

            // 5. ★修正: 電子署名ロジックを廃止（ダミーを入れる）
            // 秘密鍵 "priv1" は復号できないため、署名計算自体をやめる
            String signature = "DUMMY_SIGNATURE"; // ダミー署名
            String currHash = "DUMMY_HASH_" + System.currentTimeMillis(); // ダミーハッシュ

            // 6. DB更新
            // LedgerへのINSERT
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
     * チャージ処理（シングルノード版）
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
                // 必要であればここで改ざんチェックロジックを入れる（paymentと同じ）
            }

            // 3. データ作成
            int newBalance = currentBalance + amount;
            
            String encPrivKey = rsUser.getString("encrypted_private_key");
            var privKey = PaymentSystem.decryptPrivateKey(encPrivKey);
            
            // チャージ用署名
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
            psU.setInt(1, newBalance);
            psU.setString(2, userId.toString());
            psU.executeUpdate();

            con.commit();
            return newBalance;

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
                    // ★ここが重要: 提示されたUserクラスに合わせて値をセット
                    // UUID.fromString で文字列をUUID型に変換してセット
                    user.setUserId(UUID.fromString(rs.getString("user_id")));
                    user.setUserName(rs.getString("user_name"));
                    user.setBalance(rs.getInt("balance"));
                    user.setPoint(rs.getInt("point"));
                    user.setLoginAttemptCount(rs.getInt("login_attempt_count"));
                    user.setLockout(rs.getBoolean("is_lockout"));
                    
                    // パスワードやセキュリティコードが必要ならセット（一覧表示だけなら不要な場合もあります）
                    // user.setUserPassword(rs.getString("password")); 
                    // user.setSecurityCode(rs.getString("security_code"));

                } catch (Exception e) {
                    // Failure例外やUUID形式エラー等の場合
                    e.printStackTrace();
                    // データの不整合があるレコードはスキップするか、エラーとして扱う
                    continue; 
                }

                boolean isPaid = rs.getBoolean("is_paid");
                
                // 元のUserViewDTO (randomIdフィールド不要版) を使用
                list.add(new UserViewDTO(user, isPaid));
            }
        } catch (Exception e) {
            throw new DaoException("一覧取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }
    
    /**
     * ★追加: 管理者画面用
     * 指定されたユーザーのロックアウトを解除し、試行回数をリセットする
     */
    public void unlockUser(UUID userId) throws DaoException {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            con.setAutoCommit(false); // トランザクション開始

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

    // UserDao.java

/**
     * 新規ユーザー登録（暗号化なしバージョン）
     */
    public void register(User user) throws Exception {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            // 前回の要望通り、ダミーの鍵を入れて生パスワードで保存
            String sql = "INSERT INTO users (user_id, user_name, user_password, security_code, balance, point, login_attempt_count, is_lockout, encrypted_private_key, public_key) VALUES (?, ?, ?, ?, ?, ?, 0, FALSE, 'DUMMY_PRIV', 'DUMMY_PUB')";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, user.getUserId().toString());
            ps.setString(2, user.getUserName());
            ps.setString(3, user.getUserPassword());
            ps.setString(4, user.getSecurityCode());
            ps.setInt(5, user.getBalance());
            ps.setInt(6, user.getPoint());
            
            ps.executeUpdate();
        } finally {
            connectionCloser.closeConnection(con);
        }
    }
}