package control.user;

import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class UserLogin {

    public UserLoginResult execute(String userName, String password) throws Failure {
        try {
            UserDao dao = new UserDao();
            User user = dao.findByName(userName);

            // ユーザーが存在しない、またはパスワードが一致しない場合
            if (user == null || !user.getUserPassword().equals(password)) {
                // ★ 指定のエラーメッセージに変更
                throw new Failure("ユーザー名かパスワードが違います");
            }
            
            if (user.isLockout()) {
                throw new Failure("アカウントがロックされています");
            }

            return new UserLoginResult(user);

        } catch (Failure e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new Failure("システムエラーが発生しました");
        }
    }
}