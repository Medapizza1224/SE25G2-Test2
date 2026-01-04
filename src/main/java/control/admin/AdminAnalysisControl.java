package control.admin;

import java.util.List;
import dao.OrderCountDao;
import dto.AnalysisDto;

public class AdminAnalysisControl {
    public AdminAnalysisResult execute(String type) {
        if (type == null) type = "Single";

        // タブの種類をDBカラム名に変換
        String column = "order_count_from_single_adult";
        switch (type) {
            case "Pair": column = "order_count_from_two_adults"; break;
            case "Family": column = "order_count_from_family_group"; break;
            case "AdultGroup": column = "order_count_from_adult_group"; break;
            case "Group": column = "order_count_from_group"; break;
        }

        try {
            OrderCountDao dao = new OrderCountDao();
            List<AnalysisDto> ranking = dao.getRanking(column);
            return new AdminAnalysisResult(ranking, type);
        } catch (Exception e) {
            e.printStackTrace();
            return new AdminAnalysisResult(null, type);
        }
    }
}