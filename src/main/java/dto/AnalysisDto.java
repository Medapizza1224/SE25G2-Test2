package dto;

public class AnalysisDto {
    private String productName;
    private int count;

    public AnalysisDto(String productName, int count) {
        this.productName = productName;
        this.count = count;
    }

    public String getProductName() { return productName; }
    public int getCount() { return count; }
}