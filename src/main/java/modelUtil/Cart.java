package modelUtil;
import java.util.ArrayList;
import java.util.List;
import entity.Product;

public class Cart {
    private List<CartItem> items = new ArrayList<>();

    public void add(Product product, int quantity) {
        for (CartItem item : items) {
            if (item.getProduct().getProductId().equals(product.getProductId())) {
                item.setQuantity(item.getQuantity() + quantity);
                return;
            }
        }
        items.add(new CartItem(product, quantity));
    }
    public void remove(String productId) {
        items.removeIf(i -> i.getProduct().getProductId().equals(productId));
    }
    public int getTotalAmount() {
        return items.stream().mapToInt(CartItem::getSubTotal).sum();
    }
    
    // ★追加: カート内の商品総数を取得
    public int getTotalQuantity() {
        return items.stream().mapToInt(CartItem::getQuantity).sum();
    }

    public List<CartItem> getItems() { return items; }
    public void clear() { items.clear(); }
}