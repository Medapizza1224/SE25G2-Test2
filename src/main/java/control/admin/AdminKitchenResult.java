
package control.admin;

import java.util.List;
import entity.OrderItem;

public class AdminKitchenResult {
    private List<OrderItem> unservedList;

    public AdminKitchenResult(List<OrderItem> unservedList) {
        this.unservedList = unservedList;
    }

    public List<OrderItem> getUnservedList() {
        return unservedList;
    }
}