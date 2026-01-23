package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import entity.Order;

public class OrderDao {
    
    private final javax.sql.DataSource dataSource; // 変更
    private final ConnectionCloser connectionCloser;

    public OrderDao() {
        this.dataSource = new DataSourceHolder().dataSource; // 変更
        this.connectionCloser = new ConnectionCloser();
    }

    /**
     * 新規伝票作成 (来店時)
     */
    public void create(Order order) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
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
            con = this.dataSource.getConnection();
            return findById(con, orderId);
        } catch (Exception e) {
            throw new DaoException("伝票取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    // 内部利用用 (Connectionを受け取る版)
    private Order findById(Connection con, UUID orderId) throws Exception {
        String sqlHead = "SELECT * FROM orders WHERE order_id = ?";
        PreparedStatement psHead = con.prepareStatement(sqlHead);
        psHead.setString(1, orderId.toString());
        ResultSet rsHead = psHead.executeQuery();
        
        if (rsHead.next()) {
            Order order = new Order();
            order.setOrderId(UUID.fromString(rsHead.getString("order_id")));
            order.setTableNumber(rsHead.getString("table_number"));
            order.setAdultCount(rsHead.getInt("adult_count"));
            order.setChildCount(rsHead.getInt("child_count"));
            order.setPaymentCompleted(rsHead.getBoolean("is_payment_completed"));
            order.setVisitAt(rsHead.getTimestamp("visit_at"));
            
            int total = calculateTotalAmount(con, orderId);
            order.setTotalAmount(total);
            return order;
        }
        return null;
    }

    /**
     * ★追加: 未会計（稼働中）の注文リストを取得 (テーブル番号順)
     */
    public List<Order> findActiveOrders() throws DaoException {
        List<Order> list = new ArrayList<>();
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "SELECT * FROM orders WHERE is_payment_completed = FALSE ORDER BY table_number ASC";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(UUID.fromString(rs.getString("order_id")));
                order.setTableNumber(rs.getString("table_number"));
                order.setAdultCount(rs.getInt("adult_count"));
                order.setChildCount(rs.getInt("child_count"));
                order.setPaymentCompleted(rs.getBoolean("is_payment_completed"));
                order.setVisitAt(rs.getTimestamp("visit_at"));
                list.add(order);
            }
        } catch (Exception e) {
            throw new DaoException("稼働中リスト取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }

    /**
     * ★追加: 指定したテーブル番号で未会計の注文が存在するかチェック
     */
    public boolean isTableOccupied(String tableNumber) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "SELECT COUNT(*) FROM orders WHERE table_number = ? AND is_payment_completed = FALSE";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, tableNumber);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (Exception e) {
            throw new DaoException("テーブル重複チェックエラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }
    /**
     * 指定した注文IDに紐づく、注文済みの商品総数を取得する
     */
    public int countTotalItems(UUID orderId) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            // order_itemsテーブルのquantityを合計する
            String sql = "SELECT SUM(quantity) as total_qty FROM order_items WHERE order_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, orderId.toString());
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total_qty");
            }
            return 0;
        } catch (Exception e) {
            throw new DaoException("注文数カウントエラー", e);
        } finally {
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