package servlet.admin;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

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
        AppConfig config = AppConfig.load(getServletContext());

        try {
            // --- 基本設定の保存 ---
            if ("saveTheme".equals(action)) {
                config.setStoreName(request.getParameter("storeName"));
                config.setThemeColor(request.getParameter("themeColor"));
                config.save(getServletContext());
                request.getSession().setAttribute("logoSuccess", "店舗・テーマ設定を保存しました。");
            
            } else if ("saveMail".equals(action)) {
                config.setMailSubject(request.getParameter("mailSubject"));
                config.setMailBody(request.getParameter("mailBody"));
                config.save(getServletContext());
                request.getSession().setAttribute("logoSuccess", "メール設定を保存しました。");

            // --- ロゴアップロード ---
            } else if ("uploadLogo".equals(action)) {
                saveLogoUpload(request);

            // --- カテゴリ操作 ---
            } else if ("addCategory".equals(action)) {
                addItemWithIcon(request, config, "category");
            } else if ("handleCategory".equals(action)) {
                // 更新または削除
                String cmd = request.getParameter("cmd");
                if("delete".equals(cmd)) {
                    deleteItem(request, config, "category");
                } else {
                    updateItem(request, config, "category");
                }

            // --- 決済操作 ---
            } else if ("addPayment".equals(action)) {
                addItemWithIcon(request, config, "payment");
            } else if ("handlePayment".equals(action)) {
                String cmd = request.getParameter("cmd");
                if("delete".equals(cmd)) {
                    deleteItem(request, config, "payment");
                } else {
                    updateItem(request, config, "payment");
                }
            }

            response.sendRedirect("admin-setup");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("logoError", e.getMessage());
            doGet(request, response);
        }
    }

    // 新規追加
    private void addItemWithIcon(HttpServletRequest request, AppConfig config, String type) throws IOException, ServletException {
        String name = request.getParameter("name");
        String fileName = saveUploadedFile(request.getPart("iconFile"));

        // 画像がない場合は空文字またはデフォルトを許容（今回は必須想定だがnullチェック）
        if (fileName == null) fileName = "";

        if ("category".equals(type)) {
            config.getCategories().add(new AppConfig.Category(name, fileName));
        } else {
            config.getPaymentMethods().add(new AppConfig.PaymentMethod(name, fileName));
        }
        config.save(getServletContext());
    }

    // 更新処理
    private void updateItem(HttpServletRequest request, AppConfig config, String type) throws IOException, ServletException {
        int index = Integer.parseInt(request.getParameter("index"));
        String newName = request.getParameter("name");
        Part filePart = request.getPart("iconFile");
        
        // 画像保存（共通）
        String newIcon = saveUploadedFile(filePart);

        // カテゴリの場合
        if ("category".equals(type)) {
            List<AppConfig.Category> list = config.getCategories();
            if (index >= 0 && index < list.size()) {
                // 画像が未選択なら元の画像を維持
                if (newIcon == null) {
                    newIcon = list.get(index).getIcon();
                }
                // 更新
                list.set(index, new AppConfig.Category(newName, newIcon));
                
                config.save(getServletContext());
                request.getSession().setAttribute("logoSuccess", "カテゴリを更新しました。");
            }
        } 
        // 決済方法の場合
        else {
            List<AppConfig.PaymentMethod> list = config.getPaymentMethods();
            if (index >= 0 && index < list.size()) {
                // 画像が未選択なら元の画像を維持
                if (newIcon == null) {
                    newIcon = list.get(index).getIcon();
                }
                // 更新
                list.set(index, new AppConfig.PaymentMethod(newName, newIcon));
                
                config.save(getServletContext());
                request.getSession().setAttribute("logoSuccess", "決済方法を更新しました。");
            }
        }
    }

    // 削除処理
    private void deleteItem(HttpServletRequest request, AppConfig config, String type) {
        int index = Integer.parseInt(request.getParameter("index"));
        if ("category".equals(type)) {
            if (index >= 0 && index < config.getCategories().size()) {
                config.getCategories().remove(index);
            }
        } else {
            if (index >= 0 && index < config.getPaymentMethods().size()) {
                config.getPaymentMethods().remove(index);
            }
        }
        config.save(getServletContext());
        request.getSession().setAttribute("logoSuccess", "項目を削除しました。");
    }

    // ファイル保存の共通処理（UUIDリネームして2箇所に保存）
    private String saveUploadedFile(Part filePart) throws IOException {
        if(filePart == null || filePart.getSize() == 0) return null;

        String submittedName = filePart.getSubmittedFileName();
        String ext = "";
        if (submittedName != null && submittedName.contains(".")) {
             ext = submittedName.substring(submittedName.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString() + ext; 

        String srcPath = "/workspaces/SE25G2-Test2/src/main/webapp/image/icons";
        String runPath = getServletContext().getRealPath("/image/icons");
        
        // メモリに読み込んでから保存（ストリーム消費対策）
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        InputStream is = filePart.getInputStream();
        int nRead;
        byte[] data = new byte[1024];
        while ((nRead = is.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, nRead);
        }
        buffer.flush();
        byte[] fileBytes = buffer.toByteArray();

        saveBytesToFile(fileBytes, srcPath, fileName);
        saveBytesToFile(fileBytes, runPath, fileName);
        
        return fileName;
    }

    private void saveBytesToFile(byte[] data, String dirPath, String fileName) {
        try {
            File dir = new File(dirPath);
            if(!dir.exists()) dir.mkdirs();
            try (FileOutputStream fos = new FileOutputStream(new File(dir, fileName))) {
                fos.write(data);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // ロゴ画像のアップロード処理（固定名 logo.svg）
    private void saveLogoUpload(HttpServletRequest request) throws IOException, ServletException {
        Part filePart = request.getPart("logoFile");
        if(filePart == null || filePart.getSize() == 0) {
            throw new ServletException("ファイルが選択されていません。");
        }
        String fileName = filePart.getSubmittedFileName();
        if (fileName != null && fileName.toLowerCase().endsWith(".svg")) {
            String srcPath = "/workspaces/SE25G2-Test2/src/main/webapp/image/logo";
            String runPath = getServletContext().getRealPath("/image/logo");
            
            // こちらはそのままストリームコピーでOK（専用処理なので）
            // ただし2箇所保存のためバイト配列経由にする
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            InputStream is = filePart.getInputStream();
            byte[] data = new byte[1024];
            int nRead;
            while ((nRead = is.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, nRead);
            }
            byte[] bytes = buffer.toByteArray();

            saveBytesToFile(bytes, srcPath, "logo.svg");
            saveBytesToFile(bytes, runPath, "logo.svg");

            getServletContext().setAttribute("logoVersion", String.valueOf(System.currentTimeMillis()));
            request.getSession().setAttribute("logoSuccess", "ロゴ画像を更新しました。");
        } else {
            throw new ServletException("エラー: SVGファイルのみアップロード可能です。");
        }
    }
}