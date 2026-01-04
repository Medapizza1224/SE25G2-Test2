package modelUtil;

import entity.Order;

public class CustomerTypeLogic {
    public static String determineType(Order order) {
        int adult = order.getAdultCount();
        int child = order.getChildCount();

        if (child > 0) {
            return "Family"; // 子供がいればファミリー
        }
        if (adult == 1) {
            return "Single"; // 大人1人
        }
        if (adult == 2) {
            return "Pair";   // 大人2人
        }
        if (adult >= 3) {
            return "AdultGroup"; // 大人グループ
        }
        
        return "Group"; // その他（念のため）
    }
}