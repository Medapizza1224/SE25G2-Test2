package control.user;
import entity.User;

public class UserLoginResult {
    private User user;
    public UserLoginResult(User user) { this.user = user; }
    public User getUser() { return user; }
}