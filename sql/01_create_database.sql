-- ============================================================
--  E-COMMERCE DATABASE MANAGEMENT SYSTEM
--  Module 1: Database & Table Creation
--  Author  : Academic Project – Final Year Diploma/Degree
--  DBMS    : MySQL 8.x
-- ============================================================

-- -------------------------------------------------------
-- Step 1: Create & select the database
-- -------------------------------------------------------
CREATE DATABASE IF NOT EXISTS ecommerce_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ecommerce_db;

-- -------------------------------------------------------
-- Step 2: Disable FK checks while creating tables
-- -------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;


-- ============================================================
-- TABLE: categories
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    category_id   INT           NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100)  NOT NULL,
    description   TEXT,
    parent_id     INT           DEFAULT NULL,                 -- self-referencing for sub-categories
    is_active     TINYINT(1)    NOT NULL DEFAULT 1,
    created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_categories     PRIMARY KEY (category_id),
    CONSTRAINT uq_category_name  UNIQUE      (category_name),
    CONSTRAINT chk_cat_active    CHECK       (is_active IN (0, 1)),
    CONSTRAINT fk_cat_parent     FOREIGN KEY (parent_id)
                                     REFERENCES categories(category_id)
                                     ON DELETE SET NULL
                                     ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Product categories (supports nested hierarchy)';


-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    user_id        INT           NOT NULL AUTO_INCREMENT,
    full_name      VARCHAR(150)  NOT NULL,
    email          VARCHAR(200)  NOT NULL,
    password_hash  VARCHAR(255)  NOT NULL,
    phone          VARCHAR(15)   DEFAULT NULL,
    role           ENUM('admin','customer') NOT NULL DEFAULT 'customer',
    is_active      TINYINT(1)    NOT NULL DEFAULT 1,
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_users        PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email   UNIQUE      (email),
    CONSTRAINT chk_user_phone  CHECK       (phone REGEXP '^[0-9+\\-() ]+$' OR phone IS NULL),
    CONSTRAINT chk_user_active CHECK       (is_active IN (0, 1))
) ENGINE=InnoDB COMMENT='Registered users: admins and customers';


-- ============================================================
-- TABLE: addresses
-- ============================================================
CREATE TABLE IF NOT EXISTS addresses (
    address_id   INT           NOT NULL AUTO_INCREMENT,
    user_id      INT           NOT NULL,
    address_line VARCHAR(255)  NOT NULL,
    city         VARCHAR(100)  NOT NULL,
    state        VARCHAR(100)  NOT NULL,
    pincode      VARCHAR(10)   NOT NULL,
    country      VARCHAR(100)  NOT NULL DEFAULT 'India',
    is_default   TINYINT(1)    NOT NULL DEFAULT 0,

    CONSTRAINT pk_addresses   PRIMARY KEY (address_id),
    CONSTRAINT fk_addr_user   FOREIGN KEY (user_id)
                                  REFERENCES users(user_id)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,
    CONSTRAINT chk_is_default CHECK (is_default IN (0, 1))
) ENGINE=InnoDB COMMENT='Shipping/billing addresses per user';


-- ============================================================
-- TABLE: products
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    product_id    INT             NOT NULL AUTO_INCREMENT,
    category_id   INT             NOT NULL,
    product_name  VARCHAR(200)    NOT NULL,
    description   TEXT,
    price         DECIMAL(10, 2)  NOT NULL,
    stock_qty     INT             NOT NULL DEFAULT 0,
    image_url     VARCHAR(500)    DEFAULT NULL,
    brand         VARCHAR(100)    DEFAULT NULL,
    is_active     TINYINT(1)      NOT NULL DEFAULT 1,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                           ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_products       PRIMARY KEY (product_id),
    CONSTRAINT fk_prod_category  FOREIGN KEY (category_id)
                                     REFERENCES categories(category_id)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT chk_prod_price    CHECK (price >= 0),
    CONSTRAINT chk_prod_stock    CHECK (stock_qty >= 0)
) ENGINE=InnoDB COMMENT='Product catalogue';


-- ============================================================
-- TABLE: cart
-- ============================================================
CREATE TABLE IF NOT EXISTS cart (
    cart_id     INT  NOT NULL AUTO_INCREMENT,
    user_id     INT  NOT NULL,
    product_id  INT  NOT NULL,
    quantity    INT  NOT NULL DEFAULT 1,
    added_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_cart          PRIMARY KEY (cart_id),
    CONSTRAINT uq_cart_item     UNIQUE      (user_id, product_id),
    CONSTRAINT fk_cart_user     FOREIGN KEY (user_id)
                                    REFERENCES users(user_id)
                                    ON DELETE CASCADE,
    CONSTRAINT fk_cart_product  FOREIGN KEY (product_id)
                                    REFERENCES products(product_id)
                                    ON DELETE CASCADE,
    CONSTRAINT chk_cart_qty     CHECK (quantity >= 1)
) ENGINE=InnoDB COMMENT='Shopping cart (one row per user-product pair)';


-- ============================================================
-- TABLE: orders
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (
    order_id       INT             NOT NULL AUTO_INCREMENT,
    user_id        INT             NOT NULL,
    address_id     INT             NOT NULL,
    order_date     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount   DECIMAL(12, 2)  NOT NULL,
    status         ENUM('pending','confirmed','shipped',
                        'delivered','cancelled','returned')
                                   NOT NULL DEFAULT 'pending',
    notes          TEXT            DEFAULT NULL,

    CONSTRAINT pk_orders        PRIMARY KEY (order_id),
    CONSTRAINT fk_order_user    FOREIGN KEY (user_id)
                                    REFERENCES users(user_id)
                                    ON DELETE RESTRICT,
    CONSTRAINT fk_order_address FOREIGN KEY (address_id)
                                    REFERENCES addresses(address_id)
                                    ON DELETE RESTRICT,
    CONSTRAINT chk_order_total  CHECK (total_amount >= 0)
) ENGINE=InnoDB COMMENT='Customer orders header';


-- ============================================================
-- TABLE: order_items
-- ============================================================
CREATE TABLE IF NOT EXISTS order_items (
    item_id      INT             NOT NULL AUTO_INCREMENT,
    order_id     INT             NOT NULL,
    product_id   INT             NOT NULL,
    quantity     INT             NOT NULL,
    unit_price   DECIMAL(10, 2)  NOT NULL,  -- price snapshot at order time

    CONSTRAINT pk_order_items      PRIMARY KEY (item_id),
    CONSTRAINT fk_oi_order         FOREIGN KEY (order_id)
                                       REFERENCES orders(order_id)
                                       ON DELETE CASCADE,
    CONSTRAINT fk_oi_product       FOREIGN KEY (product_id)
                                       REFERENCES products(product_id)
                                       ON DELETE RESTRICT,
    CONSTRAINT chk_oi_qty          CHECK (quantity >= 1),
    CONSTRAINT chk_oi_unit_price   CHECK (unit_price >= 0)
) ENGINE=InnoDB COMMENT='Line items within an order';


-- ============================================================
-- TABLE: payments
-- ============================================================
CREATE TABLE IF NOT EXISTS payments (
    payment_id      INT             NOT NULL AUTO_INCREMENT,
    order_id        INT             NOT NULL,
    payment_date    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount          DECIMAL(12, 2)  NOT NULL,
    method          ENUM('credit_card','debit_card','upi',
                         'net_banking','cod','wallet')
                                    NOT NULL,
    status          ENUM('pending','success','failed','refunded')
                                    NOT NULL DEFAULT 'pending',
    transaction_ref VARCHAR(100)    DEFAULT NULL,

    CONSTRAINT pk_payments      PRIMARY KEY (payment_id),
    CONSTRAINT fk_pay_order     FOREIGN KEY (order_id)
                                    REFERENCES orders(order_id)
                                    ON DELETE RESTRICT,
    CONSTRAINT uq_txn_ref       UNIQUE (transaction_ref),
    CONSTRAINT chk_pay_amount   CHECK (amount >= 0)
) ENGINE=InnoDB COMMENT='Payment transactions for orders';


-- ============================================================
-- TABLE: shipping
-- ============================================================
CREATE TABLE IF NOT EXISTS shipping (
    shipping_id       INT          NOT NULL AUTO_INCREMENT,
    order_id          INT          NOT NULL,
    courier_name      VARCHAR(100) NOT NULL,
    tracking_number   VARCHAR(100) DEFAULT NULL,
    shipped_date      DATE         DEFAULT NULL,
    estimated_delivery DATE        DEFAULT NULL,
    delivered_date    DATE         DEFAULT NULL,
    status            ENUM('not_shipped','in_transit',
                           'delivered','returned')
                                   NOT NULL DEFAULT 'not_shipped',

    CONSTRAINT pk_shipping      PRIMARY KEY (shipping_id),
    CONSTRAINT fk_ship_order    FOREIGN KEY (order_id)
                                    REFERENCES orders(order_id)
                                    ON DELETE CASCADE,
    CONSTRAINT uq_ship_tracking UNIQUE (tracking_number)
) ENGINE=InnoDB COMMENT='Shipping & courier tracking per order';


-- ============================================================
-- TABLE: reviews
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
    review_id    INT       NOT NULL AUTO_INCREMENT,
    product_id   INT       NOT NULL,
    user_id      INT       NOT NULL,
    rating       TINYINT   NOT NULL,
    title        VARCHAR(200) DEFAULT NULL,
    body         TEXT      DEFAULT NULL,
    created_at   DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_verified  TINYINT(1) NOT NULL DEFAULT 0,  -- verified purchase flag

    CONSTRAINT pk_reviews        PRIMARY KEY (review_id),
    CONSTRAINT uq_review_once    UNIQUE      (product_id, user_id),
    CONSTRAINT fk_rev_product    FOREIGN KEY (product_id)
                                     REFERENCES products(product_id)
                                     ON DELETE CASCADE,
    CONSTRAINT fk_rev_user       FOREIGN KEY (user_id)
                                     REFERENCES users(user_id)
                                     ON DELETE CASCADE,
    CONSTRAINT chk_rating_range  CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB COMMENT='Customer product reviews and ratings';


-- -------------------------------------------------------
-- Re-enable FK checks
-- -------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 1;
