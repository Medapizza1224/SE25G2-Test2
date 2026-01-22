package control.admin;

import java.util.List;
import dao.AnalysisDao;
import dto.AnalysisDto;

public class AdminAnalysisControl {
    
    public AdminAnalysisResult execute(String type) {
        // 1. パラメータがなければデフォルトを "Single" にする
        if (type == null || type.isEmpty()) {
            type = "Single";
        }

        try {
            AnalysisDao dao = new AnalysisDao();
            
            // ★修正ポイント:
            // 以前のコードにあった switch 文によるカラム名変換処理は削除しました。
            // 新しい AnalysisDao.getRanking() は "Single", "Pair" 等のタイプ名を
            // そのまま受け取って内部で適切なカラムを判断してくれます。
            List<AnalysisDto> ranking = dao.getRanking(type);
            
            return new AdminAnalysisResult(ranking, type);
            
        } catch (Exception e) {
            e.printStackTrace();
            // エラー時はランキングをnullにして結果を返す
            return new AdminAnalysisResult(null, type);
        }
    }
}