

package entity;

import modelUtil.Failure;

// クラスの定義
public class OrderCounts {

    // フィールド
    private String productId;
    private int orderCountFromSingleAdult;
    private int orderCountFromTwoAdults;
    private int orderCountFromFamilyGroup;
    private int orderCountFromAdultGroup;
    private int orderCountFromGroup;

    // コンストラクタ
    public OrderCounts(String productId, int orderCountFromSingleAdult, int orderCountFromTwoAdults, int orderCountFromFamilyGroup, int orderCountFromAdultGroup, int orderCountFromGroup) throws Failure {
        setProductId(productId);
        setOrderCountFromSingleAdult(orderCountFromSingleAdult);
        setOrderCountFromTwoAdults(orderCountFromTwoAdults);
        setOrderCountFromFamilyGroup(orderCountFromFamilyGroup);
        setOrderCountFromAdultGroup(orderCountFromAdultGroup);
        setOrderCountFromGroup(orderCountFromGroup);
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
            throw new Failure("商品IDの入力エラーです。");
        }
        if (productId.length() > 32) {
            throw new Failure("商品IDは32文字以内で入力してください。");
        }
    }

    // 1人のお客様が注文した数
    public int getOrderCountFromSingleAdult() {
        return orderCountFromSingleAdult;
    }

    public void setOrderCountFromSingleAdult(int orderCountFromSingleAdult) throws Failure {
        checkOrderCount(orderCountFromSingleAdult, "1人のお客様の注文数");
        this.orderCountFromSingleAdult = orderCountFromSingleAdult;
    }

    // 2人のお客様が注文した数
    public int getOrderCountFromTwoAdults() {
        return orderCountFromTwoAdults;
    }

    public void setOrderCountFromTwoAdults(int orderCountFromTwoAdults) throws Failure {
        checkOrderCount(orderCountFromTwoAdults, "2人のお客様の注文数");
        this.orderCountFromTwoAdults = orderCountFromTwoAdults;
    }

    // ファミリーのお客様が注文した数
    public int getOrderCountFromFamilyGroup() {
        return orderCountFromFamilyGroup;
    }

    public void setOrderCountFromFamilyGroup(int orderCountFromFamilyGroup) throws Failure {
        checkOrderCount(orderCountFromFamilyGroup, "ファミリーの注文数");
        this.orderCountFromFamilyGroup = orderCountFromFamilyGroup;
    }

    // 大人グループのお客様が注文した数
    public int getOrderCountFromAdultGroup() {
        return orderCountFromAdultGroup;
    }

    public void setOrderCountFromAdultGroup(int orderCountFromAdultGroup) throws Failure {
        checkOrderCount(orderCountFromAdultGroup, "大人グループの注文数");
        this.orderCountFromAdultGroup = orderCountFromAdultGroup;
    }

    // グループのお客様が注文した数
    public int getOrderCountFromGroup() {
        return orderCountFromGroup;
    }

    public void setOrderCountFromGroup(int orderCountFromGroup) throws Failure {
        checkOrderCount(orderCountFromGroup, "グループの注文数");
        this.orderCountFromGroup = orderCountFromGroup;
    }

    // 共通化
    private void checkOrderCount(int count, String fieldName) throws Failure {
        if (count < 0) {
            throw new Failure(fieldName + "で、カウントエラーです。");
        }
    }
}