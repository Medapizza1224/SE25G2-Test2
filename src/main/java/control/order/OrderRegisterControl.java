package control.order;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import dao.*;
import entity.*;
import modelUtil.*;

public class OrderRegisterControl {

    // ★変更: 注文個数の上限 (50個)
    private static final int MAX_TOTAL_QUANTITY = 50;

    public OrderRegisterResult execute(Order order, Cart cart) {
        if (order == null || cart == null || cart.getItems().isEmpty()) {
            return new OrderRegisterResult(false, "カートが空です");
        }

        javax.sql.DataSource dataSource = new DataSourceHolder().dataSource;
        ConnectionCloser closer = new ConnectionCloser();
        Connection con = null;

        try {
            // 1. 現在の注文済み個数を取得
            OrderDao orderDao = new OrderDao();
            int currentTotalQty = orderDao.countTotalItems(order.getOrderId());
            
            // 2. カート内の個数を取得
            int cartQty = cart.getTotalQuantity();

            // 3. 上限チェック (50個)
            if (currentTotalQty + cartQty > MAX_TOTAL_QUANTITY) {
                // 詳細なエラーメッセージを作成
                String msg = "ご注文数の上限（" + MAX_TOTAL_QUANTITY + "品）を超過しています。\n\n"
                           + "現在の注文済み： " + currentTotalQty + " 品\n"
                           + "カートの商品数： " + cartQty + " 品\n"
                           + "----------------------\n"
                           + "合　計　　　　： " + (currentTotalQty + cartQty) + " 品\n\n"
                           + "一度のご来店で注文できるのは最大50品までです。\n"
                           + "カートの内容を減らすか、店員をお呼びください。";
                
                return new OrderRegisterResult(false, msg);
            }

            con = dataSource.getConnection();
            con.setAutoCommit(false); // トランザクション開始

            // 4. OrderItemテーブルへの登録
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

            // 5. OrderCountテーブル（分析用）の更新
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
            return new OrderRegisterResult(false, "システムエラーが発生しました: " + e.getMessage());
        } finally {
            closer.closeConnection(con);
        }
    }
}