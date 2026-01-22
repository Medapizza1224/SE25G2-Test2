package util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class MailUtil {
    // ★ご自身のGmailアドレスと発行したアプリパスワードを入れてください
    private static final String MY_EMAIL = "inuda081012@gmail.com";
    private static final String MY_APP_PASSWORD = "jdue nbeh zygq jwav"; // 16桁のアプリパスワード

    // 既存メソッド（互換性のため残すか、新しいメソッドに委譲）
    public static void sendMail(String toEmail, String subject, String body) throws Exception {
        // デフォルトの送信者名
        sendMail(toEmail, subject, body, "焼肉〇〇 システム");
    }

    // ★追加: 差出人名を指定して送信するメソッド
    public static void sendMail(String toEmail, String subject, String body, String senderName) throws Exception {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MY_EMAIL, MY_APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        // ★修正: 指定された senderName を使用して From を設定
        message.setFrom(new InternetAddress(MY_EMAIL, senderName));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setText(body);

        Transport.send(message);
    }
}