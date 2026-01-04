package control.admin;

import java.util.List;
import dto.UserViewDTO;

public class AdminUserViewResult {
    
    // JSPで ${result.list} と呼び出すため、フィールド名またはゲッターを合わせる
    private List<UserViewDTO> list;

    public AdminUserViewResult(List<UserViewDTO> list) {
        this.list = list;
    }

    // ★重要: JSPの ${result.list} はこの getList() を探しに行きます
    public List<UserViewDTO> getList() {
        return list;
    }
}