package control.order;

import entity.Order;

public class OrderShowQR {
    public OrderShowQRResult execute(Order order, String baseUrl) {
        // nullチェック
        if (order == null) {
            return new OrderShowQRResult(null, null);
        }
        
        String orderIdStr = order.getOrderId().toString();

        // 決済URL生成ロジック
        String url = baseUrl + "/UserPayment?orderId=" + orderIdStr;
        
        // ★修正: URLだけでなく、注文IDもResultに詰めて返す
        return new OrderShowQRResult(url, orderIdStr);
    }
}