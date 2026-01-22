package control.user;

import java.util.UUID;
import dao.DaoException;
import dao.UserDao;
import entity.User;
import modelUtil.Failure;
import servlet.system.PaymentSystem; // ハッシュ計算用

public class UserPayment {

    public UserPaymentResult execute(UUID userId, String orderIdStr, String amountStr, String securityCode) throws Failure {
        
        // 1. 基本チェック
        if (userId == null) throw new Failure("セッションが無効です");
        if (securityCode == null || securityCode.trim().isEmpty()) throw new Failure("セキュリティコードを入力してください");

        int amount;
        UUID orderId;
        try {
            amount = Integer.parseInt(amountStr);
            if (amount <= 0) throw new NumberFormatException();
            orderId = UUID.fromString(orderIdStr);
        } catch (IllegalArgumentException e) {
            throw new Failure("不正なパラメータです");
        }

        try {
            UserDao dao = new UserDao();
            
            // 2. ユーザー情報の最新を取得してチェック
            User user = dao.findById(userId);
            if (user == null) throw new Failure("ユーザーが見つかりません");
            
            // 既にロックされているか確認
            if (user.isLockout()) {
                throw new Failure("アカウントがロックされています。管理者に連絡してください。");
            }

            // 3. セキュリティコードの照合 (Hash化して比較)
            // 入力されたコードをハッシュ化
            String inputHash = PaymentSystem.calculateHash(securityCode);
            String dbHash = user.getSecurityCode();

            if (!inputHash.equals(dbHash)) {
                // ★失敗時のカウントアップ処理
                int newCount = dao.incrementLoginAttempt(userId);
                int remaining = 3 - newCount;
                
                if (remaining <= 0) {
                    throw new Failure("セキュリティコードの入力を3回間違えたため、\nアカウントがロックされました。");
                } else {
                    throw new Failure("セキュリティコードが違います。\nあと" + remaining + "回失敗するとロックされます。");
                }
            }

            // ★成功時のリセット処理
            dao.resetLoginAttempt(userId);

            // 4. 決済実行（Daoにはハッシュ化したコードを渡すことで、Dao内のチェックも通過させる）
            int newBalance = dao.userPayment(userId, orderId, amount, inputHash);
            
            // ポイント計算（表示用）
            int earnedPoints = (int)(amount * 0.01); // 1%
            
            return new UserPaymentResult(amount, earnedPoints, newBalance);

        } catch (DaoException e) {
            throw new Failure(e.getMessage(), e);
        } catch (Failure e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new Failure("システムエラーが発生しました", e);
        }
    }
}