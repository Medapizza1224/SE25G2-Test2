package control.admin;

import java.util.UUID;
import dao.UserDao;

public class AdminUserUnlock {

    public void execute(String userIdStr) throws Exception {
        if (userIdStr == null || userIdStr.isEmpty()) {
            return;
        }
        
        UserDao dao = new UserDao();
        dao.unlockUser(UUID.fromString(userIdStr));
    }
}