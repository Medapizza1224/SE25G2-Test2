package dao;

public class DaoException extends Exception {

    // ★このコンストラクタが足りていないためエラーになっています
    public DaoException(String message) {
        super(message);
    }

    // 元々あったコンストラクタ
    public DaoException(String message, Throwable cause) {
        super(message, cause);
    }
}