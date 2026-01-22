package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dto.AnalysisDto;

public class AnalysisDao {
    private final DataSourceHolder dbHolder;
    private final ConnectionCloser connectionCloser;

    public AnalysisDao() {
        this.dbHolder = new DataSourceHolder();
        this.connectionCloser = new ConnectionCloser();
    }

    /**
     * 日次メンテナンス
     * 1. 7日以上前のデータを削除
     * 2. 今日のデータがなければ、全商品分作成 (INSERT IGNORE / NOT EXISTS)
     */
    public void maintainDailyRecords(Connection con) throws SQLException {
        // 1. 古いデータを削除 (7日より前)
        String delSql = "DELETE FROM analysis WHERE analysis_date < DATE_SUB(CURRENT_DATE, INTERVAL 6 DAY)";
        try(PreparedStatement ps = con.prepareStatement(delSql)) {
            ps.executeUpdate();
        }

        // 2. 今日のレコード作成 (存在しない商品のみ)
        // analysis_date, product_id が主キーなので重複エラー無視でも良いが、
        // ここではまだ無いものだけを入れる
        String insSql = "INSERT IGNORE INTO analysis (analysis_date, product_id) " +
                        "SELECT CURRENT_DATE, product_id FROM products";
        try(PreparedStatement ps = con.prepareStatement(insSql)) {
            ps.executeUpdate();
        }
    }

    /**
     * 注文数をインクリメント (注文確定時に呼ぶ)
     */
    public void incrementCount(Connection con, String productId, String customerType, int quantity) throws SQLException {
        // まず日次レコードがあるか保証する
        maintainDailyRecords(con);

        String column = "";
        switch (customerType) {
            case "Single": column = "count_single"; break;
            case "Pair": column = "count_pair"; break;
            case "Family": column = "count_family"; break;
            case "AdultGroup": column = "count_adult_group"; break;
            default: column = "count_group"; break;
        }

        String sql = "UPDATE analysis SET " + column + " = " + column + " + ? " +
                     "WHERE analysis_date = CURRENT_DATE AND product_id = ?";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setString(2, productId);
            ps.executeUpdate();
        }
    }

    /**
     * ランキング取得 (直近7日間の合計)
     */
    public List<AnalysisDto> getRanking(String customerType) throws Exception {
        List<AnalysisDto> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dbHolder.getConnection();
            
            // メンテナンス（表示のタイミングで更新しておく）
            maintainDailyRecords(con);

            String column = "";
            switch (customerType) {
                case "Single": column = "count_single"; break;
                case "Pair": column = "count_pair"; break;
                case "Family": column = "count_family"; break;
                case "AdultGroup": column = "count_adult_group"; break;
                default: column = "count_group"; break;
            }

            // 商品ごとに過去7日分をSUMしてTOP5
            String sql = "SELECT p.product_name, p.image, SUM(a." + column + ") as total " +
                         "FROM analysis a " +
                         "JOIN products p ON a.product_id = p.product_id " +
                         "WHERE a.analysis_date BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 6 DAY) AND CURRENT_DATE " +
                         "GROUP BY p.product_id, p.product_name, p.image " +
                         "ORDER BY total DESC LIMIT 5";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while(rs.next()){
                list.add(new AnalysisDto(
                    rs.getString("product_name"), 
                    rs.getInt("total"),
                    rs.getString("image")
                ));
            }
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }
}