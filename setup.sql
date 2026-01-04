SET NAMES utf8mb4;
-- もしDBがまだ作られていなければ、作成時に指定する
CREATE DATABASE IF NOT EXISTS restaurant_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE restaurant_db;

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

-- 3. 注文明細 (★IDをUUID形式に変更)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at) VALUES
('00000000-0000-0000-0000-000000000001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'P001', 2, 5000, NOW()),
('00000000-0000-0000-0000-000000000002', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'P002', 1, 2000, NOW());

-- ==========================================
-- D. 追加商品データ（アプリのカテゴリ表示用）
-- ==========================================

-- カテゴリ: 肉
INSERT INTO products (product_id, product_name, image, category, price, sales_status) VALUES 
('MEAT001', '和牛上カルビ', 'kalbi.jpg', '肉', 1280, '販売中'),
('MEAT002', '熟成ハラミ', 'harami.jpg', '肉', 980, '販売中'),
('MEAT003', 'ネギ塩タン', 'tan.jpg', '肉', 1380, '販売中'),
('MEAT004', 'ロース', 'roast.jpg', '肉', 880, '販売中'),
('MEAT005', '豚トロ', 'tontoro.jpg', '肉', 680, '販売中'),
('MEAT006', '黒毛和牛サーロイン', 'sirloin.jpg', '肉', 2480, '販売中'),
('MEAT007', '厚切り上タン塩', 'thick_tan.jpg', '肉', 1680, '販売中'),
('MEAT008', '中落ちカルビ', 'nakaochi.jpg', '肉', 780, '販売中'),
('MEAT009', '壺漬けカルビ', 'tsubo_kalbi.jpg', '肉', 980, '販売中'),
('MEAT010', 'カイノミ', 'kainomi.jpg', '肉', 1180, '販売中'),
('MEAT011', 'ミスジ', 'misuji.jpg', '肉', 1480, '販売中'),
('MEAT012', 'イチボ', 'ichibo.jpg', '肉', 1380, '販売中'),
('MEAT013', 'ザブトン', 'zabuton.jpg', '肉', 1980, '販売中'),
('MEAT014', '三角バラ', 'sankaku.jpg', '肉', 1580, '販売中'),
('MEAT015', '国産豚バラ', 'butabara.jpg', '肉', 580, '販売中'),
('MEAT016', '桜姫鶏モモ', 'torimomo.jpg', '肉', 480, '販売中'),
('MEAT017', '鶏セセリ', 'seseri.jpg', '肉', 520, '販売中'),
('MEAT018', 'サムギョプサルセット', 'samgyeopsal.jpg', '肉', 1280, '販売中'),
('MEAT019', '和牛3種盛り合わせ', 'wagyu_set.jpg', '肉', 2980, '販売中'),
('MEAT020', 'ファミリー盛り(4人前)', 'family_set.jpg', '肉', 3980, '販売中');

-- カテゴリ: ホルモン
INSERT INTO products (product_id, product_name, image, category, price, sales_status) VALUES 
('HRMN001', 'シマチョウ', 'shimacho.jpg', 'ホルモン', 680, '販売中'),
('HRMN002', '上ミノ', 'mino.jpg', 'ホルモン', 880, '販売中'),
('HRMN003', '牛レバー', 'liver.jpg', 'ホルモン', 580, '販売中'),
('HRMN004', 'マルチョウ', 'marucho.jpg', 'ホルモン', 680, '販売中');

-- カテゴリ: サイド (サラダ・ご飯もの含む)
INSERT INTO products (product_id, product_name, image, category, price, sales_status) VALUES 
('SIDE001', 'チョレギサラダ', 'salad.jpg', 'サイド', 680, '販売中'),
('SIDE002', '石焼ビビンバ', 'bibimba.jpg', 'サイド', 980, '販売中'),
('SIDE003', '冷麺', 'reimen.jpg', 'サイド', 880, '販売中'),
('SIDE004', '白菜キムチ', 'kimchi.jpg', 'サイド', 480, '販売中'),
('SIDE005', 'ナムル盛り合わせ', 'namul.jpg', 'サイド', 580, '販売中'),
('SIDE006', 'わかめスープ', 'soup.jpg', 'サイド', 450, '販売中'),
('SIDE007', 'ライス(中)', 'rice.jpg', 'サイド', 250, '販売中');

-- カテゴリ: ドリンク (飲み物)
INSERT INTO products (product_id, product_name, image, category, price, sales_status) VALUES 
('DRNK001', '生ビール(中)', 'beer.jpg', 'ドリンク', 550, '販売中'),
('DRNK002', 'ハイボール', 'highball.jpg', 'ドリンク', 450, '販売中'),
('DRNK003', 'レモンサワー', 'sour.jpg', 'ドリンク', 450, '販売中'),
('DRNK004', '赤ワイン(グラス)', 'wine_red.jpg', 'ドリンク', 600, '販売中'),
('DRNK005', 'ウーロン茶', 'oolong.jpg', 'ドリンク', 300, '販売中'),
('DRNK006', 'コーラ', 'cola.jpg', 'ドリンク', 300, '販売中'),
('DRNK007', 'オレンジジュース', 'orange.jpg', 'ドリンク', 300, '販売中');

-- ==========================================
-- E. 管理者アカウント (ログイン用)
-- ==========================================
-- AdminLoginServletの固定値認証に対応
INSERT INTO admins (admin_name, admin_password) VALUES ('admin', '1234');


-- ==========================================
-- F. 注文集計テーブルの初期化 (分析機能用)
-- ==========================================
-- 商品登録時に本来は行われますが、初期データ分を手動で登録しておきます。
-- これがないと分析画面でエラーになるか、データが表示されません。

INSERT INTO order_counts (product_id, order_count_from_single_adult, order_count_from_two_adults, order_count_from_family_group, order_count_from_adult_group, order_count_from_group) VALUES 
-- 既存・テスト系
('P001', 5, 2, 1, 0, 0),
('P002', 3, 1, 0, 0, 0),
('P003', 10, 5, 0, 8, 2),
('PROD005', 1, 0, 2, 0, 0),
-- 肉
('MEAT001', 12, 8, 5, 3, 1), -- 和牛上カルビ（人気No.1想定）
('MEAT002', 8, 6, 4, 2, 1),
('MEAT003', 10, 4, 2, 1, 0),
('MEAT004', 5, 3, 1, 0, 0),
('MEAT005', 4, 2, 0, 0, 0),
('MEAT006', 2, 1, 0, 1, 0),
-- ホルモン
('HRMN001', 3, 2, 0, 1, 0),
('HRMN002', 4, 1, 0, 0, 0),
('HRMN003', 2, 0, 0, 0, 0),
('HRMN004', 3, 1, 0, 0, 0),
-- サイド
('SIDE001', 8, 5, 3, 2, 0),
('SIDE002', 6, 4, 2, 1, 0),
('SIDE003', 5, 3, 1, 0, 0),
('SIDE004', 15, 10, 5, 5, 2), -- キムチ（注文数多い想定）
('SIDE005', 4, 2, 1, 0, 0),
('SIDE006', 3, 1, 2, 0, 0),
('SIDE007', 20, 15, 10, 5, 5), -- ライス
-- ドリンク
('DRNK001', 30, 20, 5, 15, 10), -- 生ビール（圧倒的人気）
('DRNK002', 15, 10, 2, 5, 2),
('DRNK003', 10, 8, 1, 3, 1),
('DRNK004', 2, 2, 0, 1, 0),
('DRNK005', 5, 3, 2, 1, 0),
('DRNK006', 4, 2, 5, 0, 1),
('DRNK007', 3, 1, 4, 0, 0);


-- ==========================================
-- G. テスト用：キッチンモニター表示データ
-- ==========================================
-- 「未提供（調理中）」の注文データを作成して、
-- キッチン画面を開いたときにカードが表示されるようにします。

-- 注文ヘッダ (テーブル5番)
-- ★IDをUUID形式に変更 (5555...)
INSERT INTO orders (order_id, table_number, adult_count, child_count, is_payment_completed, visit_at)
VALUES ('55555555-5555-5555-5555-555555555555', '5', 2, 0, FALSE, NOW());

-- 注文明細 (テーブル5番の注文)
-- ★明細IDをUUID形式に変更
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status) VALUES
('55555555-5555-5555-5555-000000000001', '55555555-5555-5555-5555-555555555555', 'MEAT001', 2, 1280, NOW(), '調理中'), -- 和牛上カルビ
('55555555-5555-5555-5555-000000000002', '55555555-5555-5555-5555-555555555555', 'DRNK001', 2, 550,  NOW(), '調理中'), -- 生ビール
('55555555-5555-5555-5555-000000000003', '55555555-5555-5555-5555-555555555555', 'SIDE004', 1, 480,  NOW(), '調理中'); -- 白菜キムチ


-- 注文ヘッダ (テーブル12番)
-- ★IDをUUID形式に変更 (1212...)
INSERT INTO orders (order_id, table_number, adult_count, child_count, is_payment_completed, visit_at)
VALUES ('12121212-1212-1212-1212-121212121212', '12', 2, 2, FALSE, NOW());

-- 注文明細 (テーブル12番の注文)
-- ★明細IDをUUID形式に変更
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price, add_order_at, order_status) VALUES
('12121212-1212-1212-1212-000000000004', '12121212-1212-1212-1212-121212121212', 'SIDE007', 4, 250, DATE_SUB(NOW(), INTERVAL 5 MINUTE), '調理中'), -- ライス
('12121212-1212-1212-1212-000000000005', '12121212-1212-1212-1212-121212121212', 'MEAT003', 2, 1380, DATE_SUB(NOW(), INTERVAL 5 MINUTE), '調理中'); -- ネギ塩タン

USE restaurant_db;

-- データ投入（名前をメアド形式、残高50万以下、必須項目のみ）
INSERT INTO users (user_id, user_name, user_password, security_code, balance, point, login_attempt_count, is_lockout, encrypted_private_key, public_key) VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'user0001@gmail.com', 'pass1', 'sec1',  50000,  100, 0, FALSE, 'priv1', 'pub1'),
('660e8400-e29b-41d4-a716-446655440002', 'user0002@gmail.com', 'pass2', 'sec2',   2000,   50, 3, TRUE,  'priv2', 'pub2'),
('770e8400-e29b-41d4-a716-446655440003', 'user0003@gmail.com', 'pass3', 'sec3', 500000, 5000, 0, FALSE, 'priv3', 'pub3');