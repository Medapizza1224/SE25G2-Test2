package control.user;

import java.util.UUID;
import dao.DaoException;
import dao.UserDao;
import modelUtil.Failure;

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

        // 2. 決済実行（Daoのセキュリティロジックへ委譲）
        try {
            UserDao dao = new UserDao();
            // ここで多数決＆改ざんチェック付きの決済が走る
            int newBalance = dao.userPayment(userId, orderId, amount, securityCode);
            
            // ポイント計算（表示用）
            int earnedPoints = (int)(amount * 0.01);
            
            return new UserPaymentResult(amount, earnedPoints, newBalance);

        } catch (DaoException e) {
            // セキュリティエラー含むDaoからのメッセージを表示
            throw new Failure(e.getMessage(), e);
        } catch (Exception e) {
            e.printStackTrace();
            throw new Failure("システムエラーが発生しました", e);
        }
    }
}