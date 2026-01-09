package control.user;

import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class UserLogin {

    public UserLoginResult execute(String userName, String password) throws Failure {
        try {
            UserDao dao = new UserDao();
            User user = dao.findByName(userName);

            if (user == null) {
                throw new Failure("ユーザーが見つかりません。");
            }

            // ★修正: 単純な文字列比較に変更
            if (!user.getUserPassword().equals(password)) {
                throw new Failure("パスワードが違います。");
            }
            
            // ロックアウトチェック等は残す
            if (user.isLockout()) {
                throw new Failure("アカウントがロックされています。");
            }

            return new UserLoginResult(user);

        } catch (Failure e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new Failure("システムエラー", e);
        }
    }
}