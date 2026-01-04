package control.order;
import java.util.List;
import entity.OrderItem;

public class OrderHistoryResult {
    private List<OrderItem> historyList;
    private int totalAmount;

    public OrderHistoryResult(List<OrderItem> historyList, int totalAmount) {
        this.historyList = historyList;
        this.totalAmount = totalAmount;
    }
    public List<OrderItem> getHistoryList() { return historyList; }
    public int getTotalAmount() { return totalAmount; }
}