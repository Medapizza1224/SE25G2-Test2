package control;

import dao.DBInspectorDao;

public class DBInspectorControl {
    public DBInspectorResult execute() {
        DBInspectorDao dao = new DBInspectorDao();
        
        // DAO内の各メソッドで例外ハンドリングしているため、ここでは単純に呼び出してResultを生成
        return new DBInspectorResult(
            dao.getAllAdmins(),
            dao.getAllUsers(),
            dao.getAllProducts(),
            dao.getAllOrders(),
            dao.getAllOrderItems(),
            dao.getAllPayments(),
            dao.getAllLedgers(),
            dao.getAllOrderCounts(),
            dao.getAllAnalysis()
        );
    }
}