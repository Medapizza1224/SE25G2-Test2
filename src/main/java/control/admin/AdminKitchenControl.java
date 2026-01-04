package control.admin;

import java.util.List;
import dao.OrderItemDao;
import entity.OrderItem;

public class AdminKitchenControl {
    
    public AdminKitchenResult execute() {
        try {
            OrderItemDao dao = new OrderItemDao();
            
            // "調理中" の注文リストをデータベースから取得
            // ※DAO内で products テーブルと結合し、productName も取得済みのデータが返ってきます
            List<OrderItem> list = dao.findUnserved();
            
            return new AdminKitchenResult(list);
            
        } catch (Exception e) {
            e.printStackTrace();
            // エラー時は null を渡して、JSP側で "注文はありません" 等の表示に倒す
            return new AdminKitchenResult(null);
        }
    }
}