package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import entity.Product;
import modelUtil.Failure;

public class ProductDao {
    private final DataSourceHolder dataSourceHolder;
    private final ConnectionCloser connectionCloser;

    public ProductDao() {
        this.dataSourceHolder = new DataSourceHolder();
        this.connectionCloser = new ConnectionCloser();
    }

    public List<Product> viewProductAll() throws DaoException {
        List<Product> list = new ArrayList<>();
        Connection con = null;

        try {
            // 読み込みなので Node1 (db1) だけに接続
            con = dataSourceHolder.getNode1Connection();

            String sql = "SELECT * FROM products ORDER BY product_id";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                try {
                    // ここでEntity生成（チェック処理が走る）
                    Product p = new Product(
                        rs.getString("product_id"),
                        rs.getString("image"),
                        rs.getString("product_name"),
                        rs.getString("category"),
                        rs.getInt("price"),
                        rs.getString("sales_status"),
                        rs.getTimestamp("update_at")
                    );
                    list.add(p);
                    
                } catch (Failure e) {
                    // DBデータがEntityのバリデーションに違反していた場合
                    // 画面全体をエラーにせず、その行だけスキップしてログを出す
                    System.err.println("不正データをスキップ: ID=" + rs.getString("product_id") + " 理由=" + e.getMessage());
                }
            }
        } catch (SQLException e) {
            throw new DaoException("商品データ取得中にDBエラーが発生しました", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }
}