package control.admin;

import java.util.List;
import dto.AnalysisDto;

public class AdminAnalysisResult {
    private List<AnalysisDto> ranking;
    private String currentType;

    public AdminAnalysisResult(List<AnalysisDto> ranking, String currentType) {
        this.ranking = ranking;
        this.currentType = currentType;
    }

    public List<AnalysisDto> getRanking() { return ranking; }
    public String getCurrentType() { return currentType; }
}