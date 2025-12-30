package entity;

import java.sql.Timestamp;
import modelUtil.Failure;

// クラスの定義
public class Analysis {

    // フィールド
    private String productId;
    private String customerSegment;
    private int orderCount;
    private Timestamp updateDate;

    // コンストラクタ
    public Analysis(String productId, String customerSegment, int orderCount, Timestamp updateDate) throws Failure {
        setProductId(productId);
        setCustomerSegment(customerSegment);
        setOrderCount(orderCount);
        setUpdateDate(updateDate);
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

    // 客層
    public String getCustomerSegment() {
        return customerSegment;
    }

    public void setCustomerSegment(String customerSegment) throws Failure {
        checkCustomerSegment(customerSegment);
        this.customerSegment = customerSegment;
    }

    private void checkCustomerSegment(String customerSegment) throws Failure {
        if (customerSegment == null || customerSegment.isEmpty()) {
            throw new Failure("客層を選択してください。");
        }
        // 備考にある特定の客層以外を弾くバリデーション
        if (!(customerSegment.equals("大人1人") || 
              customerSegment.equals("大人2人") || 
              customerSegment.equals("ファミリー") || 
              customerSegment.equals("大人グループ") || 
              customerSegment.equals("グループ"))) {
            throw new Failure("客層の設定が不正です。");
        }
    }

    // 注文数
    public int getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(int orderCount) throws Failure {
        checkOrderCount(orderCount);
        this.orderCount = orderCount;
    }

    private void checkOrderCount(int orderCount) throws Failure {
        if (orderCount < 0) {
            throw new Failure("注文数は0以上の数値を設定してください。");
        }
    }

    // 更新日時
    public Timestamp getUpdateDate() {
        return updateDate;
    }

    public void setUpdateDate(Timestamp updateDate) throws Failure {
        checkUpdateDate(updateDate);
        this.updateDate = updateDate;
    }

    private void checkUpdateDate(Timestamp updateDate) throws Failure {
        if (updateDate == null) {
            throw new Failure("更新日時が不正です。");
        }
    }
}