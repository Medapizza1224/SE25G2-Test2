package servlet.system;

import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.KeyPair;           // 追加
import java.security.KeyPairGenerator;  // 追加
import java.security.MessageDigest;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class PaymentSystem {

    // -------------------------------------------------------------------------
    // 元のキー "12345678901234567890123456789012" をBase64エンコードしたもの。
    // (32バイト = AES-256ビットキー)
    // -------------------------------------------------------------------------
    private static final String OBFUSCATED_KEY_STR = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI=";
    private static final String ALGORITHM_AES = "AES";
    private static final String ALGORITHM_SIGN = "SHA256withRSA";
    private static final String KEY_ALGO_RSA = "RSA"; // 追加

    /**
     * 難読化されたキーを元に戻してバイト配列として取得するメソッド
     */
    private static byte[] getMasterKeyBytes() {
        return Base64.getDecoder().decode(OBFUSCATED_KEY_STR);
    }

    /**
     * 【追加】RSAキーペア（秘密鍵・公開鍵）の作成
     */
    public static KeyPair createKeyPair() throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance(KEY_ALGO_RSA);
        keyGen.initialize(2048);
        return keyGen.generateKeyPair();
    }

    /**
     * 【追加】秘密鍵の暗号化 (AES)
     * DB保存前に使用します。
     */
    public static String encryptPrivateKey(PrivateKey privateKey) throws Exception {
        byte[] keyBytes = privateKey.getEncoded(); // PKCS#8形式のバイト列
        
        // 共通鍵の生成
        SecretKeySpec keySpec = new SecretKeySpec(getMasterKeyBytes(), ALGORITHM_AES);
        
        Cipher cipher = Cipher.getInstance(ALGORITHM_AES);
        cipher.init(Cipher.ENCRYPT_MODE, keySpec);
        byte[] encryptedBytes = cipher.doFinal(keyBytes);
        
        return Base64.getEncoder().encodeToString(encryptedBytes);
    }

    // -------------------------------------------------------------------------
    // 以下、既存メソッド (decryptPrivateKey, calculateHash, signData, verifySignature)
    // -------------------------------------------------------------------------

    // 秘密鍵の復号
    public static PrivateKey decryptPrivateKey(String encryptedPrivateKeyStr) throws Exception {
        byte[] encryptedBytes = Base64.getDecoder().decode(encryptedPrivateKeyStr);
        
        SecretKeySpec keySpec = new SecretKeySpec(getMasterKeyBytes(), ALGORITHM_AES);
        
        Cipher cipher = Cipher.getInstance(ALGORITHM_AES);
        cipher.init(Cipher.DECRYPT_MODE, keySpec);
        byte[] decryptedBytes = cipher.doFinal(encryptedBytes);
        
        PKCS8EncodedKeySpec keySpecPKCS8 = new PKCS8EncodedKeySpec(decryptedBytes);
        KeyFactory kf = KeyFactory.getInstance(KEY_ALGO_RSA);
        return kf.generatePrivate(keySpecPKCS8);
    }
    
    // 公開鍵の復元（検証用）
    public static PublicKey getPublicKey(String publicKeyStr) throws Exception {
        byte[] publicBytes = Base64.getDecoder().decode(publicKeyStr);
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(publicBytes);
        KeyFactory keyFactory = KeyFactory.getInstance(KEY_ALGO_RSA);
        return keyFactory.generatePublic(keySpec);
    }

    // 電子署名を作成（ハンコを押す）
    public static String signData(String data, PrivateKey privateKey) throws Exception {
        Signature privateSignature = Signature.getInstance(ALGORITHM_SIGN);
        privateSignature.initSign(privateKey);
        privateSignature.update(data.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(privateSignature.sign());
    }

    // 署名を検証（ハンコが正しいかチェック）
    public static boolean verifySignature(String data, String signatureStr, PublicKey publicKey) {
        try {
            Signature publicSignature = Signature.getInstance(ALGORITHM_SIGN);
            publicSignature.initVerify(publicKey);
            publicSignature.update(data.getBytes(StandardCharsets.UTF_8));
            byte[] signatureBytes = Base64.getDecoder().decode(signatureStr);
            return publicSignature.verify(signatureBytes);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ハッシュ計算（指紋作成）
    public static String calculateHash(String input) {
        if (input == null) return null;
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedhash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(encodedhash);
        } catch (Exception e) {
            throw new RuntimeException("Hash Error", e);
        }
    }

    private static String bytesToHex(byte[] hash) {
        StringBuilder hexString = new StringBuilder(2 * hash.length);
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    }
}