package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import entity.*;

public class DBInspectorDao {
    private final DataSourceHolder dbHolder;
    private final ConnectionCloser connectionCloser;

    public DBInspectorDao() {
        this.dbHolder = new DataSourceHolder();
        this.connectionCloser = new ConnectionCloser();
    }

    public List<Admin> getAllAdmins() {
        List<Admin> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM admins");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                Admin a = new Admin();
                a.setAdminName(rs.getString("admin_name"));
                a.setAdminPassword(rs.getString("admin_password"));
                list.add(a);
            }
        } catch (Exception e) { e.printStackTrace(); } 
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM users");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                User u = new User();
                u.setUserId(UUID.fromString(rs.getString("user_id")));
                u.setUserName(rs.getString("user_name"));
                u.setUserPassword(rs.getString("user_password"));
                u.setSecurityCode(rs.getString("security_code"));
                u.setBalance(rs.getInt("balance"));
                u.setPoint(rs.getInt("point"));
                u.setLoginAttemptCount(rs.getInt("login_attempt_count"));
                u.setLockout(rs.getBoolean("is_lockout"));
                list.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM products");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                list.add(new Product(
                    rs.getString("product_id"),
                    rs.getString("image"),
                    rs.getString("product_name"),
                    rs.getString("category"),
                    rs.getInt("price"),
                    rs.getString("sales_status"),
                    rs.getTimestamp("update_at")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM orders ORDER BY visit_at DESC");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                Order o = new Order();
                o.setOrderId(UUID.fromString(rs.getString("order_id")));
                o.setTableNumber(rs.getString("table_number"));
                o.setAdultCount(rs.getInt("adult_count"));
                o.setChildCount(rs.getInt("child_count"));
                o.setPaymentCompleted(rs.getBoolean("is_payment_completed"));
                o.setVisitAt(rs.getTimestamp("visit_at"));
                list.add(o);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public List<OrderItem> getAllOrderItems() {
        List<OrderItem> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM order_items ORDER BY add_order_at DESC");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                OrderItem oi = new OrderItem();
                oi.setOrderItemId(UUID.fromString(rs.getString("order_item_id")));
                oi.setOrderId(UUID.fromString(rs.getString("order_id")));
                oi.setProductId(rs.getString("product_id"));
                oi.setQuantity(rs.getInt("quantity"));
                oi.setPrice(rs.getInt("price"));
                oi.setAddOrderAt(rs.getTimestamp("add_order_at"));
                oi.setOrderCompletedAt(rs.getTimestamp("order_completed_at"));
                oi.setOrderStatus(rs.getString("order_status"));
                list.add(oi);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public List<Payment> getAllPayments() {
        List<Payment> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM payments ORDER BY payment_completed_at DESC");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                list.add(new Payment(
                    UUID.fromString(rs.getString("order_id")),
                    UUID.fromString(rs.getString("user_id")),
                    rs.getInt("used_points"),
                    rs.getInt("earned_points"),
                    rs.getTimestamp("payment_completed_at")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public List<Ledger> getAllLedgers() {
        List<Ledger> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM ledger ORDER BY height DESC");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                list.add(new Ledger(
                    rs.getInt("height"),
                    rs.getString("prev_hash"),
                    rs.getString("curr_hash"),
                    rs.getString("sender_id"),
                    rs.getInt("amount"),
                    rs.getString("signature"),
                    rs.getTimestamp("created_at")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public List<OrderCount> getAllOrderCounts() {
        List<OrderCount> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM order_counts");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                list.add(new OrderCount(
                    rs.getString("product_id"),
                    rs.getInt("order_count_from_single_adult"),
                    rs.getInt("order_count_from_two_adults"),
                    rs.getInt("order_count_from_family_group"),
                    rs.getInt("order_count_from_adult_group"),
                    rs.getInt("order_count_from_group")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }

    public List<Analysis> getAllAnalysis() {
        List<Analysis> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM analysis ORDER BY analysis_date DESC, product_id ASC");
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                Analysis a = new Analysis();
                a.setAnalysisDate(rs.getDate("analysis_date"));
                a.setProductId(rs.getString("product_id"));
                a.setCountSingle(rs.getInt("count_single"));
                a.setCountPair(rs.getInt("count_pair"));
                a.setCountFamily(rs.getInt("count_family"));
                a.setCountAdultGroup(rs.getInt("count_adult_group"));
                a.setCountGroup(rs.getInt("count_group"));
                list.add(a);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { connectionCloser.closeConnection(con); }
        return list;
    }
}