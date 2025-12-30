-- ==========================================
-- 1. 既存テーブルのクリーンアップ
-- （外部キーの依存関係順に削除）
-- ==========================================
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS analysis;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS order_counts;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS admins;
DROP TABLE IF EXISTS ledger;
DROP TABLE IF EXISTS users;

-- ==========================================
-- A. 分散管理データ（ブロックチェーン領域）
-- ==========================================

-- ユーザーテーブル
CREATE TABLE users (
    user_id CHAR(36) PRIMARY KEY,
    user_name VARCHAR(32) NOT NULL,
    user_password VARCHAR(255) NOT NULL,
    security_code VARCHAR(255) NOT NULL,
    balance INT DEFAULT 0,
    point INT DEFAULT 0,
    login_attempt_count INT DEFAULT 0,
    is_lockout BOOLEAN DEFAULT FALSE,
    encrypted_private_key TEXT NOT NULL, 
    public_key TEXT NOT NULL
);

-- ブロックチェーン台帳
-- MySQLでの互換性のため SERIAL -> INT AUTO_INCREMENT に変更
CREATE TABLE ledger (
    height INT AUTO_INCREMENT PRIMARY KEY,
    prev_hash VARCHAR(64) NOT NULL,
    curr_hash VARCHAR(64) NOT NULL,
    sender_id CHAR(36) NOT NULL,
    amount INT NOT NULL,
    signature TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Genesis Block（初期ブロック）
-- これがないとハッシュチェーン計算が開始できません
INSERT INTO ledger (prev_hash, curr_hash, sender_id, amount, signature)
VALUES ('0', 'GENESIS_HASH', 'SYSTEM', 0, 'SYSTEM_SIG');


-- ==========================================
-- B. 店舗データ（業務アプリケーション領域）
-- ==========================================

-- 管理者
CREATE TABLE admins (
    admin_name VARCHAR(32) PRIMARY KEY, 
    admin_password VARCHAR(255)
);

-- 商品
CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY, 
    product_name VARCHAR(64), 
    image VARCHAR(255), 
    category VARCHAR(32), 
    price INT, 
    sales_status VARCHAR(32), 
    update_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 注文集計
CREATE TABLE order_counts (
    product_id VARCHAR(32) PRIMARY KEY, 
    order_count_from_single_adult INT DEFAULT 0, 
    order_count_from_two_adults INT DEFAULT 0, 
    order_count_from_family_group INT DEFAULT 0, 
    order_count_from_adult_group INT DEFAULT 0, 
    order_count_from_group INT DEFAULT 0, 
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 注文ヘッダ
CREATE TABLE orders (
    order_id CHAR(36) PRIMARY KEY, 
    table_number CHAR(4), 
    adult_count INT, 
    child_count INT, 
    is_payment_completed BOOLEAN DEFAULT FALSE, 
    visit_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 注文明細
CREATE TABLE order_items (
    order_item_id CHAR(36) PRIMARY KEY, 
    order_id CHAR(36), 
    product_id VARCHAR(32), 
    quantity INT, 
    price INT, 
    add_order_at DATETIME, 
    order_completed_at DATETIME, 
    order_status VARCHAR(32), 
    FOREIGN KEY (order_id) REFERENCES orders(order_id), 
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 決済履歴
CREATE TABLE payments (
    order_id CHAR(36) PRIMARY KEY, 
    user_id CHAR(36), 
    used_points INT DEFAULT 0, 
    earned_points INT DEFAULT 0, 
    payment_completed_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 分析用
CREATE TABLE analysis (
    product_id VARCHAR(32), 
    customer_segment VARCHAR(32), 
    order_count INT, 
    update_date DATETIME, 
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- ==========================================
-- C. 初期データ投入 (12,000円決済テスト用)
-- ==========================================

-- 1. 商品データ (P001, P002を使用)
INSERT INTO products (product_id, product_name, category, price, sales_status) VALUES 
('P001', '特選ロース焼肉セット', 'FOOD', 5000, '販売中'),
('P002', '上タン塩', 'FOOD', 2000, '販売中'),
('P003', 'プレミアム飲み放題', 'DRINK', 3000, '販売中'),
('PROD005', '季節のパフェ', 'DESSERT', 950, '販売中'); -- 追加分

-- 2. 注文ヘッダ
-- ID: a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
INSERT INTO orders (order_id, table_number, adult_count, child_count, is_payment_completed, visit_at)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '10', 2, 0, FALSE, NOW());

-- 3. 注文明細
-- (5000 * 2) + (2000 * 1) = 12,000円
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at) VALUES
('item-001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'P001', 2, 5000, NOW()),
('item-002', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'P002', 1, 2000, NOW());