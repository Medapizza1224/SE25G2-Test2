package entity;

import java.sql.Timestamp;
import modelUtil.Failure;
import java.util.UUID;

// クラスの定義
public class OrderItem {

    // フィールド
    private UUID orderItemId;
    private UUID orderId;
    private String productId;
    
    // ★追加: 画面表示用（DBのorder_itemsテーブルにはないが、JOIN結果を入れるため）
    private String productName; 
    private String image;
    private String tableNumber;

    private int quantity;
    private int price;
    private Timestamp addOrderAt;
    private Timestamp orderCompletedAt;
    private String orderStatus;
    

    // ★追加: 引数なしコンストラクタ (DAOで使用するため必須)
    public OrderItem() {
    }

    // 全項目コンストラクタ
    public OrderItem(UUID orderItemId, UUID orderId, String productId, int quantity, int price, Timestamp addOrderAt, Timestamp orderCompletedAt, String orderStatus) throws Failure {
        setOrderItemId(orderItemId);
        setOrderId(orderId);
        setProductId(productId);
        setQuantity(quantity);
        setPrice(price);
        setAddOrderAt(addOrderAt);
        setOrderCompletedAt(orderCompletedAt);
        setOrderStatus(orderStatus);
    }

    // --- Getter / Setter ---

    // 注文項目ID
    public UUID getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(UUID orderItemId) throws Failure {
        checkOrderItemId(orderItemId);
        this.orderItemId = orderItemId;
    }

    private void checkOrderItemId(UUID orderItemId) throws Failure {
        if (orderItemId == null) {
            throw new Failure("注文項目IDが正しくありません。");
        }
    }

    // 伝票ID
    public UUID getOrderId() {
        return orderId;
    }

    public void setOrderId(UUID orderId) throws Failure {
        checkOrderId(orderId);
        this.orderId = orderId;
    }

    private void checkOrderId(UUID orderId) throws Failure {
        if (orderId == null) {
            throw new Failure("伝票IDが正しくありません。");
        }
    }

    // 商品ID
    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) throws Failure {
        checkProductId(productId);
        this.productId = productId;
    }

    private void checkProductId(String productId) throws Failure {
        if (productId == null || productId.isEmpty()) {
            throw new Failure("商品IDが正しくありません。");
        }
        if (productId.length() > 32) {
            throw new Failure("商品IDは32文字以内で入力してください。");
        }
    }

    // ★追加 Getter/Setter
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    // ★追加: 商品名 (表示用なのでバリデーションは任意ですが、Setterは用意)
    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getTableNumber() {
        return tableNumber;
    }

    public void setTableNumber(String tableNumber) {
        this.tableNumber = tableNumber;
    }

    // 個数 (1〜10個)
    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) throws Failure {
        checkQuantity(quantity);
        this.quantity = quantity;
    }

    private void checkQuantity(int quantity) throws Failure {
        if (quantity < 1) {
            throw new Failure("個数は1個以上で設定してください。");
        }
    }

    // 価格
    public int getPrice() {
        return price;
    }

    public void setPrice(int price) throws Failure {
        checkPrice(price);
        this.price = price;
    }

    private void checkPrice(int price) throws Failure {
        if (price < 0) {
            throw new Failure("価格は0円以上に設定してください。");
        }
    }

    // 注文カゴ追加日時
    public Timestamp getAddOrderAt() {
        return addOrderAt;
    }

    public void setAddOrderAt(Timestamp addOrderAt) throws Failure {
        checkAddOrderAt(addOrderAt);
        this.addOrderAt = addOrderAt;
    }

    private void checkAddOrderAt(Timestamp addOrderAt) throws Failure {
        if (addOrderAt == null) {
            throw new Failure("注文追加日時が不正です。");
        }
    }

    // 注文確定日時 (Not Null: NO なので null を許容)
    public Timestamp getOrderCompletedAt() {
        return orderCompletedAt;
    }

    public void setOrderCompletedAt(Timestamp orderCompletedAt) {
        // nullを許容するため、特別なバリデーションは行わない
        this.orderCompletedAt = orderCompletedAt;
    }

    // 注文状況
    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) throws Failure {
        checkOrderStatus(orderStatus);
        this.orderStatus = orderStatus;
    }

    private void checkOrderStatus(String orderStatus) throws Failure {
        if (orderStatus == null || orderStatus.isEmpty()) {
            throw new Failure("注文状況を選択してください。");
        }
        // 特定のステータス以外を弾く場合（任意）
        if (!(orderStatus.equals("注文カゴ") || orderStatus.equals("調理中") || orderStatus.equals("提供済"))) {
            throw new Failure("注文状況が不正です。");
        }
    }
}