package util;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletContext;

public class AppConfig implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // 設定項目
    private String themeColor = "#FF6900"; // デフォルト: オレンジ
    private String mailSubject = "【焼肉〇〇】新規登録の認証をお願いします";
    private String mailBody = "以下のリンクをクリックして、登録を完了してください。\n\n{link}\n\n※このリンクの有効期限があります。";
    private List<Category> categories = new ArrayList<>();

    // 内部クラス: カテゴリ
    public static class Category implements Serializable {
        private String name;
        private String icon; // ファイル名 (例: cat_meat.svg)
        public Category(String name, String icon) {
            this.name = name;
            this.icon = icon;
        }
        public String getName() { return name; }
        public String getIcon() { return icon; }
    }

    // コンストラクタ（初期値：ファイル名に変更）
    public AppConfig() {
        categories.add(new Category("肉", "cat_meat.svg"));
        categories.add(new Category("ホルモン", "cat_hormone.svg"));
        categories.add(new Category("サイド", "cat_side.svg"));
        categories.add(new Category("ドリンク", "cat_drink.svg"));
    }

    // --- 読み書きロジック ---

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
        // アプリケーションスコープ更新
        context.setAttribute("appConfig", this);
    }

    // --- 簡易JSON処理 ---
    private String toJson() {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"themeColor\":\"").append(escape(themeColor)).append("\",");
        sb.append("\"mailSubject\":\"").append(escape(mailSubject)).append("\",");
        sb.append("\"mailBody\":\"").append(escape(mailBody)).append("\",");
        
        sb.append("\"categories\":[");
        for (int i = 0; i < categories.size(); i++) {
            Category c = categories.get(i);
            sb.append("{\"name\":\"").append(escape(c.name)).append("\",");
            sb.append("\"icon\":\"").append(escape(c.icon)).append("\"}");
            if (i < categories.size() - 1) sb.append(",");
        }
        sb.append("]");
        sb.append("}");
        return sb.toString();
    }

    private static AppConfig parseJson(String json) {
        AppConfig config = new AppConfig();
        try {
            config.setThemeColor(extract(json, "themeColor"));
            config.setMailSubject(extract(json, "mailSubject"));
            config.setMailBody(extract(json, "mailBody"));
            
            config.categories.clear();
            int catStart = json.indexOf("\"categories\":[");
            if (catStart != -1) {
                int catEnd = json.indexOf("]", catStart);
                String catJson = json.substring(catStart, catEnd + 1);
                
                String[] items = catJson.split("\\},\\{");
                for (String item : items) {
                    String name = extract(item, "name");
                    String icon = extract(item, "icon");
                    if (!name.isEmpty()) config.categories.add(new Category(name, icon));
                }
            }
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
    public String getThemeColor() { return themeColor; }
    public void setThemeColor(String themeColor) { this.themeColor = themeColor; }
    public String getMailSubject() { return mailSubject; }
    public void setMailSubject(String mailSubject) { this.mailSubject = mailSubject; }
    public String getMailBody() { return mailBody; }
    public void setMailBody(String mailBody) { this.mailBody = mailBody; }
    public List<Category> getCategories() { return categories; }
    public void setCategories(List<Category> categories) { this.categories = categories; }
}