package servlet.admin;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.AppConfig;

@WebServlet(value = { "/admin-setup" })
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 10
)
public class AdminSetupServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminNameManagement") == null) {
            response.sendRedirect(request.getContextPath() + "/Admin");
            return;
        }
        // 現在の設定をロード
        AppConfig config = AppConfig.load(getServletContext());
        request.setAttribute("config", config);
        
        request.getRequestDispatcher("/WEB-INF/admin/admin_setup.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminNameManagement") == null) {
            response.sendRedirect(request.getContextPath() + "/Admin");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        try {
            if ("uploadLogo".equals(action)) {
                saveLogoUpload(request);
            } else if ("saveConfig".equals(action)) {
                saveConfig(request);
            }
            // リダイレクトして画面更新
            response.sendRedirect("admin-setup");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("logoError", e.getMessage());
            doGet(request, response); // エラー時はフォワード
        }
    }

    private void saveConfig(HttpServletRequest request) {
        AppConfig config = new AppConfig();
        
        // テーマカラー
        config.setThemeColor(request.getParameter("themeColor"));
        
        // メール設定
        config.setMailSubject(request.getParameter("mailSubject"));
        config.setMailBody(request.getParameter("mailBody"));
        
        // カテゴリ設定
        String[] catNames = request.getParameterValues("catName");
        String[] catIcons = request.getParameterValues("catIcon");
        List<AppConfig.Category> list = new ArrayList<>();
        
        if (catNames != null && catIcons != null) {
            for (int i = 0; i < catNames.length; i++) {
                if (!catNames[i].trim().isEmpty()) {
                    list.add(new AppConfig.Category(catNames[i], catIcons[i]));
                }
            }
        }
        config.setCategories(list);

        // 保存
        config.save(getServletContext());
        request.getSession().setAttribute("logoSuccess", "設定を保存しました。");
    }
    
    private void saveLogoUpload(HttpServletRequest request) throws IOException, ServletException {
        // (以前のコードと同じ: 省略せず記述します)
        Part filePart = request.getPart("logoFile");
        if(filePart == null || filePart.getSize() == 0) {
            throw new ServletException("ファイルが選択されていません。");
        }
        String fileName = filePart.getSubmittedFileName();
        if (fileName != null && fileName.toLowerCase().endsWith(".svg")) {
            String srcPath = "/workspaces/SE25G2-Test2/src/main/webapp/image/logo";
            File srcDir = new File(srcPath);
            String runPath = getServletContext().getRealPath("/image/logo");
            File runDir = new File(runPath);
            
            if (!srcDir.exists()) srcDir.mkdirs(); else { for(File f:srcDir.listFiles()) f.delete(); }
            if (!runDir.exists()) runDir.mkdirs(); else { for(File f:runDir.listFiles()) f.delete(); }

            File srcFile = new File(srcDir, "logo.svg");
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, srcFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
            File runFile = new File(runDir, "logo.svg");
            Files.copy(srcFile.toPath(), runFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

            getServletContext().setAttribute("logoVersion", String.valueOf(System.currentTimeMillis()));
            request.getSession().setAttribute("logoSuccess", "ロゴ画像を更新しました。");
        } else {
            throw new ServletException("エラー: SVGファイルのみアップロード可能です。");
        }
    }
}