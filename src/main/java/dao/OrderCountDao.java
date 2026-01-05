package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.AnalysisDto;

public class OrderCountDao {

    // ★修正1: フィールド変数の追加
    private final DataSourceHolder dataSourceHolder;
    private final ConnectionCloser connectionCloser;

    // ★修正2: コンストラクタでの初期化
    public OrderCountDao() {
        this.dataSourceHolder = new DataSourceHolder();
        this.connectionCloser = new ConnectionCloser();
    }
    
    // コントロール側でトランザクション中のConnectionを受け取る設計
    public void incrementCount(Connection con, String productId, String customerType, int quantity) throws SQLException {
        // カラム名を判定
        String column = "";
        switch (customerType) {
            case "Single":
                column = "order_count_from_single_adult";
                break;
            case "Pair":
                column = "order_count_from_two_adults";
                break;
            case "Family":
                column = "order_count_from_family_group";
                break;
            case "AdultGroup":
                column = "order_count_from_adult_group";
                break;
            default:
                column = "order_count_from_group";
                break;
        }

        // SQL構築 (SQLインジェクション対策のため、カラム名はホワイトリスト方式でswitchで分岐させています)
        String sql = "UPDATE order_counts SET " + column + " = " + column + " + ? WHERE product_id = ?";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setString(2, productId);
            
            int updated = ps.executeUpdate();
            
            // もしレコードが存在しなかった場合（新商品など）、新規作成するロジックが必要ならここに追加
            if (updated == 0) {
                createInitialRecord(con, productId, column, quantity);
            }
        }
    }

    // 指定された客層カラムでランキングを取得 (TOP5)
    public List<AnalysisDto> getRanking(String column) throws DaoException {
        List<AnalysisDto> list = new ArrayList<>();
        Connection con = null;
        try {
            con = dataSourceHolder.getConnection();
            
            // ★修正1: SQL文に p.image を追加
            String sql = "SELECT p.product_name, p.image, c." + column + " as cnt " +
                         "FROM order_counts c " +
                         "JOIN products p ON c.product_id = p.product_id " +
                         "ORDER BY cnt DESC LIMIT 5";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while(rs.next()){
                // ★修正2: DTOのコンストラクタに image を渡す
                list.add(new AnalysisDto(
                    rs.getString("product_name"), 
                    rs.getInt("cnt"),
                    rs.getString("image") // ここを追加
                ));
            }
        } catch(Exception e) {
            throw new DaoException("分析データ取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }

    // レコードがない場合の初期作成用
    private void createInitialRecord(Connection con, String productId, String column, int quantity) throws SQLException {
        String sql = "INSERT INTO order_counts (product_id, " + column + ") VALUES (?, ?)";
        // 他のカラムはデフォルト0が入る前提
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, productId);
            ps.setInt(2, quantity);
            ps.executeUpdate();
        }
    }
}