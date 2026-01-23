package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import entity.Product;
import modelUtil.Failure;

public class ProductDao {
    private final javax.sql.DataSource dataSource; // 変更
    private final ConnectionCloser connectionCloser;

    public ProductDao() {
        this.dataSource = new DataSourceHolder().dataSource; // 変更
        this.connectionCloser = new ConnectionCloser();
    }

    // 全商品取得 (管理者一覧用)
    public List<Product> viewProductAll() throws DaoException {
        List<Product> list = new ArrayList<>();
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "SELECT * FROM products ORDER BY product_id";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapToEntity(rs));
            }
        } catch (Exception e) {
            throw new DaoException("商品一覧取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }

    // IDで取得 (編集フォーム用)
    public Product findById(String id) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "SELECT * FROM products WHERE product_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapToEntity(rs);
            }
            return null;
        } catch (Exception e) {
            throw new DaoException("商品取得エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    // 新規登録
    public void insert(Product p) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "INSERT INTO products (product_id, product_name, category, price, image, sales_status, update_at) VALUES (?, ?, ?, ?, ?, ?, NOW())";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, p.getProductId());
            ps.setString(2, p.getProductName());
            ps.setString(3, p.getCategory());
            ps.setInt(4, p.getPrice());
            ps.setString(5, p.getImage());
            ps.setString(6, p.getSalesStatus());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new DaoException("商品登録エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    // 更新
    public void update(Product p) throws DaoException {
        Connection con = null;
        try {
            con = this.dataSource.getConnection();
            String sql = "UPDATE products SET product_name=?, category=?, price=?, image=?, sales_status=?, update_at=NOW() WHERE product_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, p.getProductName());
            ps.setString(2, p.getCategory());
            ps.setInt(3, p.getPrice());
            ps.setString(4, p.getImage());
            ps.setString(5, p.getSalesStatus());
            ps.setString(6, p.getProductId());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new DaoException("商品更新エラー", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
    }

    /**
     * カテゴリを指定して、販売中の商品リストを取得する
     * （メニュー画面で使用）
     */
    public List<Product> findByCategory(String category) throws DaoException {
        List<Product> list = new ArrayList<>();
        Connection con = null;

        try {
            con = this.dataSource.getConnection();
            // ユーザー画面用なので、sales_status が '販売中' のものだけに絞り込むのが一般的です
            String sql = "SELECT * FROM products WHERE category = ? AND sales_status = '販売中' ORDER BY product_id";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                try {
                    list.add(mapToEntity(rs));
                } catch (Failure e) {
                    System.err.println("不正な商品データをスキップしました(ID: " + rs.getString("product_id") + "): " + e.getMessage());
                }
            }
        } catch (Exception e) {
            throw new DaoException("カテゴリ検索中にエラーが発生しました", e);
        } finally {
            connectionCloser.closeConnection(con);
        }
        return list;
    }

    /**
     * ResultSetからProductオブジェクトへのマッピングを行う共通メソッド
     */
    private Product mapToEntity(ResultSet rs) throws SQLException, Failure {
        return new Product(
            rs.getString("product_id"),
            rs.getString("image"),
            rs.getString("product_name"),
            rs.getString("category"),
            rs.getInt("price"),
            rs.getString("sales_status"),
            rs.getTimestamp("update_at")
        );
    }
}