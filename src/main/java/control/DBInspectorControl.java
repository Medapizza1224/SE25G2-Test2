package control;

import dao.DBInspectorDao;

public class DBInspectorControl {
    public DBInspectorResult execute() {
        DBInspectorDao dao = new DBInspectorDao();
        
        return new DBInspectorResult(
            dao.getAllAdmins(),
            dao.getAllUsers(),
            dao.getAllPendingUsers(), // ★追加: 3番目の引数として渡す
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