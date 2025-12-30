package control;

import java.util.ArrayList;
import java.util.List;
import entity.Product;

public class ProductViewTestResult {
    
    private List<Product> productList; // 取得したデータ
    private String errorMessage;       // エラー時のメッセージ
    private boolean success;           // 成功フラグ

    // 成功時用コンストラクタ
    public ProductViewTestResult(List<Product> productList) {
        this.productList = productList;
        this.success = true;
    }

    // 失敗時用コンストラクタ
    public ProductViewTestResult(String errorMessage) {
        this.productList = new ArrayList<>(); // null回避
        this.errorMessage = errorMessage;
        this.success = false;
    }

    // Getter
    public List<Product> getProductList() { return productList; }
    public String getErrorMessage() { return errorMessage; }
    public boolean isSuccess() { return success; }
}