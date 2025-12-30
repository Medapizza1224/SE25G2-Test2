package control.user;

public class UserPaymentResult {
    private int paidAmount;
    private int earnedPoints; // 獲得ポイント（表示用）
    private int currentBalance; // 決済後残高（表示用）

    public UserPaymentResult(int paidAmount, int earnedPoints, int currentBalance) {
        this.paidAmount = paidAmount;
        this.earnedPoints = earnedPoints;
        this.currentBalance = currentBalance;
    }

    public int getPaidAmount() {
        return paidAmount;
    }

    public int getEarnedPoints() {
        return earnedPoints;
    }

    public int getCurrentBalance() {
        return currentBalance;
    }
}