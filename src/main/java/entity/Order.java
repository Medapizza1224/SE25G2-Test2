package entity;

import java.sql.Timestamp;
import modelUtil.Failure;
import java.util.UUID;

// クラスの定義
public class Order {

    // フィールド
    private UUID orderId;
    private String tableNumber;
    private int adultCount;
    private int childCount;
    private boolean isPaymentCompleted;
    private Timestamp visitAt;

    // コンストラクタ
    public Order(UUID orderId, String tableNumber, int adultCount, int childCount, boolean isPaymentCompleted, Timestamp visitAt) throws Failure {
        setOrderId(orderId);
        setTableNumber(tableNumber);
        setAdultCount(adultCount);
        setChildCount(childCount);
        setPaymentCompleted(isPaymentCompleted);
        setVisitAt(visitAt);
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
        if (orderId == null) { // isEmpty：String型のみ
            throw new Failure("伝票IDの入力エラーです。");
        }
    }

    // テーブル番号 (4桁の数字)
    public String getTableNumber() {
        return tableNumber;
    }

    public void setTableNumber(String tableNumber) throws Failure {
        checkTableNumber(tableNumber);
        this.tableNumber = tableNumber;
    }

    private void checkTableNumber(String tableNumber) throws Failure {
        if (tableNumber == null || !tableNumber.matches("^[0-9]{4}$")) {
            throw new Failure("テーブル番号は、4桁の数字（0000〜9999）で入力してください。");
        }
    }

    // 大人人数 (1〜8人)
    public int getAdultCount() {
        return adultCount;
    }

    public void setAdultCount(int adultCount) throws Failure {
        checkAdultCount(adultCount);
        this.adultCount = adultCount;
    }

    private void checkAdultCount(int adultCount) throws Failure {
        if (adultCount < 1 || adultCount > 8) {
            throw new Failure("大人の人数のエラー"); // 画面上に出ることはない（JSP上で制限）
        }
    }

    // 子供人数 (0〜7人)
    public int getChildCount() {
        return childCount;
    }

    public void setChildCount(int childCount) throws Failure {
        checkChildCount(childCount);
        this.childCount = childCount;
    }

    private void checkChildCount(int childCount) throws Failure {
        if (childCount < 0 || childCount > 7) {
            throw new Failure("子供の人数のエラー"); // 画面上に出ることはない
        }
    }

    // 決済完了
    public boolean isPaymentCompleted() {
        return isPaymentCompleted;
    }

    public void setPaymentCompleted(boolean isPaymentCompleted) {
        this.isPaymentCompleted = isPaymentCompleted;
    }

    // 来店日時
    public Timestamp getVisitAt() {
        return visitAt;
    }

    public void setVisitAt(Timestamp visitAt) throws Failure {
        checkVisitAt(visitAt);
        this.visitAt = visitAt;
    }

    private void checkVisitAt(Timestamp visitAt) throws Failure {
        if (visitAt == null) {
            throw new Failure("来店日時が不正です。");
        }
    }
}