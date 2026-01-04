package control.order;
import java.util.List;
import dao.ProductDao;
import entity.Product;

public class OrderHome {
    public OrderHomeResult execute(String category) {
        if (category == null || category.isEmpty()) {
            category = "肉"; // デフォルト
        }
        ProductDao dao = new ProductDao();
        // ※DAOにfindByCategoryメソッドがある前提
        try {
            List<Product> list = dao.findByCategory(category);
            return new OrderHomeResult(list, category);
        } catch (Exception e) {
            e.printStackTrace();
            return new OrderHomeResult(null, category);
        }
    }
}