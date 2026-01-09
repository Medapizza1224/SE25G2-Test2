package util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class MailUtil {
    // ★ご自身のGmailアドレスと発行したアプリパスワードを入れてください
    private static final String MY_EMAIL = "inuda081012@gmail.com";
    private static final String MY_APP_PASSWORD = "jdue nbeh zygq jwav"; // 16桁のアプリパスワード

    public static void sendAuthMail(String toEmail, String authUrl) throws Exception {
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
        message.setFrom(new InternetAddress(MY_EMAIL, "焼肉〇〇 システム"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("【焼肉〇〇】新規登録の認証をお願いします");

        String content = "以下のリンクをクリックして、登録を完了してください。\n\n"
                       + authUrl + "\n\n"
                       + "※このリンクの有効期限があります。";
        
        message.setText(content);

        Transport.send(message);
    }
}