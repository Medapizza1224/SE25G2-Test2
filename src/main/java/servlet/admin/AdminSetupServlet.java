package servlet.admin;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(value = { "/admin-setup" })
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 読み込み境界
    maxFileSize = 1024 * 1024 * 10,      // 1個のファイルの最大アップロード容量（10MB）
    maxRequestSize = 1024 * 1024 * 10    // 1回の最大アップロード容量（10MB）
)
public class AdminSetupServlet extends HttpServlet {

    // 表示
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // セッションチェック
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }
        
        request.getRequestDispatcher("/WEB-INF/admin/admin_setup.jsp").forward(request, response);
    }

    // ロゴの更新
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // セッションチェック
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        try{
            if("uploadLogo".equals(action)) {
                saveLogoUpload(request);
            }
            request.getRequestDispatcher("/WEB-INF/admin/admin_setup.jsp").forward(request, response);
        } catch (Exception e){ 
            e.printStackTrace(); // エラーログ
            request.setAttribute("logoError", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/admin/admin_setup.jsp").forward(request, response);
        }
    }
    

    // 画像保存処理
    private void saveLogoUpload(HttpServletRequest request) throws IOException, ServletException {
        Part filePart = request.getPart("logoFile");
        
        // ファイル未選択チェック
        if(filePart == null || filePart.getSize() == 0) {
            request.setAttribute("logoError", "ファイルが選択されていません。");
            return;
        }

        String fileName = filePart.getSubmittedFileName();

        // SVGのファイルか確認
        if (fileName != null && fileName.toLowerCase().endsWith(".svg")) {
            
            // 原本
            String srcPath = "/workspaces/se25g2/src/main/webapp/image/logo";
            File srcDir = new File(srcPath);

            // 実行環境
            String runPath = getServletContext().getRealPath("/image/logo");
            File runDir = new File(runPath);
            
            // 原本フォルダの削除
            if (!srcDir.exists()) {
                srcDir.mkdirs();
            } else {
                File[] files = srcDir.listFiles();
                if (files != null) {
                    for (File file : files) file.delete(); 
                }
            }

            // 実行環境フォルダの削除
            if (!runDir.exists()) {
                runDir.mkdirs();
            } else {
                File[] files = runDir.listFiles();
                if (files != null) {
                    for (File file : files) file.delete(); 
                }
            }

            // 原本に保存
            File srcFile = new File(srcDir, "logo.svg");
            try (InputStream input = filePart.getInputStream()) { // 上書き
                Files.copy(input, srcFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            // 実行環境へコピー（即時変更）
            File runFile = new File(runDir, "logo.svg");
            Files.copy(srcFile.toPath(), runFile.toPath(), StandardCopyOption.REPLACE_EXISTING);


            // 成功メッセージ
            request.setAttribute("logoSuccess", "ロゴ画像を更新しました。");
        
        } else {
            request.setAttribute("logoError", "エラー: SVGファイルのみアップロード可能です。");
        }
    }
}