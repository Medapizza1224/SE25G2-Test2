package control.order;

import dao.AdminDao;
import entity.Admin;

public class TableInitControl {

    public TableInitResult execute(String adminName, String password) {
        // 1. 入力チェック
        if (adminName == null || adminName.isEmpty() || password == null || password.isEmpty()) {
            return new TableInitResult("管理者名かパスワードが違います");
        }

        try {
            // 2. DAOを使ってDB照合
            AdminDao dao = new AdminDao();
            Admin admin = dao.findByLogin(adminName, password);

            // 3. 認証判定
            if (admin == null) {
                return new TableInitResult("管理者名かパスワードが違います");
            }

            // 認証成功
            return new TableInitResult();

        } catch (Exception e) {
            e.printStackTrace();
            return new TableInitResult("システムエラーが発生しました");
        }
    }
}