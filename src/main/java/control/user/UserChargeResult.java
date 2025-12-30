package control.user;

public class UserChargeResult {
    private int chargedAmount; // 今回チャージした額
    private int newBalance;    // チャージ後の残高

    public UserChargeResult(int chargedAmount, int newBalance) {
        this.chargedAmount = chargedAmount;
        this.newBalance = newBalance;
    }

    public int getChargedAmount() {
        return chargedAmount;
    }

    public int getNewBalance() {
        return newBalance;
    }
}