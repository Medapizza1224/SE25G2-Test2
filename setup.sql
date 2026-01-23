SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS restaurant_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE restaurant_db;

-- ==========================================
-- 1. テーブル削除
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
DROP TABLE IF EXISTS pending_users;
DROP TABLE IF EXISTS terminal_settings_admins;

-- ==========================================
-- 2. テーブル作成
-- ==========================================

-- [Users] 修正: IDはUUID、Nameにメールアドレス
CREATE TABLE users (
    user_id CHAR(36) PRIMARY KEY,    -- UUID
    user_name VARCHAR(255) NOT NULL, -- メールアドレス
    user_password VARCHAR(255) NOT NULL,
    security_code VARCHAR(255) NOT NULL,
    balance INT DEFAULT 0,
    point INT DEFAULT 0,
    login_attempt_count INT DEFAULT 0,
    is_lockout BOOLEAN DEFAULT FALSE,
    encrypted_private_key TEXT,
    public_key TEXT
);

CREATE TABLE admins (
    admin_name VARCHAR(32) PRIMARY KEY, 
    admin_password VARCHAR(255)
);

CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY, 
    product_name VARCHAR(64), 
    image VARCHAR(255), 
    category VARCHAR(32), 
    price INT, 
    sales_status VARCHAR(32), 
    update_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id CHAR(36) PRIMARY KEY, 
    table_number CHAR(4), 
    adult_count INT, 
    child_count INT, 
    is_payment_completed BOOLEAN DEFAULT FALSE, 
    visit_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

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

CREATE TABLE payments (
    order_id CHAR(36) PRIMARY KEY, 
    user_id CHAR(36), -- UUID
    used_points INT DEFAULT 0, 
    earned_points INT DEFAULT 0, 
    payment_completed_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE ledger (
    height INT AUTO_INCREMENT PRIMARY KEY,
    prev_hash VARCHAR(64) NOT NULL,
    curr_hash VARCHAR(64) NOT NULL,
    sender_id CHAR(36) NOT NULL, -- UUID
    amount INT NOT NULL,
    signature TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE analysis (
    analysis_date DATE NOT NULL,
    product_id VARCHAR(32) NOT NULL,
    count_single INT DEFAULT 0,
    count_pair INT DEFAULT 0,
    count_family INT DEFAULT 0,
    count_adult_group INT DEFAULT 0,
    count_group INT DEFAULT 0,
    PRIMARY KEY (analysis_date, product_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 一時保存用テーブルの作成
CREATE TABLE pending_users (
    token VARCHAR(64) PRIMARY KEY,      -- メール認証用トークン
    user_id CHAR(36) NOT NULL,          -- UUID
    user_name VARCHAR(255) NOT NULL,    -- メールアドレス
    user_password VARCHAR(255) NOT NULL,-- パスワード（ハッシュ済み想定）
    security_code VARCHAR(255) NOT NULL,-- セキュリティコード
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP -- 有効期限チェック用
);

-- setup.sql に追加
CREATE TABLE terminal_settings_admins (
    id VARCHAR(32) PRIMARY KEY,
    password VARCHAR(255)
);


-- ==========================================
-- 3. データ投入
-- ==========================================

-- [Admins]
INSERT INTO admins VALUES ('admin', '1234');

-- [Ledger] Genesis
INSERT INTO ledger (prev_hash, curr_hash, sender_id, amount, signature)
VALUES ('0', 'GENESIS', 'SYSTEM', 0, 'SIG');


-- [Products] 各カテゴリ20個 (画像ランダム)
-- 肉カテゴリ (20個)
INSERT INTO products (product_id, product_name, category, price, image, sales_status) VALUES
('MEAT001', '和牛上カルビ', '肉', 1280, '和牛上カルビ.png', '販売中'),
('MEAT002', '熟成ハラミ', '肉', 980, '熟成ハラミ.png', '販売中'),
('MEAT003', 'ネギ塩タン', '肉', 1380, 'ネギ塩タン.png', '販売中'),
('MEAT004', 'ロース', '肉', 880, 'ロース.png', '販売中'),
('MEAT005', '豚トロ', '肉', 680, '豚トロ.png', '販売中'),
('MEAT006', 'サーロイン', '肉', 2480, 'サーロイン.png', '販売中'),
('MEAT007', '厚切りタン', '肉', 1680, '厚切りタン.png', '販売中'),
('MEAT008', '中落ちカルビ', '肉', 780, '中落ちカルビ.png', '販売中'),
('MEAT009', '壺漬けカルビ', '肉', 980, '壺漬けカルビ.png', '販売中'),
('MEAT010', 'カイノミ', '肉', 1180, 'カイノミ.png', '販売中'),
('MEAT011', 'ミスジ', '肉', 1480, 'ミスジ.png', '販売中'),
('MEAT012', 'イチボ', '肉', 1380, 'イチボ.png', '販売中'),
('MEAT013', 'ザブトン', '肉', 1980, 'ザブトン.png', '販売中'),
('MEAT014', '三角バラ', '肉', 1580, '三角バラ.png', '販売中'),
('MEAT015', '国産豚バラ', '肉', 580, '国産豚バラ.png', '販売中'),
('MEAT016', '桜姫鶏モモ', '肉', 480, '桜姫鶏モモ.png', '販売中'),
('MEAT017', '鶏セセリ', '肉', 520, '鶏セセリ.png', '販売中'),
('MEAT018', 'サムギョプサル', '肉', 1280, 'サムギョプサル.png', '販売中'),
('MEAT019', 'カルビ', '肉', 580, 'カルビ.png', '販売中'),
('MEAT020', 'ファミリー盛り', '肉', 3980, 'ファミリー盛り.png', '販売中');

-- ホルモンカテゴリ (20個)
INSERT INTO products (product_id, product_name, category, price, image, sales_status) VALUES
('HRMN001', 'シマチョウ', 'ホルモン', 680, 'シマチョウ.png', '販売中'),
('HRMN002', '上ミノ', 'ホルモン', 880, '上ミノ.png', '販売中'),
('HRMN003', 'レバー', 'ホルモン', 580, 'レバー.png', '販売中'),
('HRMN004', 'マルチョウ', 'ホルモン', 680, 'マルチョウ.png', '販売中'),
('HRMN005', 'ハツ', 'ホルモン', 580, 'ハツ.png', '販売中'),
('HRMN006', 'センマイ', 'ホルモン', 680, 'センマイ.png', '販売中'),
('HRMN007', 'ギアラ', 'ホルモン', 580, 'ギアラ.png', '販売中'),
('HRMN008', 'コブクロ', 'ホルモン', 480, 'コブクロ.png', '販売中'),
('HRMN009', 'テッポウ', 'ホルモン', 480, 'テッポウ.png', '販売中'),
('HRMN010', 'ガツ', 'ホルモン', 480, 'ガツ.png', '販売中'),
('HRMN011', 'ハチノス', 'ホルモン', 580, 'ハチノス.png', '販売中'),
('HRMN012', 'ウルテ', 'ホルモン', 680, 'ウルテ.png', '販売中'),
('HRMN013', 'シビレ', 'ホルモン', 780, 'シビレ.png', '販売中'),
('HRMN014', 'マメ', 'ホルモン', 480, 'マメ.png', '販売中'),
('HRMN015', 'フワ', 'ホルモン', 480, 'フワ.png', '販売中'),
('HRMN016', 'チレ', 'ホルモン', 480, 'チレ.png', '販売中'),
('HRMN017', 'ノドブエ', 'ホルモン', 580, 'ノドブエ.png', '販売中'),
('HRMN018', 'コリコリ', 'ホルモン', 580, 'コリコリ.png', '販売中'),
('HRMN019', 'ハツモト', 'ホルモン', 680, 'ハツモト.png', '販売中'),
('HRMN020', 'ホルモン5種', 'ホルモン', 1580, 'ホルモン5種.png', '販売中');

-- サイドカテゴリ (20個)
INSERT INTO products (product_id, product_name, category, price, image, sales_status) VALUES
('SIDE001', 'チョレギサラダ', 'サイド', 680, 'チョレギサラダ.png', '販売中'),
('SIDE002', '石焼ビビンバ', 'サイド', 980, '石焼ビビンバ.png', '販売中'),
('SIDE003', '冷麺', 'サイド', 880, '冷麺.png', '販売中'),
('SIDE004', 'キムチ', 'サイド', 480, 'キムチ.png', '販売中'),
('SIDE005', 'ナムル', 'サイド', 580, 'ナムル.png', '販売中'),
('SIDE006', 'わかめスープ', 'サイド', 450, 'わかめスープ.png', '販売中'),
('SIDE007', 'ライス(中)', 'サイド', 250, 'ライス(中).png', '販売中'),
('SIDE008', 'ライス(大)', 'サイド', 350, 'ライス(大).png', '販売中'),
('SIDE009', 'ユッケジャン', 'サイド', 780, 'ユッケジャン.png', '販売中'),
('SIDE010', 'たまごスープ', 'サイド', 450, 'たまごスープ.png', '販売中'),
('SIDE011', 'カクテキ', 'サイド', 480, 'カクテキ.png', '販売中'),
('SIDE012', 'オイキムチ', 'サイド', 480, 'オイキムチ.png', '販売中'),
('SIDE013', 'サンチュ', 'サイド', 380, 'サンチュ.png', '販売中'),
('SIDE014', 'シーザーサラダ', 'サイド', 780, 'シーザーサラダ.png', '販売中'),
('SIDE015', 'ポテトサラダ', 'サイド', 480, 'ポテトサラダ.png', '販売中'),
('SIDE016', 'クッパ', 'サイド', 780, 'クッパ.png', '販売中'),
('SIDE017', 'チヂミ', 'サイド', 880, 'チヂミ.png', '販売中'),
('SIDE018', '韓国海苔', 'サイド', 200, '韓国海苔.png', '販売中'),
('SIDE019', 'チャンジャ', 'サイド', 480, 'チャンジャ.png', '販売中'),
('SIDE020', 'アイス', 'サイド', 350, 'アイス.png', '販売中');

-- ドリンクカテゴリ (20個)
INSERT INTO products (product_id, product_name, category, price, image, sales_status) VALUES
('DRNK001', '生ビール', 'ドリンク', 550, '生ビール.png', '販売中'),
('DRNK002', 'ハイボール', 'ドリンク', 450, 'ハイボール.png', '販売中'),
('DRNK003', 'レモンサワー', 'ドリンク', 450, 'レモンサワー.png', '販売中'),
('DRNK004', '赤ワイン', 'ドリンク', 600, '赤ワイン.png', '販売中'),
('DRNK005', 'ウーロン茶', 'ドリンク', 300, 'ウーロン茶.png', '販売中'),
('DRNK006', 'コーラ', 'ドリンク', 300, 'コーラ.png', '販売中'),
('DRNK007', 'オレンジ', 'ドリンク', 300, 'オレンジ.png', '販売中'),
('DRNK008', 'ジンジャー', 'ドリンク', 300, 'ジンジャー.png', '販売中'),
('DRNK009', '緑茶', 'ドリンク', 300, '緑茶.png', '販売中'),
('DRNK010', '黒ウーロン', 'ドリンク', 400, '黒ウーロン.png', '販売中'),
('DRNK011', '瓶ビール', 'ドリンク', 650, '瓶ビール.png', '販売中'),
('DRNK012', 'ウーロンハイ', 'ドリンク', 450, 'ウーロンハイ.png', '販売中'),
('DRNK013', '緑茶ハイ', 'ドリンク', 450, '緑茶ハイ.png', '販売中'),
('DRNK014', 'カシス', 'ドリンク', 500, 'カシス.png', '販売中'),
('DRNK015', 'ファジー', 'ドリンク', 500, 'ファジー.png', '販売中'),
('DRNK016', '梅酒', 'ドリンク', 500, '梅酒.png', '販売中'),
('DRNK017', '麦焼酎', 'ドリンク', 500, '麦焼酎.png', '販売中'),
('DRNK018', '芋焼酎', 'ドリンク', 500, '芋焼酎.png', '販売中'),
('DRNK019', '日本酒', 'ドリンク', 700, '日本酒.png', '販売中'),
('DRNK020', 'マッコリ', 'ドリンク', 1200, 'マッコリ.png', '販売中');

-- [Analysis] 過去7日分 × 全商品(80個) のダミーデータ生成
-- プロシージャを使ってループ処理
DELIMITER //
CREATE PROCEDURE generate_analysis_data()
BEGIN
    DECLARE i INT DEFAULT 0;
    -- 0日前(今日)から6日前まで
    WHILE i < 7 DO
        INSERT INTO analysis (analysis_date, product_id, count_single, count_pair, count_family, count_adult_group, count_group)
        SELECT 
            CURRENT_DATE - INTERVAL i DAY,
            product_id,
            FLOOR(RAND() * 20),
            FLOOR(RAND() * 20),
            FLOOR(RAND() * 20),
            FLOOR(RAND() * 20),
            FLOOR(RAND() * 20)
        FROM products;
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;
CALL generate_analysis_data();
DROP PROCEDURE generate_analysis_data;

-- [Orders] ランダムに5つ
INSERT INTO orders (order_id, table_number, adult_count, child_count, is_payment_completed, visit_at) VALUES
(UUID(), '0010', 2, 0, FALSE, NOW()),
(UUID(), '0005', 4, 1, FALSE, NOW()),
(UUID(), '0012', 1, 0, TRUE, NOW() - INTERVAL 1 HOUR),
(UUID(), '0003', 2, 2, FALSE, NOW()),
(UUID(), '0008', 3, 0, TRUE, NOW() - INTERVAL 2 HOUR);

-- [OrderItems] 上記Orderに対して適当に10個割り当て
-- ※単純化のため、サブクエリで適当なOrderとProductを紐づける
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'MEAT001', 2, 1280, NOW(), '調理中' FROM orders LIMIT 1;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'DRNK001', 4, 550, NOW(), '調理中' FROM orders LIMIT 1 OFFSET 1;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'SIDE007', 3, 250, NOW(), '提供済' FROM orders LIMIT 1 OFFSET 2;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'MEAT003', 1, 1380, NOW(), '調理中' FROM orders LIMIT 1 OFFSET 3;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'HRMN001', 5, 680, NOW(), '提供済' FROM orders LIMIT 1 OFFSET 4;

-- 残り5個をランダムなOrderへ
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'MEAT020', 1, 3980, NOW(), '調理中' FROM orders ORDER BY RAND() LIMIT 1;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'DRNK010', 2, 400, NOW(), '調理中' FROM orders ORDER BY RAND() LIMIT 1;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'SIDE004', 3, 480, NOW(), '提供済' FROM orders ORDER BY RAND() LIMIT 1;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'MEAT010', 2, 1180, NOW(), '調理中' FROM orders ORDER BY RAND() LIMIT 1;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status)
SELECT UUID(), order_id, 'DRNK003', 1, 450, NOW(), '調理中' FROM orders ORDER BY RAND() LIMIT 1;

-- 注文端末設定専用のパスワード（管理画面用とは別にする）
INSERT INTO terminal_settings_admins VALUES ('order', '1234');

SET FOREIGN_KEY_CHECKS = 1;