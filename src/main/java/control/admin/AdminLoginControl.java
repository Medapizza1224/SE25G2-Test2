package control.admin;

import dao.AdminDao;
import entity.Admin;
import modelUtil.Failure;

public class AdminLoginControl {

    public AdminLoginResult execute(String adminName, String password) throws Exception {
        // 1. 簡易入力チェック
        if (adminName == null || adminName.isEmpty()) {
            throw new Failure("管理者名を入力してください");
        }
        if (password == null || password.isEmpty()) {
            throw new Failure("パスワードを入力してください");
        }

        // 2. DAOを使ってDB照合
        AdminDao dao = new AdminDao();
        Admin admin = dao.findByLogin(adminName, password);

        // 3. 認証判定
        if (admin == null) {
            throw new Failure("管理者名またはパスワードが間違っています");
        }

        return new AdminLoginResult(admin);
    }
}