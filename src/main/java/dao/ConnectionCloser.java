package dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * {@link java.sql.Connection#close()}を抽象化する。
 * 他のパッケージからも利用できるように public を付与
 */
public class ConnectionCloser { // ← ここに public を追加
    /**
     * 単一の接続を閉じる（既存メソッド）
     */
    public void closeConnection(Connection connection) throws DaoException {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException sqlException) {
                throw new DaoException("データベース切断時にエラーが発生しました。", sqlException);
            }
        }
    }

    /**
     * 【追加】複数の接続をまとめて閉じる
     * 分散書き込み処理の finally ブロックで使用する。
     */
    public void closeConnections(List<Connection> connections) {
        if (connections == null) return;
        
        // 1つ閉じるのに失敗しても、残りを閉じようとする実装
        SQLException firstException = null;

        for (Connection conn : connections) {
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                if (firstException == null) {
                    firstException = e;
                }
            }
        }
        
        // エラーログを出力（今回はコンソールに出力して処理続行）
        if (firstException != null) {
            System.err.println("一部のDB接続切断に失敗しました: " + firstException.getMessage());
        }
    }
}