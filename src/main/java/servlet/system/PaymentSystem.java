package servlet.system;

import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
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
    // 元のキー "12345678901234567890123456789012" をBase64エンコードしたものに変更。
    // ソースコードをパッと見ただけでは、元の文字列が何かは分かりません。
    // -------------------------------------------------------------------------
    private static final String OBFUSCATED_KEY_STR = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI=";
    private static final String ALGORITHM_AES = "AES";
    private static final String ALGORITHM_SIGN = "SHA256withRSA";

    /**
     * 【追加】難読化されたキーを元に戻してバイト配列として取得するメソッド
     * 外部からは隠蔽(private)しておく
     */
    private static byte[] getMasterKeyBytes() {
        // Base64デコードして元のバイト配列に戻す
        return Base64.getDecoder().decode(OBFUSCATED_KEY_STR);
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

    // 秘密鍵の復号
    public static PrivateKey decryptPrivateKey(String encryptedPrivateKeyStr) throws Exception {
        byte[] encryptedBytes = Base64.getDecoder().decode(encryptedPrivateKeyStr);
        
        // 【変更点】ここで難読化解除メソッドを呼び出す
        // getMasterKeyBytes() が元のキーのバイト配列を返します
        SecretKeySpec keySpec = new SecretKeySpec(getMasterKeyBytes(), ALGORITHM_AES);
        
        Cipher cipher = Cipher.getInstance(ALGORITHM_AES);
        cipher.init(Cipher.DECRYPT_MODE, keySpec);
        byte[] decryptedBytes = cipher.doFinal(encryptedBytes);
        
        PKCS8EncodedKeySpec keySpecPKCS8 = new PKCS8EncodedKeySpec(decryptedBytes);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        return kf.generatePrivate(keySpecPKCS8);
    }
    
    // 公開鍵の復元（検証用）
    public static PublicKey getPublicKey(String publicKeyStr) throws Exception {
        byte[] publicBytes = Base64.getDecoder().decode(publicKeyStr);
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(publicBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
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