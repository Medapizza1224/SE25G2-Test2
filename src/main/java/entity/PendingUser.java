package entity;

import java.sql.Timestamp;

public class PendingUser {
    private String token;
    private String userId;
    private String userName;
    private String securityCode;
    private Timestamp createdAt;

    public PendingUser() {}

    public PendingUser(String token, String userId, String userName, String securityCode, Timestamp createdAt) {
        this.token = token;
        this.userId = userId;
        this.userName = userName;
        this.securityCode = securityCode;
        this.createdAt = createdAt;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getSecurityCode() { return securityCode; }
    public void setSecurityCode(String securityCode) { this.securityCode = securityCode; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}