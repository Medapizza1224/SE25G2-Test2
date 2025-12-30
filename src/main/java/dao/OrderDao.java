package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;
import entity.Order;

public class OrderDao {
    
    /**
     * 注文IDから注文情報を取得し、明細を集計して合計金額をセットして返す
     */
    public Order findById(UUID orderId) throws Exception {
        DataSourceHolder dbHolder = new DataSourceHolder();
        
        // 読み取り専用なので Node1 (getNode1Connection) を利用
        // もしDataSourceHolderにgetConnection()を作ったならそれを使う
        try (Connection con = dbHolder.getNode1Connection()) {
            
            // 1. 注文ヘッダの存在確認
            String sqlHead = "SELECT * FROM orders WHERE order_id = ?";
            PreparedStatement psHead = con.prepareStatement(sqlHead);
            psHead.setString(1, orderId.toString());
            ResultSet rsHead = psHead.executeQuery();
            
            if (rsHead.next()) {
                Order order = new Order();
                order.setOrderId(UUID.fromString(rsHead.getString("order_id")));
                order.setPaymentCompleted(rsHead.getBoolean("is_payment_completed"));
                
                // 2. 合計金額の計算 (order_itemsの price * quantity の総和)
                int total = calculateTotalAmount(con, orderId);
                order.setTotalAmount(total);
                
                return order;
            }
            return null;
        }
    }

    /**
     * 明細テーブルを集計して合計金額を出す
     */
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