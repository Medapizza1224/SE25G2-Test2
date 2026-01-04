package dto;

import entity.User;

public class UserViewDTO {
    private User user;
    private boolean isPaid;

    public UserViewDTO(User user, boolean isPaid) {
        this.user = user;
        this.isPaid = isPaid;
    }

    public User getUser() { return user; }
    public boolean isPaid() { return isPaid; }
}