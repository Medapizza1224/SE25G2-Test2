package servlet.system;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import control.system.PaymentSetupResult;
import control.system.PaymentSetup;

@WebServlet("/PaymentSetup")
public class PaymentSetupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. Controlを実行して Result を取得
            PaymentSetup control = new PaymentSetup();
            PaymentSetupResult result = control.execute();

            // 2. 自動ログイン処理 (Result -> Setup -> User と辿って取得)
            HttpSession session = request.getSession();
            session.setAttribute("user", result.getSetup().getUser());

            // 3. JSPへ Resultオブジェクト を渡す
            // "result" という名前で渡します
            request.setAttribute("result", result);
            
            // 4. フォワード
            request.getRequestDispatcher("/WEB-INF/user/user_setup.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Setup Error: " + e.getMessage());
        }
    }
}