package control.order;

public class OrderShowQRResult {
    private String paymentUrl;
    private String orderId; // ★追加: ポーリング用に注文IDが必要

    public OrderShowQRResult(String paymentUrl, String orderId) {
        this.paymentUrl = paymentUrl;
        this.orderId = orderId;
    }

    public String getPaymentUrl() {
        return paymentUrl;
    }

    public String getOrderId() {
        return orderId;
    }
}