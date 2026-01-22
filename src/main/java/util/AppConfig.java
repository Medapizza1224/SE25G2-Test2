package util;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletContext;

public class AppConfig implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // ★追加: 店舗名 (デフォルト値つき)
    private String storeName = "焼肉〇〇";

    private String themeColor = "#FF6900";
    private String mailSubject = "【{store}】新規登録の認証をお願いします"; // {store}で置換可能に
    private String mailBody = "以下のリンクをクリックして、登録を完了してください。\n\n{link}\n\n※このリンクの有効期限があります。";
    
    private List<Category> categories = new ArrayList<>();
    // ★追加: 決済方法リスト
    private List<PaymentMethod> paymentMethods = new ArrayList<>();

    // 内部クラス: カテゴリ
    public static class Category implements Serializable {
        private String name;
        private String icon;
        public Category(String name, String icon) {
            this.name = name;
            this.icon = icon;
        }
        public String getName() { return name; }
        public String getIcon() { return icon; }
    }

    // ★追加: 決済方法クラス
    public static class PaymentMethod implements Serializable {
        private String name;
        private String icon; // アイコンファイル名
        public PaymentMethod(String name, String icon) {
            this.name = name;
            this.icon = icon;
        }
        public String getName() { return name; }
        public String getIcon() { return icon; }
    }

    public AppConfig() {
        // 初期データ
        categories.add(new Category("肉", "cat_meat.svg"));
        categories.add(new Category("ホルモン", "cat_hormone.svg"));
        categories.add(new Category("サイド", "cat_side.svg"));
        categories.add(new Category("ドリンク", "cat_drink.svg"));
        
        // ★追加: デフォルト決済方法
        paymentMethods.add(new PaymentMethod("QRコード決済", "pay_qr.svg"));
    }

    public static AppConfig load(ServletContext context) {
        String path = context.getRealPath("/WEB-INF/data/config.json");
        File file = new File(path);
        
        if (!file.exists()) {
            AppConfig def = new AppConfig();
            def.save(context);
            return def;
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            StringBuilder json = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) json.append(line);
            return parseJson(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            return new AppConfig();
        }
    }

    public void save(ServletContext context) {
        String dirPath = context.getRealPath("/WEB-INF/data");
        File dir = new File(dirPath);
        if (!dir.exists()) dir.mkdirs();

        String path = dirPath + "/config.json";
        try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(path), StandardCharsets.UTF_8))) {
            bw.write(toJson());
        } catch (Exception e) {
            e.printStackTrace();
        }
        context.setAttribute("appConfig", this);
    }

    private String toJson() {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        // ★追加
        sb.append("\"storeName\":\"").append(escape(storeName)).append("\",");
        
        sb.append("\"themeColor\":\"").append(escape(themeColor)).append("\",");
        sb.append("\"mailSubject\":\"").append(escape(mailSubject)).append("\",");
        sb.append("\"mailBody\":\"").append(escape(mailBody)).append("\",");
        
        sb.append("\"categories\":[");
        for (int i = 0; i < categories.size(); i++) {
            Category c = categories.get(i);
            sb.append("{\"name\":\"").append(escape(c.getName())).append("\",");
            sb.append("\"icon\":\"").append(escape(c.getIcon())).append("\"}");
            if (i < categories.size() - 1) sb.append(",");
        }
        sb.append("],"); // カンマ追加

        // ★追加: 決済方法のJSON化
        sb.append("\"paymentMethods\":[");
        for (int i = 0; i < paymentMethods.size(); i++) {
            PaymentMethod p = paymentMethods.get(i);
            sb.append("{\"name\":\"").append(escape(p.getName())).append("\",");
            sb.append("\"icon\":\"").append(escape(p.getIcon())).append("\"}");
            if (i < paymentMethods.size() - 1) sb.append(",");
        }
        sb.append("]");
        
        sb.append("}");
        return sb.toString();
    }

    private static AppConfig parseJson(String json) {
        AppConfig config = new AppConfig();
        try {
            // ★追加
            String sn = extract(json, "storeName");
            if (!sn.isEmpty()) config.setStoreName(sn);

            config.setThemeColor(extract(json, "themeColor"));
            config.setMailSubject(extract(json, "mailSubject"));
            config.setMailBody(extract(json, "mailBody"));
            
            // カテゴリ
            int catStart = json.indexOf("\"categories\":[");
            if (catStart != -1) {
                config.getCategories().clear();
                int catEnd = json.indexOf("]", catStart);
                String catJson = json.substring(catStart, catEnd + 1);
                String[] items = catJson.split("\\},\\{");
                for (String item : items) {
                    String name = extract(item, "name");
                    String icon = extract(item, "icon");
                    if (!name.isEmpty()) config.getCategories().add(new Category(name, icon));
                }
            }

            // ★追加: 決済方法
            int payStart = json.indexOf("\"paymentMethods\":[");
            if (payStart != -1) {
                config.getPaymentMethods().clear(); // ★JSONにデータがある場合のみクリアして読み込む
                
                int payEnd = json.indexOf("]", payStart);
                String payJson = json.substring(payStart, payEnd + 1);
                String[] items = payJson.split("\\},\\{");
                for (String item : items) {
                    String name = extract(item, "name");
                    String icon = extract(item, "icon");
                    if (!name.isEmpty()) config.getPaymentMethods().add(new PaymentMethod(name, icon));
                }
            }
            // JSONにデータがない場合は、コンストラクタで設定された初期値（QRコード決済）が維持されます

        } catch (Exception e) {
            e.printStackTrace();
        }
        return config;
    }

    private static String extract(String source, String key) {
        String pattern = "\"" + key + "\":\"";
        int start = source.indexOf(pattern);
        if (start == -1) return "";
        start += pattern.length();
        
        StringBuilder val = new StringBuilder();
        boolean escape = false;
        for (int i = start; i < source.length(); i++) {
            char c = source.charAt(i);
            if (escape) {
                if (c == 'n') val.append('\n');
                else if (c == '\"') val.append('\"');
                else if (c == '\\') val.append('\\');
                else val.append(c);
                escape = false;
            } else {
                if (c == '\\') escape = true;
                else if (c == '"') break;
                else val.append(c);
            }
        }
        return val.toString();
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }

    // Getter / Setter
    public String getStoreName() { return storeName; }
    public void setStoreName(String storeName) { this.storeName = storeName; }

    public String getThemeColor() { return themeColor; }
    public void setThemeColor(String themeColor) { this.themeColor = themeColor; }
    public String getMailSubject() { return mailSubject; }
    public void setMailSubject(String mailSubject) { this.mailSubject = mailSubject; }
    public String getMailBody() { return mailBody; }
    public void setMailBody(String mailBody) { this.mailBody = mailBody; }
    public List<Category> getCategories() { return categories; }
    public void setCategories(List<Category> categories) { this.categories = categories; }
    // ★追加
    public List<PaymentMethod> getPaymentMethods() { return paymentMethods; }
    public void setPaymentMethods(List<PaymentMethod> paymentMethods) { this.paymentMethods = paymentMethods; }
}