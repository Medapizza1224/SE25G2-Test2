package entity;

import modelUtil.Failure;
import java.util.UUID;

// クラスの定義
public class User {

    // フィールド
    private UUID userId;
    private String userName;
    private String userPassword;
    private String securityCode;
    private int balance;
    private int point;
    private int loginAttemptCount;
    private boolean isLockout;

    // コンストラクタ
    public User(UUID userId, String userName, String userPassword, String securityCode,  int balance, int point, int loginAttemptCount, boolean isLockout) throws Failure {
        setUserId(userId);
        setUserName(userName);
        setUserPassword(userPassword);
        setSecurityCode(securityCode);
        setBalance(balance);
        setPoint(point);
        setLoginAttemptCount(loginAttemptCount);
        setLockout(isLockout);
    }

    // ユーザーID
    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) throws Failure {
        checkUserId(userId);
        this.userId = userId;
    }

    private void checkUserId(UUID userId) throws Failure {
        if (userId == null) {
            throw new Failure("ユーザーIDがエラーです。");
        }
    }

    // ユーザー名 (8〜32文字)
    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) throws Failure {
        checkUserName(userName);
        this.userName = userName;
    }

    private void checkUserName(String userName) throws Failure {
        if (userName == null || userName.length() < 8 || userName.length() > 32) {
            throw new Failure("半角8~32文字以内かつ、英数小文字・数字・記号のうち2種類以上を使ってください。");
        }
    }

    // パスワード (ハッシュ化済みを想定)
    public String getUserPassword() {
        return userPassword;
    }

    public void setUserPassword(String userPassword) throws Failure {
        checkUserPassword(userPassword);
        this.userPassword = userPassword;
    }

    private void checkUserPassword(String userPassword) throws Failure {
        if (userPassword == null || userPassword.isEmpty()) {
            throw new Failure("半角8~32文字以内かつ、英数小文字・数字・記号のうち2種類以上を使ってください。");
        }
    }

    // セキュリティコード (4桁数字のハッシュ済みを想定)
    public String getSecurityCode() {
        return securityCode;
    }

    public void setSecurityCode(String securityCode) throws Failure {
        checkSecurityCode(securityCode);
        this.securityCode = securityCode;
    }

    private void checkSecurityCode(String securityCode) throws Failure {
        if (securityCode == null || securityCode.isEmpty()) {
            throw new Failure("半角8~32文字以内かつ、英数小文字・数字・記号のうち2種類以上を使ってください。");
        }
    }

    // 残高 (0円〜500,000円)
    public int getBalance() {
        return balance;
    }

    public void setBalance(int balance) throws Failure {
        checkBalance(balance);
        this.balance = balance;
    }

    private void checkBalance(int balance) throws Failure {
        if (balance < 0 || balance > 500000) {
            throw new Failure("チャージ上限（500,000円）を超えます。");
        }
    }

    // ポイント数
    public int getPoint() {
        return point;
    }

    public void setPoint(int point) throws Failure {
        checkPoint(point);
        this.point = point;
    }

    private void checkPoint(int point) throws Failure {
        if (point < 0) {
            throw new Failure("ポイント数がエラーです。");
        }
    }

    // 試行回数
    public int getLoginAttemptCount() {
        return loginAttemptCount;
    }

    public void setLoginAttemptCount(int loginAttemptCount) throws Failure {
        checkLoginAttemptCount(loginAttemptCount);
        this.loginAttemptCount = loginAttemptCount;
    }

    private void checkLoginAttemptCount(int loginAttemptCount) throws Failure {
        if (loginAttemptCount < 0) {
            throw new Failure("試行回数がエラーです。");
        }
    }

    // ユーザーロックアウト
    public boolean isLockout() {
        return isLockout;
    }

    public void setLockout(boolean isLockout) {
        this.isLockout = isLockout;
    }
}