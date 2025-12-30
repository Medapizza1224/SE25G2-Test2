package dao;

public class DaoException extends Exception {
    // メッセージのみのコンストラクタを追加
    public DaoException(String message) {
        super(message);
    }

    public DaoException(String message, Throwable cause) {
        super(message, cause);
    }
}