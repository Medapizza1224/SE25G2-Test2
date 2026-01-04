package control.admin;

import dao.OrderItemDao;

public class AdminKitchenUpdateControl {
    public void execute(String orderItemId) {
        try {
            OrderItemDao dao = new OrderItemDao();
            // ステータスを「提供済」に更新
            dao.updateStatus(orderItemId, "提供済");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}