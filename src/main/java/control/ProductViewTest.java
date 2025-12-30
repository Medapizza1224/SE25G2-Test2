package control;

import java.util.List;
import dao.DaoException;
import dao.ProductDao;
import entity.Product;

public class ProductViewTest {

    // 一覧取得メソッド
    public ProductViewTestResult getProductList() {
        ProductDao dao = new ProductDao();
        try {
            // DAO実行
            List<Product> list = dao.viewProductAll();
            
            // 成功結果を返す
            return new ProductViewTestResult(list);
            
        } catch (DaoException e) {
            // 失敗結果を返す
            e.printStackTrace();
            return new ProductViewTestResult("システムエラーが発生しました: " + e.getMessage());
        }
    }
}