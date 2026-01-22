package entity;

import java.sql.Timestamp;

public class Ledger {
    private int height;
    private String prevHash;
    private String currHash;
    private String senderId;
    private int amount;
    private String signature;
    private Timestamp createdAt;

    public Ledger() {}

    public Ledger(int height, String prevHash, String currHash, String senderId, int amount, String signature, Timestamp createdAt) {
        this.height = height;
        this.prevHash = prevHash;
        this.currHash = currHash;
        this.senderId = senderId;
        this.amount = amount;
        this.signature = signature;
        this.createdAt = createdAt;
    }

    public int getHeight() { return height; }
    public void setHeight(int height) { this.height = height; }
    public String getPrevHash() { return prevHash; }
    public void setPrevHash(String prevHash) { this.prevHash = prevHash; }
    public String getCurrHash() { return currHash; }
    public void setCurrHash(String currHash) { this.currHash = currHash; }
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
    public String getSignature() { return signature; }
    public void setSignature(String signature) { this.signature = signature; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}