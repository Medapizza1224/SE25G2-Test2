package control.admin;

public class AdminProductSaveResult {
    private boolean success;
    private String errorMessage;

    public AdminProductSaveResult(boolean success, String errorMessage) {
        this.success = success;
        this.errorMessage = errorMessage;
    }
    public boolean isSuccess() { return success; }
    public String getErrorMessage() { return errorMessage; }
}