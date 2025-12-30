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
                // プロパティファイルのパス取得（ファイルが存在しなくてもコード設定で動くようにします）
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

                    // ★ここに追記：ユーザーとパスワードを強制的に指定★
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
                e.printStackTrace(); // エラーログをコンソールに出す
                throw new RuntimeException("DB接続プールの初期化に失敗しました: " + e.getMessage(), e);
            }
        }
    }

    // 読み込み用 (Node1)
    public Connection getNode1Connection() throws SQLException {
        return _dataSources.get(0).getConnection();
    }

    // 書き込み用 (全ノード)
    public List<Connection> getAllConnections() throws SQLException {
        List<Connection> connections = new ArrayList<>();
        try {
            for (DataSource ds : _dataSources) {
                connections.add(ds.getConnection());
            }
        } catch (SQLException e) {
            for (Connection c : connections) {
                try { c.close(); } catch (Exception ignore) {}
            }
            throw e;
        }
        return connections;
    }
}