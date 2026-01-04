package control.admin;
import entity.Product;

public class AdminProductEditResult {
    private Product product;
    private String mode; // "insert" または "update"

    public AdminProductEditResult(Product product, String mode) {
        this.product = product;
        this.mode = mode;
    }
    public Product getProduct() { return product; }
    public String getMode() { return mode; }
}