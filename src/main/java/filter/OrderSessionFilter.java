package filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class OrderSessionFilter extends HttpFilter {

    // 客が操作中にアクセスを許可するパス
    private static final List<String> ORDER_FLOW_PATHS = Arrays.asList(
        "/OrderHome", "/CustomerCount", "/ProductDetail", "/ShowQr", 
        "/PaymentSelect", "/CheckPaymentStatus", "/OrderComplete", 
        "/OrderReceived", "/OrderReset", "/OrderSubmit"
    );

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpSession session = request.getSession(false);
        String path = request.getServletPath();

        // 1. 公開リソースとログイン入口は常に許可
        if (path.startsWith("/image/") || path.startsWith("/css/") || path.startsWith("/js/") || 
            path.equals("/DB") || path.equals("/Admin") || path.equals("/Order") || path.equals("/User")) {
            chain.doFilter(request, response);
            return;
        }

        // 2. 管理者ツール (/Admin... /admin-setup)
        if (path.startsWith("/Admin") || path.equals("/admin-setup")) {
            if (session == null || session.getAttribute("adminNameManagement") == null) {
                response.sendRedirect(request.getContextPath() + "/Admin");
                return;
            }
            chain.doFilter(request, response);
            return;
        }

        // 3. 端末設定画面 (/OrderSetup) 
        // 卓番が決まる前の画面なので、terminalSetupAuthのみをチェックする
        if (path.equals("/OrderSetup")) {
            if (session == null || session.getAttribute("terminalSetupAuth") == null) {
                response.sendRedirect(request.getContextPath() + "/Order");
                return;
            }
            chain.doFilter(request, response);
            return;
        }

        // 4. 注文端末の実操作画面 (メニューなど)
        boolean isOrderPath = false;
        for (String op : ORDER_FLOW_PATHS) {
            if (path.startsWith(op)) {
                isOrderPath = true;
                break;
            }
        }
        if (isOrderPath) {
            // 卓番(tableNumber)がなければ設定画面へ戻す
            if (session == null || session.getAttribute("tableNumber") == null) {
                response.sendRedirect(request.getContextPath() + "/Order");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}