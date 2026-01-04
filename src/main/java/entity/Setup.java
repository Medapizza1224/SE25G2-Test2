package entity;

import java.io.Serializable;

public class Setup implements Serializable {
    
    // 生成されたユーザー情報
    private User user;
    
    // 生成された注文情報（決済テスト用）
    private Order order;
    
    // 表示用の生セキュリティコード（Userエンティティの中はハッシュ化されるため）
    private String rawSecurityCode;

    public Setup() {
    }

    public Setup(User user, Order order, String rawSecurityCode) {
        this.user = user;
        this.order = order;
        this.rawSecurityCode = rawSecurityCode;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Order getOrder() {
        return order;
    }

    public void setOrder(Order order) {
        this.order = order;
    }

    public String getRawSecurityCode() {
        return rawSecurityCode;
    }

    public void setRawSecurityCode(String rawSecurityCode) {
        this.rawSecurityCode = rawSecurityCode;
    }
}