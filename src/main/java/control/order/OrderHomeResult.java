package control.order;
import java.util.List;
import entity.Product;

public class OrderHomeResult {
    private List<Product> productList;
    private String currentCategory;

    public OrderHomeResult(List<Product> productList, String currentCategory) {
        this.productList = productList;
        this.currentCategory = currentCategory;
    }
    public List<Product> getProductList() { return productList; }
    public String getCurrentCategory() { return currentCategory; }
}