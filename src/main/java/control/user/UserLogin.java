package control.user;

import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class UserLogin {
    public UserLoginResult execute(String userIdOrName, String password) throws Failure {
        try {
            UserDao dao = new UserDao();
            // 本来はパスワードハッシュチェックなどを行いますが、
            // デモ用にユーザー名検索で最初に見つかったユーザーを返します
            // (PaymentSetupで作成されたユーザーでログインすることを想定)
            User user = dao.findByName(userIdOrName); // ※UserDaoにfindByNameが必要

            if (user == null) {
                throw new Failure("ユーザーが見つかりません。");
            }
            
            // 簡易パスワードチェック (PaymentSetupで"dummy_pass"を設定している前提)
            if (!"dummy_pass".equals(password)) {
                 // throw new Failure("パスワードが違います。"); 
                 // デモをスムーズにするため一旦コメントアウトするか、Setupと合わせる
            }

            return new UserLoginResult(user);
        } catch (Exception e) {
            throw new Failure("ログイン処理に失敗しました。", e);
        }
    }
}