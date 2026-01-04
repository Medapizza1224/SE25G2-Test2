package control.order;

import dao.AdminDao;
import entity.Admin;
import modelUtil.Failure;

public class TableInitControl {

    public void execute(String user, String pass, String tableNumber) throws Exception {
        
        // 1. テーブル番号の形式チェック (4桁の数字)
        if (tableNumber == null || !tableNumber.matches("\\d{4}")) {
            throw new Failure("テーブル番号は4桁の数字で入力してください (例: 0001)");
        }

        // 2. 入力チェック
        if (user == null || user.isEmpty() || pass == null || pass.isEmpty()) {
            throw new Failure("管理者名とパスワードを入力してください");
        }

        // 3. DAOを使ってDB照合 (既存のAdminDaoを再利用)
        AdminDao dao = new AdminDao();
        Admin admin = dao.findByLogin(user, pass);

        // 4. 認証判定
        if (admin == null) {
            throw new Failure("管理者名またはパスワードが一致しません");
        }

        // ここまでエラーがなければ認証OK & テーブル番号形式OK
    }
}