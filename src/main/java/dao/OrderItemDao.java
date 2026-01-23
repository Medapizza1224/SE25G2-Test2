package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import entity.OrderItem;

public class OrderItemDao {
    private final javax.sql.DataSource dataSource; // 変更
    private final ConnectionCloser connectionCloser;

    public OrderItemDao() {
        this.dataSource = new DataSourceHolder().dataSource; // 変更
        this.connectionCloser = new ConnectionCloser();
    }


    // 注文明細の一括登録
    public void insertBatch(Connection con, List<OrderItem> items, String orderId) throws SQLException {
        String sql = "INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (OrderItem item : items) {
                ps.setString(1, UUID.randomUUID().toString());
                ps.setString(2, orderId);
                ps.setString(3, item.getProductId());
                ps.setInt(4, item.getQuantity());
                ps.setInt(5, item.getPrice());
                ps.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
                ps.setString(7, "調理中");
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    // 履歴取得
    public List<OrderItem> findByOrderId(String orderId) throws DaoException {
        List<OrderItem> list = new ArrayList<>();
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "SELECT oi.*, p.product_name, p.image FROM order_items oi JOIN products p ON oi.product_id = p.product_id WHERE oi.order_id = ? ORDER BY oi.add_order_at DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(UUID.fromString(rs.getString("order_item_id")));
                item.setProductId(rs.getString("product_id"));
                item.setProductName(rs.getString("product_name"));
                item.setImage(rs.getString("image"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPrice(rs.getInt("price"));
                item.setAddOrderAt(rs.getTimestamp("add_order_at"));
                item.setOrderStatus(rs.getString("order_status"));
                list.add(item);
            }
        } catch (Exception e) { throw new DaoException("履歴取得エラー", e); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public boolean hasUnservedItems(String orderId) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            // 調理中（提供されていない）商品が1つでもあるか
            String sql = "SELECT COUNT(*) FROM order_items WHERE order_id = ? AND order_status = '調理中'";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (Exception e) { throw new DaoException("チェックエラー", e); }
        finally { connectionCloser.closeConnection(con); }
    }

    // キッチン用
    public List<OrderItem> findUnserved() throws DaoException {
        List<OrderItem> list = new ArrayList<>();
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "SELECT oi.*, p.product_name, o.table_number FROM order_items oi JOIN products p ON oi.product_id = p.product_id JOIN orders o ON oi.order_id = o.order_id WHERE oi.order_status = '調理中' ORDER BY oi.add_order_at ASC";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(UUID.fromString(rs.getString("order_item_id")));
                item.setTableNumber(rs.getString("table_number"));
                item.setProductName(rs.getString("product_name"));
                item.setQuantity(rs.getInt("quantity"));
                item.setAddOrderAt(rs.getTimestamp("add_order_at"));
                list.add(item);
            }
        } catch (Exception e) { throw new DaoException("キッチンリスト取得エラー", e); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public void updateStatus(String orderItemId, String status) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "UPDATE order_items SET order_status = ?, order_completed_at = NOW() WHERE order_item_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, orderItemId);
            ps.executeUpdate();
        } catch (Exception e) { throw new DaoException("ステータス更新エラー", e); }
        finally { connectionCloser.closeConnection(con); }
    }

    public int countUnservedItems(String orderId) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "SELECT SUM(quantity) FROM order_items WHERE order_id = ? AND order_status = '調理中'";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1); // 調理中の総個数を返す
            }
            return 0;
        } catch (Exception e) { throw new DaoException("カウントエラー", e); }
        finally { connectionCloser.closeConnection(con); }
    }
}