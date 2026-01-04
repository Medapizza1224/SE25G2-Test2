package control.admin;

import entity.Admin;

public class AdminLoginResult {
    private Admin admin;

    public AdminLoginResult(Admin admin) {
        this.admin = admin;
    }

    public Admin getAdmin() {
        return admin;
    }
}