package control.admin;

import dao.AdminDao;
import entity.Admin;
import modelUtil.Failure;

public class AdminLoginControl {

    public AdminLoginResult execute(String adminName, String password) throws Exception {
        // 入力チェック
        if (adminName == null || adminName.isEmpty() || password == null || password.isEmpty()) {
            throw new Failure("管理者名かパスワードが違います"); // 曖昧にしてセキュリティ向上
        }

        AdminDao dao = new AdminDao();
        Admin admin = dao.findByLogin(adminName, password);

        if (admin == null) {
            // ★ 指定のエラーメッセージに変更
            throw new Failure("管理者名かパスワードが違います");
        }

        return new AdminLoginResult(admin);
    }
}