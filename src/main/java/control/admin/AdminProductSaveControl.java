package control.admin;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import entity.Product;
import dao.ProductDao;

public class AdminProductSaveControl {

    public AdminProductSaveResult execute(HttpServletRequest request, String realPath) {
        try {
            String mode = request.getParameter("mode");
            
            // フォームデータの取得
            Product p = new Product();
            p.setProductId(request.getParameter("productId"));
            p.setProductName(request.getParameter("productName"));
            p.setCategory(request.getParameter("category"));
            
            String priceStr = request.getParameter("price");
            p.setPrice(priceStr != null && !priceStr.isEmpty() ? Integer.parseInt(priceStr) : 0);
            
            p.setSalesStatus(request.getParameter("salesStatus"));

            // --- 画像アップロード処理 ---
            Part filePart = request.getPart("imageFile");
            String fileName = null;

            // ファイルが選択されている場合のみ保存処理
            if (filePart != null && filePart.getSize() > 0) {
                fileName = filePart.getSubmittedFileName();
                
                // 1. ソースコード領域（開発環境の原本）へのパス
                // ※環境に合わせて調整してください
                String srcPath = "/workspaces/se25g2/src/main/webapp/image/product"; 
                File srcDir = new File(srcPath);
                
                // 2. 実行環境領域（Tomcat等のデプロイ先）へのパス
                File runDir = new File(realPath + "/image/product");

                // フォルダ作成
                if (!srcDir.exists()) srcDir.mkdirs();
                if (!runDir.exists()) runDir.mkdirs();

                // 原本に保存
                File srcFile = new File(srcDir, fileName);
                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, srcFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }

                // 実行環境へコピー（再起動しなくても即時反映されるように）
                File runFile = new File(runDir, fileName);
                Files.copy(srcFile.toPath(), runFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                
                // DB保存用にファイル名をセット
                p.setImage(fileName);
            } else {
                // 画像が変更されなかった場合は、既存の画像名を維持 (hiddenパラメータから取得)
                p.setImage(request.getParameter("currentImage")); 
            }

            // --- DAO実行 ---
            ProductDao dao = new ProductDao();
            if ("insert".equals(mode)) {
                dao.insert(p);
            } else {
                dao.update(p);
            }
            
            return new AdminProductSaveResult(true, null);

        } catch (Exception e) {
            e.printStackTrace();
            return new AdminProductSaveResult(false, "保存エラー: " + e.getMessage());
        }
    }
}