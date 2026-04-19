-- ============================================================
--  E-COMMERCE DATABASE MANAGEMENT SYSTEM
--  Module 2: Sample / Seed Data
--  DBMS: MySQL 8.x
-- ============================================================

USE ecommerce_db;

-- -------------------------------------------------------
-- Categories
-- -------------------------------------------------------
INSERT INTO categories (category_id, category_name, description, parent_id) VALUES
(1,  'Electronics',        'All electronic gadgets and devices',          NULL),
(2,  'Mobiles',            'Smartphones and accessories',                 1),
(3,  'Laptops',            'Laptops and notebooks',                       1),
(4,  'Fashion',            'Clothing, footwear and accessories',          NULL),
(5,  'Men\'s Clothing',    'Shirts, trousers, t-shirts for men',          4),
(6,  'Women\'s Clothing',  'Kurtas, sarees, tops for women',              4),
(7,  'Home & Kitchen',     'Furniture, appliances and décor',             NULL),
(8,  'Kitchen Appliances', 'Mixers, ovens, refrigerators etc.',           7),
(9,  'Books',              'Fiction, non-fiction, academic books',        NULL),
(10, 'Sports & Fitness',   'Gym equipment, sportswear and accessories',   NULL);


-- -------------------------------------------------------
-- Users  (passwords are bcrypt hashes – stored as demo)
-- -------------------------------------------------------
INSERT INTO users (user_id, full_name, email, password_hash, phone, role) VALUES
(1, 'Admin User',       'admin@ecommerce.com',   '$2a$10$adminHashDemoXXXXXXXXXX', '9000000001', 'admin'),
(2, 'Riya Sharma',      'riya@gmail.com',        '$2a$10$hashRiyaXXXXXXXXXXXXXX', '9812345678', 'customer'),
(3, 'Arjun Patel',      'arjun@gmail.com',       '$2a$10$hashArjunXXXXXXXXXXXXX', '9823456789', 'customer'),
(4, 'Sneha Verma',      'sneha@gmail.com',       '$2a$10$hashSnehaXXXXXXXXXXXXX', '9834567890', 'customer'),
(5, 'Karan Mehta',      'karan@gmail.com',       '$2a$10$hashKaranXXXXXXXXXXXXX', '9845678901', 'customer');


-- -------------------------------------------------------
-- Addresses
-- -------------------------------------------------------
INSERT INTO addresses (address_id, user_id, address_line, city, state, pincode, country, is_default) VALUES
(1, 2, '101 MG Road, Near City Mall',    'Pune',      'Maharashtra', '411001', 'India', 1),
(2, 3, '45 Gandhi Nagar, Sector 5',      'Ahmedabad', 'Gujarat',     '380001', 'India', 1),
(3, 4, '12 Anna Salai, T-Nagar',         'Chennai',   'Tamil Nadu',  '600017', 'India', 1),
(4, 5, '88 Connaught Place, Block C',    'New Delhi', 'Delhi',       '110001', 'India', 1),
(5, 2, '207 Koregaon Park',              'Pune',      'Maharashtra', '411036', 'India', 0);


-- -------------------------------------------------------
-- Products
-- -------------------------------------------------------
INSERT INTO products (product_id, category_id, product_name, description, price, stock_qty, brand) VALUES
(1,  2,  'Samsung Galaxy A54',      '5G smartphone with 50MP camera',                   28999.00,  150, 'Samsung'),
(2,  2,  'Redmi Note 13 Pro',       '200MP camera, AMOLED display, 5000mAh battery',   22999.00,  200, 'Redmi'),
(3,  3,  'HP Pavilion 15',          'Intel i5 12th Gen, 16GB RAM, 512GB SSD',          62990.00,   80, 'HP'),
(4,  3,  'Lenovo IdeaPad 5',        'AMD Ryzen 5, 8GB RAM, 256GB SSD, FHD Display',    54999.00,   60, 'Lenovo'),
(5,  5,  'Peter England Formal Shirt','100% cotton slim fit formal shirt',               1299.00,  300, 'Peter England'),
(6,  6,  'Biba Ethnic Kurta',       'Cotton printed ethnic kurta for women',            1799.00,  250, 'Biba'),
(7,  8,  'Prestige Induction Cooktop','2000W, 8 preset menus, auto-off safety',         3999.00,  120, 'Prestige'),
(8,  9,  'Let Us C – Yashavant Kanetkar','Best-seller C programming book',               499.00,  500, 'BPB Publications'),
(9,  10, 'Cosco Football',          'Size 5, PU leather, official match ball',           899.00,  180, 'Cosco'),
(10, 2,  'boAt Airdopes 141',       'Bluetooth 5.1 TWS earbuds, 42hr playtime',        1299.00,  400, 'boAt');


-- -------------------------------------------------------
-- Cart (active sessions at time of data load)
-- -------------------------------------------------------
INSERT INTO cart (cart_id, user_id, product_id, quantity) VALUES
(1, 2,  1, 1),
(2, 2,  8, 2),
(3, 3,  3, 1),
(4, 4, 10, 2),
(5, 5,  7, 1);


-- -------------------------------------------------------
-- Orders
-- -------------------------------------------------------
INSERT INTO orders (order_id, user_id, address_id, total_amount, status) VALUES
(1, 2, 1, 29498.00,  'delivered'),
(2, 3, 2, 62990.00,  'shipped'),
(3, 4, 3,  3598.00,  'confirmed'),
(4, 5, 4, 23898.00,  'pending'),
(5, 2, 1,  1299.00,  'delivered');


-- -------------------------------------------------------
-- Order Items
-- -------------------------------------------------------
INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1,  1, 1, 28999.00),   -- Riya bought Samsung
(2, 1,  8, 1,   499.00),   -- + Let Us C book
(3, 2,  3, 1, 62990.00),   -- Arjun bought HP Laptop
(4, 3, 10, 2,  1299.00),   -- Sneha bought 2 boAt earbuds
(5, 3,  9, 1,   899.00),   -- + football … wait, let's keep 3598
(6, 4,  2, 1, 22999.00),   -- Karan bought Redmi
(7, 4,  6, 1,   899.00),
(8, 5,  5, 1,  1299.00);   -- Riya bought shirt


-- -------------------------------------------------------
-- Payments
-- -------------------------------------------------------
INSERT INTO payments (payment_id, order_id, amount, method, status, transaction_ref) VALUES
(1, 1, 29498.00, 'upi',         'success', 'UPI20240101001'),
(2, 2, 62990.00, 'credit_card', 'success', 'CC20240102001'),
(3, 3,  3598.00, 'net_banking', 'success', 'NB20240103001'),
(4, 4, 23898.00, 'cod',         'pending',  NULL),
(5, 5,  1299.00, 'wallet',      'success', 'WL20240105001');


-- -------------------------------------------------------
-- Shipping
-- -------------------------------------------------------
INSERT INTO shipping (shipping_id, order_id, courier_name, tracking_number,
                      shipped_date, estimated_delivery, delivered_date, status) VALUES
(1, 1, 'BlueDart',   'BD1234567890', '2024-01-02', '2024-01-05', '2024-01-04', 'delivered'),
(2, 2, 'Delhivery',  'DL9876543210', '2024-01-03', '2024-01-07', NULL,         'in_transit'),
(3, 3, 'DTDC',       'DTDC5566778',  NULL,         NULL,          NULL,         'not_shipped'),
(4, 4, 'Speed Post', NULL,           NULL,         NULL,          NULL,         'not_shipped'),
(5, 5, 'Ekart',      'EK1122334455', '2024-01-05', '2024-01-08', '2024-01-07', 'delivered');


-- -------------------------------------------------------
-- Reviews
-- -------------------------------------------------------
INSERT INTO reviews (review_id, product_id, user_id, rating, title, body, is_verified) VALUES
(1, 1, 2, 5, 'Excellent Phone!',        'Amazing camera quality and battery life. Worth every rupee!', 1),
(2, 3, 3, 4, 'Good laptop for the price','Runs smoothly. Fan noise could be better. Good for college use.', 1),
(3, 5, 2, 4, 'Nice quality shirt',       'Good fabric and fitting. Colour is exactly as shown.',          1),
(4, 8, 4, 5, 'Best C book ever!',        'This book helped me crack my university exam. Must read.',       0),
(5, 7, 5, 3, 'Average product',          'Works fine but the display buttons feel cheap.',                1);
