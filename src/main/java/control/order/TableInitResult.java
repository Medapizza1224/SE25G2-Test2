package control.order;

public class TableInitResult {
    private boolean success;
    private String errorMessage;

    // 成功時
    public TableInitResult() {
        this.success = true;
        this.errorMessage = null;
    }

    // 失敗時
    public TableInitResult(String errorMessage) {
        this.success = false;
        this.errorMessage = errorMessage;
    }

    public boolean isSuccess() { return success; }
    public String getErrorMessage() { return errorMessage; }
}