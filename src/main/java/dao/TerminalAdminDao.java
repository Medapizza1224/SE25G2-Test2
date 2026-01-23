package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class TerminalAdminDao {
    private DataSourceHolder dbHolder = new DataSourceHolder();
    private ConnectionCloser connectionCloser = new ConnectionCloser();

    public boolean authenticate(String inputId, String inputPass) throws Exception {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            // お客様のSQL定義: テーブル名=terminal_settings_admins, カラム=id, password
            String sql = "SELECT * FROM terminal_settings_admins WHERE id = ? AND password = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, inputId);
            ps.setString(2, inputPass);
            
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // レコードがあれば認証成功
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        } finally {
            connectionCloser.closeConnection(con);
        }
    }
}