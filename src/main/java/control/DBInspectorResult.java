package control;

import java.util.List;
import entity.*;

public class DBInspectorResult {
    private List<Admin> admins;
    private List<User> users;
    private List<Product> products;
    private List<Order> orders;
    private List<OrderItem> orderItems;
    private List<Payment> payments;
    private List<Ledger> ledgers;
    private List<OrderCount> orderCounts;
    private List<Analysis> analysis;

    public DBInspectorResult(List<Admin> admins, List<User> users, List<Product> products,
                             List<Order> orders, List<OrderItem> orderItems, List<Payment> payments,
                             List<Ledger> ledgers, List<OrderCount> orderCounts, List<Analysis> analysis) {
        this.admins = admins;
        this.users = users;
        this.products = products;
        this.orders = orders;
        this.orderItems = orderItems;
        this.payments = payments;
        this.ledgers = ledgers;
        this.orderCounts = orderCounts;
        this.analysis = analysis;
    }

    public List<Admin> getAdmins() { return admins; }
    public List<User> getUsers() { return users; }
    public List<Product> getProducts() { return products; }
    public List<Order> getOrders() { return orders; }
    public List<OrderItem> getOrderItems() { return orderItems; }
    public List<Payment> getPayments() { return payments; }
    public List<Ledger> getLedgers() { return ledgers; }
    public List<OrderCount> getOrderCounts() { return orderCounts; }
    public List<Analysis> getAnalysis() { return analysis; }
}