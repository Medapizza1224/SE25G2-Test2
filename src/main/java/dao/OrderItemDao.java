package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import entity.OrderItem;

public class OrderItemDao {
    private final DataSourceHolder dataSourceHolder;
    private final ConnectionCloser connectionCloser;

    public OrderItemDao() {
        this.dataSourceHolder = new DataSourceHolder();
        this.connectionCloser = new ConnectionCloser();
    }

    // 注文明細の一括登録 (トランザクション内で使用するため Connection を受け取る)
    public void insertBatch(Connection con, List<OrderItem> items, String orderId) throws SQLException {
        String sql = "INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (OrderItem item : items) {
                ps.setString(1, UUID.randomUUID().toString()); // ID発行
                ps.setString(2, orderId);
                ps.setString(3, item.getProductId());
                ps.setInt(4, item.getQuantity());
                ps.setInt(5, item.getPrice());
                ps.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
                ps.setString(7, "調理中"); // 初期ステータス
                
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    // 注文IDに紐づく履歴取得
    public List<OrderItem> findByOrderId(String orderId) throws DaoException {
        List<OrderItem> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dataSourceHolder.getConnection();
            // 商品名を表示したい場合は Products テーブルと結合する推奨ですが、今回はEntityに合わせてシンプルにします
            String sql = "SELECT * FROM order_items WHERE order_id = ? ORDER BY add_order_at DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(UUID.fromString(rs.getString("order_item_id")));
                item.setOrderId(UUID.fromString(rs.getString("order_id")));
                item.setProductId(rs.getString("product_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPrice(rs.getInt("price"));
                item.setAddOrderAt(rs.getTimestamp("add_order_at"));
                item.setOrderCompletedAt(rs.getTimestamp("order_completed_at"));
                item.setOrderStatus(rs.getString("order_status"));
                list.add(item);
            }
        } catch (Exception e) {
            throw new DaoException("履歴取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }

    // キッチン用: 未提供('調理中')リスト取得 (商品名も結合して取得)
    public List<OrderItem> findUnserved() throws DaoException {
        List<OrderItem> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dataSourceHolder.getConnection();
            // productsテーブルと結合して商品名(product_name)を取得
            String sql = "SELECT oi.*, p.product_name " +
                         "FROM order_items oi " +
                         "JOIN products p ON oi.product_id = p.product_id " +
                         "WHERE oi.order_status = '調理中' " +
                         "ORDER BY oi.add_order_at ASC";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(UUID.fromString(rs.getString("order_item_id")));
                item.setOrderId(UUID.fromString(rs.getString("order_id"))); // テーブル番号表示用に必要ならOrdersとも結合
                item.setProductId(rs.getString("product_id"));
                item.setProductName(rs.getString("product_name")); // 結合した商品名
                item.setQuantity(rs.getInt("quantity"));
                item.setAddOrderAt(rs.getTimestamp("add_order_at"));
                item.setOrderStatus(rs.getString("order_status"));
                list.add(item);
            }
        } catch (Exception e) {
            throw new DaoException("キッチンリスト取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }

    // ステータス更新 (調理中 -> 提供済)
    public void updateStatus(String orderItemId, String status) throws DaoException {
        Connection con = null;
        try {
            con = dataSourceHolder.getConnection();
            String sql = "UPDATE order_items SET order_status = ?, order_completed_at = NOW() WHERE order_item_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, orderItemId);
            ps.executeUpdate();
        } catch (Exception e) {
            throw new DaoException("ステータス更新エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }
}