package dao;

import java.sql.*;
import java.util.*;

import entity.User;
import system.PaymentSystem;

public class UserDao {

    /**
     * 【追加】IDからユーザー情報を取得する（画面表示用）
     * サーブレットの doGet で使用します。
     */
    public User findById(UUID userId) throws Exception {
        DataSourceHolder dbHolder = new DataSourceHolder();
        
        // 参照用なので Node1 だけ見ればOK
        try (Connection con = dbHolder.getNode1Connection()) {
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
                // セキュリティコードのハッシュ等は表示不要なのでセットしなくてOK
                return user;
            }
            return null;
        }
    }

    // 決済処理（ここがセキュリティの要）
    public int userPayment(UUID userId, UUID orderId, int amount, String inputSecurityCode) throws DaoException {
        DataSourceHolder dbHolder = new DataSourceHolder(); // 既存の接続管理クラス
        ConnectionCloser closer = new ConnectionCloser();   // 既存のクローズ管理クラス
        List<Connection> conns = null;

        try {
            // 1. 全ノードに接続
            conns = dbHolder.getAllConnections();
            if (conns == null || conns.isEmpty()) throw new DaoException("DB接続エラー");

            for (Connection c : conns) c.setAutoCommit(false);

            // ---------------------------------------------------------
            // 2. 【横の監視】多数決で信頼できるノードを決める
            // ---------------------------------------------------------
            Connection trustedConn = getConsensusConnection(conns);
            
            // 信頼できるノードからユーザー情報を取得（ロック）
            String sqlUser = "SELECT * FROM users WHERE user_id = ? FOR UPDATE";
            PreparedStatement psUser = trustedConn.prepareStatement(sqlUser);
            psUser.setString(1, userId.toString());
            ResultSet rsUser = psUser.executeQuery();

            if (!rsUser.next()) throw new DaoException("ユーザー不在");
            if (rsUser.getBoolean("is_lockout")) throw new DaoException("アカウントロック中");

            // 3. 入力チェック（セキュリティコード）
            String storedHash = rsUser.getString("security_code");
            String inputHash = PaymentSystem.calculateHash(inputSecurityCode);
            if (!inputHash.equals(storedHash)) throw new DaoException("認証失敗: コードが違います");

            int currentBalance = rsUser.getInt("balance");
            if (currentBalance < amount) throw new DaoException("残高不足");

            // ---------------------------------------------------------
            // 4. 【入口の監視】直前のブロックが改ざんされていないかチェック
            // ---------------------------------------------------------
            Statement stmt = trustedConn.createStatement();
            ResultSet rsLedger = stmt.executeQuery("SELECT * FROM ledger ORDER BY height DESC LIMIT 1");
            
            String prevHash = "GENESIS"; // 初期値
            if (rsLedger.next()) {
                prevHash = rsLedger.getString("curr_hash");
                int height = rsLedger.getInt("height"); // ★追加

                // ★追加: 最初のブロック(Genesis Block)の場合は計算チェックをスキップする
                // これがないと "GENESIS_HASH" と計算結果が合わずにエラーになる
                if (height > 1) {
                    
                    String senderId = rsLedger.getString("sender_id");
                    int prevAmt = rsLedger.getInt("amount");
                    String prevSig = rsLedger.getString("signature");
                    String prevPrevHash = rsLedger.getString("prev_hash");
                    
                    // 再計算チェック
                    String dataToVerify = senderId + prevAmt + prevPrevHash + prevSig;
                    String reCalcHash = PaymentSystem.calculateHash(dataToVerify);
                    
                    if (!reCalcHash.equals(prevHash)) {
                        throw new DaoException("【緊急】ブロックチェーンの不整合を検知しました。取引を停止します。");
                    }
                }
            }

            // 5. 新しいブロックデータの作成
            int newBalance = currentBalance - amount;
            String encPrivKey = rsUser.getString("encrypted_private_key");
            var privKey = PaymentSystem.decryptPrivateKey(encPrivKey);
            
            // 署名生成 (データ: ユーザーID + 注文ID + 金額)
            String signPayload = userId.toString() + orderId.toString() + amount;
            String signature = PaymentSystem.signData(signPayload, privKey);

            // ブロックハッシュ生成 (データ + 直前のハッシュ + 署名)
            String blockData = userId.toString() + amount + prevHash + signature;
            String currHash = PaymentSystem.calculateHash(blockData);

            // 6. 全ノードへ書き込み
            String sqlLedger = "INSERT INTO ledger (prev_hash, curr_hash, sender_id, amount, signature) VALUES (?, ?, ?, ?, ?)";
            String sqlUpdUser = "UPDATE users SET balance = ?, point = point + ? WHERE user_id = ?"; // ポイント加算も追加
            String sqlUpdOrder = "UPDATE orders SET is_payment_completed = TRUE WHERE order_id = ?"; // ★追加
            String sqlInsPay = "INSERT INTO payments (order_id, user_id, used_points, earned_points) VALUES (?, ?, 0, ?)";

            // ポイント計算 (1%)
            int earnedPoints = (int)(amount * 0.01);

            for (Connection c : conns) {
                // 1. Ledger Insert
                PreparedStatement psL = c.prepareStatement(sqlLedger);
                psL.setString(1, prevHash);
                psL.setString(2, currHash);
                psL.setString(3, userId.toString());
                psL.setInt(4, amount);
                psL.setString(5, signature);
                psL.executeUpdate();

                // 2. User Update (Balance & Point)
                PreparedStatement psU = c.prepareStatement(sqlUpdUser);
                psU.setInt(1, newBalance);
                psU.setInt(2, earnedPoints);
                psU.setString(3, userId.toString());
                psU.executeUpdate();

                // 3. Order Update (Status) ★これがないと店舗側で支払い済みにならない
                PreparedStatement psO = c.prepareStatement(sqlUpdOrder);
                psO.setString(1, orderId.toString());
                psO.executeUpdate();

                // 4. Payment History Insert ★レシート代わり
                PreparedStatement psP = c.prepareStatement(sqlInsPay);
                psP.setString(1, orderId.toString());
                psP.setString(2, userId.toString());
                psP.setInt(3, earnedPoints);
                psP.executeUpdate();
            }

            for (Connection c : conns) c.commit();
            return newBalance;

        } catch (Exception e) {
            if (conns != null) for (Connection c : conns) try { c.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            throw new DaoException("決済エラー: " + e.getMessage());
        } finally {
            closer.closeConnections(conns);
        }
    }

    // 多数決ロジック（ヘルパーメソッド）
    private Connection getConsensusConnection(List<Connection> conns) throws DaoException {
        Map<String, Integer> votes = new HashMap<>();
        Map<String, Connection> connMap = new HashMap<>();

        for (Connection c : conns) {
            try {
                Statement s = c.createStatement();
                ResultSet rs = s.executeQuery("SELECT curr_hash FROM ledger ORDER BY height DESC LIMIT 1");
                String h = rs.next() ? rs.getString("curr_hash") : "GENESIS";
                votes.put(h, votes.getOrDefault(h, 0) + 1);
                connMap.putIfAbsent(h, c);
            } catch (SQLException e) {}
        }

        // 過半数チェック
        int quorum = conns.size() / 2 + 1;
        for (Map.Entry<String, Integer> entry : votes.entrySet()) {
            if (entry.getValue() >= quorum) {
                return connMap.get(entry.getKey());
            }
        }
        throw new DaoException("分散合意エラー: ノード間でデータが食い違っています。");
    }
}