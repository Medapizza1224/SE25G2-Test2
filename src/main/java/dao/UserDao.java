package dao;

import java.sql.*;
import java.util.UUID;
import entity.User;
import system.PaymentSystem;

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

    /**
     * 決済処理（シングルノード・ブロックチェーンロジック維持版）
     */
    public int userPayment(UUID userId, UUID orderId, int amount, String inputSecurityCode) throws DaoException {
        Connection con = null;

        try {
            con = dbHolder.getConnection();
            con.setAutoCommit(false); // トランザクション開始

            // 1. ユーザー情報の取得とロック (FOR UPDATE)
            String sqlUser = "SELECT * FROM users WHERE user_id = ? FOR UPDATE";
            PreparedStatement psUser = con.prepareStatement(sqlUser);
            psUser.setString(1, userId.toString());
            ResultSet rsUser = psUser.executeQuery();

            if (!rsUser.next()) throw new DaoException("ユーザーが見つかりません");
            if (rsUser.getBoolean("is_lockout")) throw new DaoException("アカウントがロックされています");

            // 2. セキュリティコードチェック
            String storedHash = rsUser.getString("security_code");
            String inputHash = PaymentSystem.calculateHash(inputSecurityCode);
            if (!inputHash.equals(storedHash)) {
                // ここでログイン試行回数を増やす処理を入れても良い
                throw new DaoException("認証失敗: セキュリティコードが違います");
            }

            // 3. 残高チェック
            int currentBalance = rsUser.getInt("balance");
            if (currentBalance < amount) throw new DaoException("残高不足です");

            // 4. Ledger(台帳)の整合性チェック
            Statement stmt = con.createStatement();
            ResultSet rsLedger = stmt.executeQuery("SELECT * FROM ledger ORDER BY height DESC LIMIT 1");
            
            String prevHash = "GENESIS"; // 初期値
            if (rsLedger.next()) {
                prevHash = rsLedger.getString("curr_hash");
                int height = rsLedger.getInt("height");

                // Genesisブロック以外ならハッシュ改ざんチェックを行う
                if (height > 1) {
                    String senderId = rsLedger.getString("sender_id");
                    int prevAmt = rsLedger.getInt("amount");
                    String prevSig = rsLedger.getString("signature");
                    String prevPrevHash = rsLedger.getString("prev_hash");
                    
                    String dataToVerify = senderId + prevAmt + prevPrevHash + prevSig;
                    String reCalcHash = PaymentSystem.calculateHash(dataToVerify);
                    
                    if (!reCalcHash.equals(prevHash)) {
                        throw new DaoException("【致命的エラー】ブロックチェーンデータの不整合（改ざん）を検知しました。");
                    }
                }
            }

            // 5. 新しいブロックデータの作成
            int newBalance = currentBalance - amount;
            String encPrivKey = rsUser.getString("encrypted_private_key");
            var privKey = PaymentSystem.decryptPrivateKey(encPrivKey);
            
            // 署名生成
            String signPayload = userId.toString() + orderId.toString() + amount;
            String signature = PaymentSystem.signData(signPayload, privKey);

            // ブロックハッシュ生成
            String blockData = userId.toString() + amount + prevHash + signature;
            String currHash = PaymentSystem.calculateHash(blockData);

            // 6. DB更新実行
            
            // Ledgerへ記録
            String sqlLedger = "INSERT INTO ledger (prev_hash, curr_hash, sender_id, amount, signature) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement psL = con.prepareStatement(sqlLedger);
            psL.setString(1, prevHash);
            psL.setString(2, currHash);
            psL.setString(3, userId.toString());
            psL.setInt(4, amount);
            psL.setString(5, signature);
            psL.executeUpdate();

            // ユーザー残高・ポイント更新
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

            // 決済履歴登録
            String sqlInsPay = "INSERT INTO payments (order_id, user_id, used_points, earned_points) VALUES (?, ?, 0, ?)";
            PreparedStatement psP = con.prepareStatement(sqlInsPay);
            psP.setString(1, orderId.toString());
            psP.setString(2, userId.toString());
            psP.setInt(3, earnedPoints);
            psP.executeUpdate();

            // 7. コミット
            con.commit();
            return newBalance;

        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            throw new DaoException("決済処理中にエラーが発生しました: " + e.getMessage());
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
}