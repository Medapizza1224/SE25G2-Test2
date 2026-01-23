package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import entity.Admin;

public class AdminDao {
    
    // DB接続用ユーティリティ（環境に合わせて適宜読み替えてください）
    private final javax.sql.DataSource dataSource; // 変更
    private ConnectionCloser connectionCloser = new ConnectionCloser();

    public AdminDao() { // 追加
        this.dataSource = new DataSourceHolder().dataSource;
    }

    public Admin findByLogin(String adminName, String password) throws Exception {
        Connection con = null;
        Admin admin = null;

        try {
            con = this.dataSource.getConnection();
            // パスワードは本来ハッシュ化すべきですが、今回は平文で比較します
            String sql = "SELECT * FROM admins WHERE admin_name = ? AND admin_password = ?";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, adminName);
            ps.setString(2, password);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                admin = new Admin();
                admin.setAdminName(rs.getString("admin_name"));
                // セキュリティ上パスワードは持ち回らない方が良いですが、一旦セット
                admin.setAdminPassword(rs.getString("admin_password")); 
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        } finally {
            connectionCloser.closeConnection(con);
        }
        return admin;
    }
}