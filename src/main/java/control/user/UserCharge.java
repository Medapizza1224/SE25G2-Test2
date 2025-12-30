package control.user;

import java.util.UUID;
import dao.DaoException;
import dao.UserDao;
import modelUtil.Failure;

public class UserCharge {

    /**
     * チャージ処理を実行する
     */
    public UserChargeResult execute(UUID userId, String amountStr) throws Failure {
        
        // 1. 入力値検証
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

        // 2. チャージ実行 (DAO呼び出し)
        try {
            UserDao dao = new UserDao();
            // ブロックチェーン記録と残高更新を行い、新しい残高を受け取る
            int newBalance = dao.userCharge(userId, amount);
            
            return new UserChargeResult(amount, newBalance);

        } catch (DaoException e) {
            // DBエラーなどの業務例外
            throw new Failure(e.getMessage(), e);
        } catch (Exception e) {
            e.printStackTrace();
            throw new Failure("予期せぬシステムエラーが発生しました。", e);
        }
    }
}