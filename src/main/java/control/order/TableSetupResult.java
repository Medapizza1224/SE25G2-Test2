package control.order;

import java.util.List;
import entity.Order;

public class TableSetupResult {
    private List<Order> activeOrders;

    public TableSetupResult(List<Order> activeOrders) {
        this.activeOrders = activeOrders;
    }

    public List<Order> getActiveOrders() {
        return activeOrders;
    }
}