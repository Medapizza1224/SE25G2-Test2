package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;
import entity.Order;

public class OrderDao {
    
    private final DataSourceHolder dbHolder;
    private final ConnectionCloser connectionCloser;

    public OrderDao() {
        this.dbHolder = new DataSourceHolder();
        this.connectionCloser = new ConnectionCloser();
    }

    public Order findById(UUID orderId) throws Exception {
        Connection con = null;
        try {
            // ★ここを修正
            con = dbHolder.getConnection();
            
            String sqlHead = "SELECT * FROM orders WHERE order_id = ?";
            PreparedStatement psHead = con.prepareStatement(sqlHead);
            psHead.setString(1, orderId.toString());
            ResultSet rsHead = psHead.executeQuery();
            
            if (rsHead.next()) {
                Order order = new Order();
                order.setOrderId(UUID.fromString(rsHead.getString("order_id")));
                order.setPaymentCompleted(rsHead.getBoolean("is_payment_completed"));
                
                int total = calculateTotalAmount(con, orderId);
                order.setTotalAmount(total);
                
                return order;
            }
            return null;
        } finally {
            // Close漏れを防ぐためfinallyで閉じるかtry-with-resources推奨
            connectionCloser.closeConnection(con);
        }
    }

    private int calculateTotalAmount(Connection con, UUID orderId) throws Exception {
        String sql = "SELECT SUM(price * quantity) as total FROM order_items WHERE order_id = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, orderId.toString());
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getInt("total");
        }
        return 0;
    }
}