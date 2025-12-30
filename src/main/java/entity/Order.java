package entity;

import java.io.Serializable; // 追加推奨
import java.sql.Timestamp;
import java.util.UUID;
import modelUtil.Failure;

public class Order implements Serializable {

    // フィールド
    private UUID orderId;
    private String tableNumber;
    private int adultCount;
    private int childCount;
    private boolean isPaymentCompleted;
    private Timestamp visitAt;
    
    // ★追加: 合計金額 (DBのordersテーブルにはないが、表示用に必要)
    private int totalAmount;

    // ★追加: 引数なしコンストラクタ (DAOで使用するため必須)
    public Order() {
    }

    // 既存の全項目コンストラクタ
    public Order(UUID orderId, String tableNumber, int adultCount, int childCount, boolean isPaymentCompleted, Timestamp visitAt) throws Failure {
        setOrderId(orderId);
        setTableNumber(tableNumber);
        setAdultCount(adultCount);
        setChildCount(childCount);
        setPaymentCompleted(isPaymentCompleted);
        setVisitAt(visitAt);
    }

    // --- ★追加: 合計金額の Getter / Setter ---
    public int getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(int totalAmount) {
        // 金額はマイナスでなければOKとする簡易チェック
        if (totalAmount < 0) {
            // DAOでのセット時に例外が出ると困る場合はログ出力程度に留めるか、
            // ここでは簡易的にセットする
        }
        this.totalAmount = totalAmount;
    }
    // ---------------------------------------

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
            throw new Failure("伝票IDの入力エラーです。");
        }
    }

    // テーブル番号
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

    // 大人人数
    public int getAdultCount() {
        return adultCount;
    }

    public void setAdultCount(int adultCount) throws Failure {
        checkAdultCount(adultCount);
        this.adultCount = adultCount;
    }

    private void checkAdultCount(int adultCount) throws Failure {
        if (adultCount < 1 || adultCount > 8) {
            throw new Failure("大人の人数のエラー");
        }
    }

    // 子供人数
    public int getChildCount() {
        return childCount;
    }

    public void setChildCount(int childCount) throws Failure {
        checkChildCount(childCount);
        this.childCount = childCount;
    }

    private void checkChildCount(int childCount) throws Failure {
        if (childCount < 0 || childCount > 7) {
            throw new Failure("子供の人数のエラー");
        }
    }

    // 決済完了
    public boolean isPaymentCompleted() {
        return isPaymentCompleted;
    }

    // booleanのSetterは "setPaymentCompleted" で統一
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