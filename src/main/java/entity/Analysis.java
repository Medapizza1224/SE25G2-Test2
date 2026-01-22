package entity;

import java.sql.Date;
import modelUtil.Failure;

public class Analysis {
    private Date analysisDate;
    private String productId;
    private int countSingle;
    private int countPair;
    private int countFamily;
    private int countAdultGroup;
    private int countGroup;
    
    // 表示用: JOINした商品情報などが必要ならフィールド追加
    private String productName;
    private String image;
    private int totalCount; // 合計用

    public Analysis() {}

    public Analysis(String productId, String productName, String image, int totalCount) {
        this.productId = productId;
        this.productName = productName;
        this.image = image;
        this.totalCount = totalCount;
    }

    // Getter/Setter
    public Date getAnalysisDate() { return analysisDate; }
    public void setAnalysisDate(Date analysisDate) { this.analysisDate = analysisDate; }
    
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    
    public int getCountSingle() { return countSingle; }
    public void setCountSingle(int count) { this.countSingle = count; }
    
    public int getCountPair() { return countPair; }
    public void setCountPair(int count) { this.countPair = count; }
    
    public int getCountFamily() { return countFamily; }
    public void setCountFamily(int count) { this.countFamily = count; }
    
    public int getCountAdultGroup() { return countAdultGroup; }
    public void setCountAdultGroup(int count) { this.countAdultGroup = count; }
    
    public int getCountGroup() { return countGroup; }
    public void setCountGroup(int count) { this.countGroup = count; }

    // 表示用
    public String getProductName() { return productName; }
    public String getImage() { return image; }
    public int getTotalCount() { return totalCount; }
}