package control.order;

public class OrderCartResult {
    // 今回は画面遷移先だけわかればよい
    private String redirectUrl;
    public OrderCartResult(String redirectUrl) { this.redirectUrl = redirectUrl; }
    public String getRedirectUrl() { return redirectUrl; }
}