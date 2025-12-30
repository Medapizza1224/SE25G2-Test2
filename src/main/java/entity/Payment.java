package entity;

import java.sql.Timestamp;
import modelUtil.Failure;
import java.util.UUID;

// クラスの定義
public class Payment {

    // フィールド
    private UUID orderId;
    private UUID userId;
    private int usedPoints;
    private int earnedPoints;
    private Timestamp paymentCompletedAt;

    // コンストラクタ
    public Payment(UUID orderId, UUID userId, int usedPoints, int earnedPoints, Timestamp paymentCompletedAt) throws Failure {
        setOrderId(orderId);
        setUserId(userId);
        setUsedPoints(usedPoints);
        setEarnedPoints(earnedPoints);
        setPaymentCompletedAt(paymentCompletedAt);
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

    // ユーザーID
    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) throws Failure {
        checkUserId(userId);
        this.userId = userId;
    }

    private void checkUserId(UUID userId) throws Failure {
        if (userId == null) {
            throw new Failure("ユーザーIDが正しくありません。");
        }
    }

    // 利用ポイント
    public int getUsedPoints() {
        return usedPoints;
    }

    public void setUsedPoints(int usedPoints) throws Failure {
        checkUsedPoints(usedPoints);
        this.usedPoints = usedPoints;
    }

    private void checkUsedPoints(int usedPoints) throws Failure {
        if (usedPoints < 0) {
            throw new Failure("利用ポイントは0以上に設定してください。");
        }
    }

    // 付与ポイント
    public int getEarnedPoints() {
        return earnedPoints;
    }

    public void setEarnedPoints(int earnedPoints) throws Failure {
        checkEarnedPoints(earnedPoints);
        this.earnedPoints = earnedPoints;
    }

    private void checkEarnedPoints(int earnedPoints) throws Failure {
        if (earnedPoints < 0) {
            throw new Failure("付与ポイントが不正です。");
        }
    }

    // 決済日時
    public Timestamp getPaymentCompletedAt() {
        return paymentCompletedAt;
    }

    public void setPaymentCompletedAt(Timestamp paymentCompletedAt) throws Failure {
        checkPaymentCompletedAt(paymentCompletedAt);
        this.paymentCompletedAt = paymentCompletedAt;
    }

    private void checkPaymentCompletedAt(Timestamp paymentCompletedAt) throws Failure {
        if (paymentCompletedAt == null) {
            throw new Failure("決済日時が不正です。");
        }
    }
}