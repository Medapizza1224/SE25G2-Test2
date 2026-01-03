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
            // ★ここを修正
            con = dataSourceHolder.getConnection();

            String sql = "SELECT * FROM products ORDER BY product_id";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                try {
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
                    System.err.println("不正データをスキップ: " + e.getMessage());
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