package entity;

import modelUtil.Failure;

// クラスの定義
public class Admins {

    // フィールド ＝ データ一覧
    private String adminName;
    private String adminPassword;

    // コンストラクタ ＝ 初期値
    public Admins (String adminName, String adminPassword) throws Failure {
        setAdminName(adminName);
        setAdminPassword(adminPassword);
    }
    // throws Failure：エラーの場合、それぞれのFailureで処理が行われる
    // 今回は、固定値との比較なので、チェックは省略（コントロールでチェック）
    
    // 管理者名
    // データの取り出し（外のファイルから）
    public String getAdminName() {
        return adminName;
    }

    // データの書き換え（外のファイルから）
    public void setAdminName(String adminName) throws Failure {
        this.adminName = adminName;
    }

    // 管理者パスワード
    public String getAdminPassword() {
        return adminPassword;
    }

    public void setAdminPassword(String adminPassword) throws Failure {
        this.adminPassword = adminPassword;
    }

}