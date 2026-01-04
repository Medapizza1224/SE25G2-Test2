package dao;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * {@link java.sql.Connection#close()}を抽象化する。
 */
public class ConnectionCloser {
    
    /**
     * {@link java.sql.Connection#close()}を抽象化する。
     * 引数の{@link java.sql.Connection}型のオブジェクトに対して{@code close}メソッドを呼び出す。
     * <p>
     * エラーが発生した場合はスタックトレースを出力し、例外はスローしない。
     * これにより、finallyブロック内での例外処理を簡潔にする。
     * </p>
     */
    // ★修正点1: throws DaoException を削除
    public void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException sqlException) {
                // ★修正点2: 例外を投げずにログ出力(または標準エラーストリーム)にとどめる
                // close時のエラーはアプリケーションの動作に致命的でないことが多いため、
                // 元の処理の例外を上書きしないようにここで握りつぶすのが一般的です。
                sqlException.printStackTrace();
            }
        }
    }
}