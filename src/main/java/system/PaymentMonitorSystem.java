package system;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.*;
import java.util.concurrent.*;
import dao.DataSourceHolder; // 既存のDB接続クラス

@WebListener
public class PaymentMonitorSystem implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // アプリ起動時に監視スケジューラーを開始
        scheduler = Executors.newSingleThreadScheduledExecutor();
        // 5分ごとにチェック実行
        scheduler.scheduleAtFixedRate(this::audit, 1, 5, TimeUnit.MINUTES);
        System.out.println("★ LedgerMonitor: 監視を開始しました");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) scheduler.shutdownNow();
    }

    // 監査ロジック
    private void audit() {
        Connection con = null;
        try {
            // ※ここでは簡易的に1つのノードだけチェック（実運用は全ノードチェック推奨）
            con = new DataSourceHolder().getConnection(); 
            
            Statement stmt = con.createStatement();
            // 古い順に全データを取得
            ResultSet rs = stmt.executeQuery("SELECT * FROM ledger ORDER BY height ASC");

            String calculatedPrevHash = "0"; // Genesis Blockのprev_hash定義に合わせる

            while (rs.next()) {
                int height = rs.getInt("height");
                String currentHash = rs.getString("curr_hash");
                String prevHash = rs.getString("prev_hash");

                // === 【追加】Genesis Block (height=1) は固定値なのでチェックをスキップ ===
                if (height == 1) {
                    // 次のブロック計算用に、このブロックのハッシュを記憶して次へ
                    calculatedPrevHash = currentHash; 
                    continue; 
                }
                // ================================================================
                
                String senderId = rs.getString("sender_id");
                int amount = rs.getInt("amount");
                String signature = rs.getString("signature");

                // チェック1: チェーンの連続性
                // (Genesis Blockは除外する条件分岐が必要な場合あり)
                if (height > 1 && !prevHash.equals(calculatedPrevHash)) {
                    alert("チェーン切断検知 Height:" + height);
                    return;
                }

                // チェック2: ハッシュ改ざん検知
                // 保存されているデータからハッシュを再計算
                String data = senderId + amount + prevHash + signature;
                String reCalc = PaymentSystem.calculateHash(data);

                if (!reCalc.equals(currentHash)) {
                    alert("改ざん検知 Height:" + height + " DB値:" + currentHash + " 計算値:" + reCalc);
                    return;
                }

                // 次のループ用にハッシュを保存
                calculatedPrevHash = currentHash;
            }
            System.out.println("LedgerMonitor: 異常なし");

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
    }

    private void alert(String msg) {
        System.err.println("[緊急セキュリティ警告] " + msg);
        // ここで管理者にメール送信などを実装
    }
}