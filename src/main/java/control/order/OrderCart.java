package control.order;

import dao.ProductDao;
import entity.Product;
import modelUtil.Cart;

public class OrderCart {
    public OrderCartResult execute(Cart cart, String action, String productId, String quantityStr) {
        
        // 1. カートがnullの場合は何もせずホームへ戻す（セッション切れ対策）
        if (cart == null) {
            return new OrderCartResult("OrderHome");
        }

        try {
            if ("add".equals(action)) {
                // 2. 数量のチェック
                int quantity = 1;
                if (quantityStr != null && !quantityStr.isEmpty()) {
                    quantity = Integer.parseInt(quantityStr);
                }

                ProductDao dao = new ProductDao();
                Product p = dao.findById(productId);
                
                // 3. 商品が存在する場合のみ追加
                if (p != null) {
                    cart.add(p, quantity);
                }
                
            } else if ("remove".equals(action)) {
                cart.remove(productId);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // エラーが発生しても、ここでは握りつぶしてホームへ戻す
        }
        
        // 処理後は必ず OrderHome へリダイレクトして最新のカート状況を表示
        return new OrderCartResult("OrderHome");
    }
}