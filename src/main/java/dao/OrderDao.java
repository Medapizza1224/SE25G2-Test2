package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;
import entity.Order;

public class OrderDao {
    
    // フィールド名を確認（ここでは dbHolder としています）
    private final DataSourceHolder dbHolder;
    private final ConnectionCloser connectionCloser;

    public OrderDao() {
        this.dbHolder = new DataSourceHolder();
        this.connectionCloser = new ConnectionCloser();
    }

    /**
     * 新規伝票作成 (来店時)
     */
    public void create(Order order) throws DaoException {
        Connection con = null;
        try {
            // ★修正: dataSourceHolder ではなく、フィールドで宣言した dbHolder を使用する
            con = dbHolder.getConnection();
            
            String sql = "INSERT INTO orders (order_id, table_number, adult_count, child_count, is_payment_completed, visit_at) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, order.getOrderId().toString());
            ps.setString(2, order.getTableNumber());
            ps.setInt(3, order.getAdultCount());
            ps.setInt(4, order.getChildCount());
            ps.setBoolean(5, order.isPaymentCompleted());
            ps.setTimestamp(6, order.getVisitAt());
            
            ps.executeUpdate();
        } catch (Exception e) {
            throw new DaoException("伝票作成エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    /**
     * IDで取得 (合計金額計算付き)
     */
    public Order findById(UUID orderId) throws DaoException {
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            
            String sqlHead = "SELECT * FROM orders WHERE order_id = ?";
            PreparedStatement psHead = con.prepareStatement(sqlHead);
            psHead.setString(1, orderId.toString());
            ResultSet rsHead = psHead.executeQuery();
            
            if (rsHead.next()) {
                Order order = new Order();
                // 必要な情報を全てマッピングします
                order.setOrderId(UUID.fromString(rsHead.getString("order_id")));
                order.setTableNumber(rsHead.getString("table_number"));
                order.setAdultCount(rsHead.getInt("adult_count"));
                order.setChildCount(rsHead.getInt("child_count"));
                order.setPaymentCompleted(rsHead.getBoolean("is_payment_completed"));
                order.setVisitAt(rsHead.getTimestamp("visit_at"));
                
                // 注文明細から合計金額を算出してセット
                int total = calculateTotalAmount(con, orderId);
                order.setTotalAmount(total);
                
                return order;
            }
            return null;
        } catch (Exception e) {
            throw new DaoException("伝票取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    /**
     * 合計金額計算用のヘルパーメソッド
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