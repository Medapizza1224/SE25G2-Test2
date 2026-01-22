package control.user;

import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class UserLogin {

    public UserLoginResult execute(String userName, String password) throws Failure {
        try {
            UserDao dao = new UserDao();
            User user = dao.findByName(userName);

            // ユーザーが存在しない場合
            if (user == null) {
                // セキュリティ上、存在しない場合も「違います」で統一するのが一般的ですが
                // 今回はシンプルにエラーを出します
                throw new Failure("ユーザー名かパスワードが違います");
            }
            
            // 既にロックされている場合
            if (user.isLockout()) {
                throw new Failure("アカウントがロックされています。管理者に連絡してください。");
            }

            // パスワードチェック
            // (本来はDBのハッシュ値と比較すべきですが、サンプルに合わせて平文比較またはハッシュ比較を行います)
            // ここではDBの値が平文かハッシュかによりますが、とりあえず equals で比較します
            if (!user.getUserPassword().equals(password)) {
                
                // ★失敗時のカウントアップ処理
                int newCount = dao.incrementLoginAttempt(user.getUserId());
                int remaining = 3 - newCount;
                
                if (remaining <= 0) {
                    throw new Failure("アカウントがロックされました。管理者に連絡してください。");
                } else {
                    throw new Failure("パスワードが違います。\nあと" + remaining + "回失敗するとロックされます。");
                }
            }

            // ★成功時のリセット処理
            dao.resetLoginAttempt(user.getUserId());

            return new UserLoginResult(user);

        } catch (Failure e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new Failure("システムエラーが発生しました");
        }
    }
}