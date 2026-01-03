package dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import java.io.InputStream;
import javax.sql.DataSource;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * DB接続を提供するクラス
 */
public class DataSourceHolder {
    private static HikariConfig _hikariConfig;
    private static DataSource _dataSource;

    // staticイニシャライザで1回だけ設定を読み込む
    static {
        try {
            // プロパティオブジェクトを作成
            Properties props = new Properties();
            
            // クラスパスからファイルをストリームとして読み込む (安全な方法)
            try (InputStream is = DataSourceHolder.class.getClassLoader().getResourceAsStream("dataSource.properties")) {
                if (is == null) {
                    throw new RuntimeException("dataSource.properties が見つかりません。src/main/resources フォルダに配置されているか確認してください。");
                }
                props.load(is);
            }

            // プロパティを使ってHikariConfigを初期化
            _hikariConfig = new HikariConfig(props);
            _dataSource = new HikariDataSource(_hikariConfig);

        } catch (Exception e) {
            // エラーログをコンソールに出力
            e.printStackTrace();
            throw new RuntimeException("DB接続設定の読み込みに失敗しました: " + e.getMessage(), e);
        }
    }

    /**
     * コネクションを取得する
     */
    public Connection getConnection() throws SQLException {
        return _dataSource.getConnection();
    }
}