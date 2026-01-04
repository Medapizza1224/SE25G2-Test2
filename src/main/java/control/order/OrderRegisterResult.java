package control.order;

public class OrderRegisterResult {
    private boolean isSuccess;
    private String message;

    public OrderRegisterResult(boolean isSuccess, String message) {
        this.isSuccess = isSuccess;
        this.message = message;
    }
    public boolean isSuccess() { return isSuccess; }
    public String getMessage() { return message; }
}