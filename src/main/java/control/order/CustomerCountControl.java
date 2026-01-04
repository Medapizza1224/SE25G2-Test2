package control.order;

import java.sql.Timestamp;
import java.util.UUID;
import dao.OrderDao;
import entity.Order;
import modelUtil.Failure;

public class CustomerCountControl {
    public Order execute(String tableNumber, String adultStr, String childStr) throws Failure {
        try {
            int adult = Integer.parseInt(adultStr);
            int child = Integer.parseInt(childStr);

            if (adult + child > 8) {
                throw new Failure("合計人数は8名までです。");
            }

            // 新規注文（伝票）オブジェクト作成
            Order order = new Order();
            order.setOrderId(UUID.randomUUID());
            order.setTableNumber(tableNumber);
            order.setAdultCount(adult);
            order.setChildCount(child);
            order.setPaymentCompleted(false);
            order.setVisitAt(new Timestamp(System.currentTimeMillis()));

            // DB保存
            OrderDao dao = new OrderDao();
            dao.create(order);

            return order;

        } catch (NumberFormatException e) {
            throw new Failure("人数の形式が不正です");
        } catch (Exception e) {
            e.printStackTrace();
            throw new Failure("システムエラーが発生しました");
        }
    }
}