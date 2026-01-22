package control.order;

import java.util.List;
import java.util.UUID;
import dao.OrderDao;
import entity.Order;
import modelUtil.Failure;

public class TableSetupControl {

    // 初期表示用データ取得
    public TableSetupResult getInitData() throws Exception {
        OrderDao dao = new OrderDao();
        List<Order> list = dao.findActiveOrders();
        return new TableSetupResult(list);
    }

    // 新規テーブル開始前のチェック
    public void checkNewTable(String tableNumber) throws Failure, Exception {
        if (tableNumber == null || !tableNumber.matches("\\d{4}")) {
            throw new Failure("テーブル番号は4桁の数字で入力してください");
        }

        OrderDao dao = new OrderDao();
        if (dao.isTableOccupied(tableNumber)) {
            // ★ 指定のエラーメッセージに変更
            throw new Failure("テーブル " + tableNumber + " は現在稼働中です。復旧リストから選択するか、別の番号を指定してください。");
        }
    }

    // 復旧用データ取得
    public Order recoverOrder(String orderIdStr) throws Failure, Exception {
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            throw new Failure("復旧する注文が選択されていません");
        }
        
        OrderDao dao = new OrderDao();
        Order order = dao.findById(UUID.fromString(orderIdStr));
        
        if (order == null) {
            throw new Failure("指定された注文データが見つかりません");
        }
        if (order.isPaymentCompleted()) {
            throw new Failure("この注文は既に会計済みです");
        }
        
        return order;
    }
}