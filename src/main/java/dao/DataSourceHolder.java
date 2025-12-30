package dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DataSourceHolder {
    
    private static List<DataSource> _dataSources = new ArrayList<>();
    
    // Docker Compose上のサービス名
    private static final String[] DB_NODES = { "db1", "db2", "db3" };

    static {
        if (_dataSources.isEmpty()) {
            try {
                // プロパティファイルのパス取得
                String propsPath = null;
                try {
                    propsPath = DataSourceHolder.class.getClassLoader()
                        .getResource("dataSource.properties").getPath();
                } catch (Exception ignore) {
                    // ファイルが見つからなくても続行
                }

                for (String node : DB_NODES) {
                    HikariConfig config;
                    if (propsPath != null) {
                        config = new HikariConfig(propsPath);
                    } else {
                        config = new HikariConfig();
                    }

                    // ★ユーザーとパスワードを強制的に指定
                    config.setUsername("root");
                    config.setPassword("root");
                    
                    // ドライバクラスも明示
                    config.setDriverClassName("com.mysql.cj.jdbc.Driver");

                    // URLの設定 (Docker内の各ノードに向ける)
                    String url = "jdbc:mysql://" + node + ":3306/restaurant_db?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
                    config.setJdbcUrl(url);
                    config.setPoolName("HikariPool-" + node);

                    _dataSources.add(new HikariDataSource(config));
                }
            } catch (Exception e) {
                e.printStackTrace();
                throw new RuntimeException("DB接続プールの初期化に失敗しました: " + e.getMessage(), e);
            }
        }
    }

    // --- ここを追加しました ---
    /**
     * デフォルトの接続（Node1）を取得する
     * LedgerMonitorなどがこのメソッド名で呼び出しているため追加
     */
    public Connection getConnection() throws SQLException {
        return getNode1Connection();
    }
    // -------------------------

    // 読み込み用 (Node1)
    public Connection getNode1Connection() throws SQLException {
        if (_dataSources.isEmpty()) throw new SQLException("DataSourceが初期化されていません");
        return _dataSources.get(0).getConnection();
    }

    // 書き込み用 (全ノード)
    public List<Connection> getAllConnections() throws SQLException {
        List<Connection> connections = new ArrayList<>();
        try {
            if (_dataSources.isEmpty()) throw new SQLException("DataSourceが初期化されていません");
            
            for (DataSource ds : _dataSources) {
                connections.add(ds.getConnection());
            }
        } catch (SQLException e) {
            // エラー時は開いた接続をすべて閉じる
            for (Connection c : connections) {
                try { c.close(); } catch (Exception ignore) {}
            }
            throw e;
        }
        return connections;
    }
}