package control.order;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import dao.*;
import entity.*;
import modelUtil.*;

public class OrderRegisterControl {

    // 1回の来店での合計注文金額上限 (300,000円)
    private static final int MAX_TOTAL_AMOUNT = 300000;

    public OrderRegisterResult execute(Order order, Cart cart) {
        if (order == null || cart == null || cart.getItems().isEmpty()) {
            return new OrderRegisterResult(false, "カートが空です");
        }

        DataSourceHolder db = new DataSourceHolder();
        ConnectionCloser closer = new ConnectionCloser();
        Connection con = null;

        try {
            con = db.getConnection();
            
            // ★追加: 現在の注文合計金額を取得（DBから最新を取得）
            OrderDao orderDao = new OrderDao();
            Order currentOrder = orderDao.findById(order.getOrderId());
            int currentTotal = (currentOrder != null) ? currentOrder.getTotalAmount() : 0;
            
            // 今回のカート金額
            int cartTotal = cart.getTotalAmount();

            // 上限チェック
            if (currentTotal + cartTotal > MAX_TOTAL_AMOUNT) {
                return new OrderRegisterResult(false, "注文金額の上限（300,000円）を超えています。");
            }

            con.setAutoCommit(false); // トランザクション開始

            // 1. OrderItemテーブルへの登録
            List<OrderItem> dbItems = new ArrayList<>();
            for (CartItem ci : cart.getItems()) {
                OrderItem oi = new OrderItem();
                oi.setProductId(ci.getProduct().getProductId());
                oi.setQuantity(ci.getQuantity());
                oi.setPrice(ci.getProduct().getPrice());
                dbItems.add(oi);
            }
            OrderItemDao itemDao = new OrderItemDao();
            itemDao.insertBatch(con, dbItems, order.getOrderId().toString());

            // 2. OrderCountテーブル（分析用）の更新
            AnalysisDao anaDao = new AnalysisDao(); 
            String customerType = CustomerTypeLogic.determineType(order);
            
            for (CartItem ci : cart.getItems()) {
                anaDao.incrementCount(con, ci.getProduct().getProductId(), customerType, ci.getQuantity());
            }

            con.commit();
            return new OrderRegisterResult(true, "注文完了");

        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            return new OrderRegisterResult(false, "エラー: " + e.getMessage());
        } finally {
            closer.closeConnection(con);
        }
    }
}