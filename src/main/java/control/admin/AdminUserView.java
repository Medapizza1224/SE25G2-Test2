package control.admin;

import java.util.List;
import dao.UserDao;
import dto.UserViewDTO;

public class AdminUserView {

    public AdminUserViewResult execute() throws Exception {
        UserDao dao = new UserDao();
        
        // DAOからUserViewDTOのリストを取得
        List<UserViewDTO> list = dao.findAllWithStatus();
        
        return new AdminUserViewResult(list);
    }
}