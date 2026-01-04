package entity;

import java.sql.Timestamp;
import modelUtil.Failure;

// クラスの定義
public class Product {

    // フィールド
    private String productId;
    private String image;
    private String productName;
    private String category;
    private int price;
    private String salesStatus;
    private Timestamp updateAt;

    // デフォルトコンストラクタ
    public Product() {}

    // コンストラクタ
    public Product (String productId, String image, String productName, String category, int price, String salesStatus, Timestamp updateAt) throws Failure {
        setProductId(productId);
        setImage(image); 
        setProductName(productName);
        setCategory(category);
        setPrice(price);
        setSalesStatus(salesStatus);
        setUpdateAt(updateAt);
    }
    
    // 商品ID
    // データの取り出し（外のファイルから）
    public String getProductId() {
        return productId;
    }

    // データの書き換え（外のファイルから）
    public void setProductId(String productId) throws Failure {
        checkProductId(productId);
        this.productId = productId;
    }

    private void checkProductId(String productId) throws Failure {
        if (productId == null || productId.isEmpty()) {
            throw new Failure("商品IDの入力エラーです。");
        }
        if (productId.length() > 32){
            throw new Failure ("商品IDは、半角英数20文字以内です。");
        }
    }

    // 商品画像
    public String getImage() {
        return image;
    }

    public void setImage(String image) throws Failure {
        checkImage(image);
        this.image = image;
    }

    private void checkImage(String image) throws Failure {
        /* 
        if (image == null) {
            throw new Failure("画像をアップロードしてください。");
        }*/
    }

    // 商品名
    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) throws Failure {
        checkProductName(productName);
        this.productName = productName;
    }

    private void checkProductName(String productName) throws Failure {
        if (productName == null || productName.isEmpty()) {
            throw new Failure("商品名の入力エラーです。");
        }
        if (productName.length() > 32){
            throw new Failure ("商品名は、半角英数32文字以内です。");
        }
    }

    // カテゴリ
    public String getCategory() {
        return category;
    }

    public void setCategory(String category) throws Failure {
        checkCategory(category);
        this.category = category;
    }

    private void checkCategory(String category) throws Failure {
        if (category == null || category.isEmpty()) {
            throw new Failure("カテゴリを選択してください。");
        }
        if (category.length() > 32) {
            throw new Failure("カテゴリ名は32文字以内で入力してください。");
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

    // 販売状況
    public String getSalesStatus() {
        return salesStatus;
    }

    public void setSalesStatus(String salesStatus) throws Failure {
        checkSalesStatus(salesStatus);
        this.salesStatus = salesStatus;
    }

    private void checkSalesStatus(String salesStatus) throws Failure {
        if (salesStatus == null || salesStatus.isEmpty()) {
            throw new Failure("販売状況を選択してください。");
        }
    }

    // 更新日時
    public java.sql.Timestamp getUpdateAt() {
        return updateAt;
    }

    public void setUpdateAt(java.sql.Timestamp updateAt) throws Failure {
        checkUpdateAt(updateAt);
        this.updateAt = updateAt;
    }

    private void checkUpdateAt(java.sql.Timestamp updateAt) throws Failure {
        if (updateAt == null) {
            throw new Failure("更新日時が不正です。");
        }
    }

}