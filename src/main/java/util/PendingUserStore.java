package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

import dao.ConnectionCloser;
import dao.DataSourceHolder;
import entity.User;

public class PendingUserStore {

    // DB接続用ツール（staticメソッド内で使うため都度インスタンス化するか、フィールドを持たせる）
    // 簡易的にメソッド内で生成します

    /**
     * 仮登録ユーザーをDB（pending_usersテーブル）に保存する
     */
    public static void add(String token, User user) throws Exception {
        DataSourceHolder dbHolder = new DataSourceHolder();
        ConnectionCloser closer = new ConnectionCloser();
        Connection con = null;

        try {
            con = dbHolder.getConnection();
            
            // トークンとユーザー情報をINSERT
            String sql = "INSERT INTO pending_users (token, user_id, user_name, user_password, security_code) VALUES (?, ?, ?, ?, ?)";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, token);
            ps.setString(2, user.getUserId().toString());
            ps.setString(3, user.getUserName());
            ps.setString(4, user.getUserPassword());
            ps.setString(5, user.getSecurityCode());
            
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        } finally {
            closer.closeConnection(con);
        }
    }

    /**
     * トークンからユーザー情報を取得し、DBから削除する（1回限り有効にするため）
     */
    public static User getAndRemove(String token) {
        DataSourceHolder dbHolder = new DataSourceHolder();
        ConnectionCloser closer = new ConnectionCloser();
        Connection con = null;
        User user = null;

        try {
            con = dbHolder.getConnection();
            con.setAutoCommit(false); // トランザクション開始

            // 1. データの取得
            String selectSql = "SELECT * FROM pending_users WHERE token = ?";
            PreparedStatement psSelect = con.prepareStatement(selectSql);
            psSelect.setString(1, token);
            ResultSet rs = psSelect.executeQuery();

            if (rs.next()) {
                user = new User();
                // DBから取り出した値をUserオブジェクトにセット
                // ※コンストラクタやSetterの仕様に合わせて適宜調整してください
                user.setUserId(UUID.fromString(rs.getString("user_id")));
                user.setUserName(rs.getString("user_name"));
                user.setUserPassword(rs.getString("user_password"));
                user.setSecurityCode(rs.getString("security_code"));
                
                // 初期値の設定（DBには保存していない初期値）
                user.setBalance(10000); // 初回特典
                user.setPoint(0);
                user.setLoginAttemptCount(0);
                user.setLockout(false);

                // 2. データの削除（取得できたらpendingからは消す）
                String deleteSql = "DELETE FROM pending_users WHERE token = ?";
                PreparedStatement psDelete = con.prepareStatement(deleteSql);
                psDelete.setString(1, token);
                psDelete.executeUpdate();
                
                con.commit(); // 削除まで成功したらコミット
            } else {
                // トークンが見つからない場合
                con.rollback();
            }

        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            return null;
        } finally {
            closer.closeConnection(con);
        }
        
        return user;
    }
}