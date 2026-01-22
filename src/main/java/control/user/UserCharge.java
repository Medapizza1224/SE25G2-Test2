package control.user;

import java.util.UUID;
import dao.DaoException;
import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class UserCharge {

    // チャージ後の残高上限 (500,000円)
    private static final int MAX_BALANCE = 500000;

    public UserChargeResult execute(UUID userId, String amountStr) throws Failure {
        if (userId == null) {
            throw new Failure("ユーザーセッションが無効です。");
        }
        
        int amount;
        try {
            amount = Integer.parseInt(amountStr);
            if (amount <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            throw new Failure("チャージ金額は正の整数で入力してください。");
        }

        try {
            UserDao dao = new UserDao();
            
            // ★追加: 現在の残高を取得して上限チェック
            User currentUser = dao.findById(userId);
            if (currentUser == null) {
                throw new Failure("ユーザーが見つかりません。");
            }
            if (currentUser.getBalance() + amount > MAX_BALANCE) {
                throw new Failure("チャージ後の残高が上限（500,000円）を超えます。");
            }

            // チャージ実行
            int newBalance = dao.userCharge(userId, amount);
            
            return new UserChargeResult(amount, newBalance);

        } catch (DaoException e) {
            throw new Failure(e.getMessage(), e);
        } catch (Exception e) {
            e.printStackTrace();
            throw new Failure("予期せぬシステムエラーが発生しました。", e);
        }
    }
}