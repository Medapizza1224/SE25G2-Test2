package servlet.admin;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.ProductDao;
import entity.Product;
import control.admin.AdminProductEditResult;
import control.admin.AdminProductSaveControl;
import control.admin.AdminProductSaveResult;

@WebServlet("/AdminProductEdit")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 10     // 10MB
)
public class AdminProductEditServlet extends HttpServlet {
    
    // フォーム表示 (GET)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        Product p = new Product();
        String mode = "insert";

        // IDがあれば更新モードとしてデータを取得
        if (id != null) {
            try {
                ProductDao dao = new ProductDao();
                p = dao.findById(id);
                if (p != null) {
                    mode = "update";
                }
            } catch (Exception e) { e.printStackTrace(); }
        }
        
        // Resultを作成してJSPへ渡す
        AdminProductEditResult result = new AdminProductEditResult(p, mode);
        request.setAttribute("result", result);
        
        request.getRequestDispatcher("/WEB-INF/admin/product_edit.jsp").forward(request, response);
    }

    // 保存処理 (POST)
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        AdminProductSaveControl control = new AdminProductSaveControl();
        // コンテキストパス配下の物理パスを取得して渡す
        String realPath = getServletContext().getRealPath("");
        
        AdminProductSaveResult result = control.execute(request, realPath);
        
        if (result.isSuccess()) {
            response.sendRedirect("AdminProductList");
        } else {
            // エラー時はフォームに戻る
            request.setAttribute("error", result.getErrorMessage());
            doGet(request, response);
        }
    }
}