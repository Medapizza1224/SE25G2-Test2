package control.admin;

import java.util.List;
import entity.Product;

public class AdminProductListResult {
    
    private List<Product> productList;

    public AdminProductListResult(List<Product> productList) {
        this.productList = productList;
    }

    public List<Product> getProductList() {
        return productList;
    }
}