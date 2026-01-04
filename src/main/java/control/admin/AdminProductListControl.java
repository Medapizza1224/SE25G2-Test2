package control.admin;

import java.util.List;
import dao.ProductDao;
import entity.Product;

public class AdminProductListControl {

    public AdminProductListResult execute() {
        try {
            ProductDao dao = new ProductDao();
            // 全商品を取得
            List<Product> list = dao.viewProductAll();
            
            return new AdminProductListResult(list);
            
        } catch (Exception e) {
            e.printStackTrace();
            return new AdminProductListResult(null);
        }
    }
}