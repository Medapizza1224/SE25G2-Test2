package control.order;

import modelUtil.Failure;

public class TableInitControl {
    // 簡易認証（本来はDB照合）
    private static final String ADMIN_USER = "admin";
    private static final String ADMIN_PASS = "1234";

    public void execute(String user, String pass, String tableNumber) throws Failure {
        if (!ADMIN_USER.equals(user) || !ADMIN_PASS.equals(pass)) {
            throw new Failure("管理者名かパスワードが一致しません");
        }
        if (tableNumber == null || !tableNumber.matches("\\d{4}")) {
            throw new Failure("テーブル番号は4桁の数字で入力してください (例: 0001)");
        }
    }
}