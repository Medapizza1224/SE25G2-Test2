package dto;

public class AnalysisDto {
    private String productName;
    private int count;
    // ▼ 追加: 画像フィールド
    private String image;

    // ▼ 変更: コンストラクタで image を受け取るように修正
    public AnalysisDto(String productName, int count, String image) {
        this.productName = productName;
        this.count = count;
        this.image = image;
    }

    public String getProductName() { return productName; }
    public int getCount() { return count; }
    
    // ▼ 追加: getter
    public String getImage() { return image; }
}