package filter;

import java.io.IOException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * すべての画面でブラウザのキャッシュを無効化するフィルター
 */
@WebFilter("/*")
public class NoCacheFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        String path = request.getRequestURI();

        // 画像、CSS、JSファイル以外（＝画面のHTML）に対して設定を行う
        if (!path.contains("/image/") && !path.contains("/css/") && !path.contains("/js/")) {
            // ブラウザに「この画面を記憶するな」と命令するヘッダー
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
            response.setHeader("Pragma", "no-cache"); // HTTP 1.0
            response.setDateHeader("Expires", 0); // Proxies
        }

        chain.doFilter(request, response);
    }
}