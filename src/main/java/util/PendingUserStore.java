package util;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import entity.User;

public class PendingUserStore {
    // トークンをキーにしてユーザー情報を保持
    private static Map<String, User> pendingUsers = new ConcurrentHashMap<>();

    public static void add(String token, User user) {
        pendingUsers.put(token, user);
    }

    public static User getAndRemove(String token) {
        return pendingUsers.remove(token);
    }
}