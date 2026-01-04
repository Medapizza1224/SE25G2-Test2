package control.order;
import java.util.ArrayList;
import java.util.List;
import dao.OrderItemDao;
import entity.Order;
import entity.OrderItem;

public class OrderHistory {
    public OrderHistoryResult execute(Order order) {
        if (order == null) return new OrderHistoryResult(new ArrayList<>(), 0);

        OrderItemDao dao = new OrderItemDao();
        try {
            // 商品名なども結合して取得するメソッドが必要 (findByOrderIdWithProductInfo)
            List<OrderItem> list = dao.findByOrderId(order.getOrderId().toString());
            
            int total = list.stream().mapToInt(i -> i.getPrice() * i.getQuantity()).sum();
            
            return new OrderHistoryResult(list, total);
        } catch (Exception e) {
            e.printStackTrace();
            return new OrderHistoryResult(new ArrayList<>(), 0);
        }
    }
}