package dao;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.net.URL;

public class DataSourceHolder { // publicを追加
    private static HikariConfig _hikariConfig;
    private static DataSource _dataSource;

    public final DataSource dataSource;

    public DataSourceHolder() {
        if (DataSourceHolder._hikariConfig == null) {
            // クラスパスから設定ファイルを取得
            URL resource = this.getClass().getClassLoader().getResource("dataSource.properties");
            if (resource == null) {
                throw new RuntimeException("dataSource.propertiesが見つかりません。");
            }
            DataSourceHolder._hikariConfig = new HikariConfig(resource.getPath());
        }

        if (DataSourceHolder._dataSource == null) {
            DataSourceHolder._dataSource = new HikariDataSource(DataSourceHolder._hikariConfig);
        }

        this.dataSource = DataSourceHolder._dataSource;
    }
}