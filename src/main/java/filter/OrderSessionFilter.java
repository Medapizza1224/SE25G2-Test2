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

/**
 * 注文端末（tableNumberを持つセッション）が、
 * 許可された注文関連画面以外にアクセスした場合に
 * セッションを破棄して強制ログアウトさせるフィルター。
 */
@WebFilter("/*")
public class OrderSessionFilter extends HttpFilter {

    // 注文端末がアクセスしてもよいパスのリスト（前方一致または完全一致で使用）
    private static final List<String> ALLOWED_PATHS = Arrays.asList(
        "/Order",              // 注文ログイン, ホーム, 履歴, カートなど (/Order~ で始まるもの全て)
        "/CustomerCount",      // 人数選択
        "/ProductDetail",      // 商品詳細
        "/ShowQr",             // 決済QR表示
        "/CheckPaymentStatus", // 決済状況確認API
        "/image/",             // 画像リソース
        "/css/",               // CSSリソース
        "/js/"                 // JSリソース
    );

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpSession session = request.getSession(false);
        
        // 1. セッションがあり、かつ「注文端末(tableNumberあり)」としてログイン中か確認
        if (session != null && session.getAttribute("tableNumber") != null) {
            
            String path = request.getServletPath();
            
            // 2. アクセスしようとしているパスが「許可リスト」に含まれているかチェック
            boolean isAllowed = false;
            for (String allowed : ALLOWED_PATHS) {
                if (path.startsWith(allowed)) {
                    isAllowed = true;
                    break;
                }
            }

            // 3. 許可されていないパス（例: /User, /Admin など）へのアクセスなら
            if (!isAllowed) {
                // セッションを破棄（ログアウト扱い）
                session.invalidate();
                
                // 注文端末のログイン画面へ強制送還
                response.sendRedirect(request.getContextPath() + "/Order");
                return; // 処理をここで中断
            }
        }

        // 問題なければ次の処理へ
        chain.doFilter(request, response);
    }
}