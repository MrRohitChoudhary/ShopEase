-- ============================================================
--  E-COMMERCE DATABASE MANAGEMENT SYSTEM
--  Module 4: Views, Indexes & Triggers
-- ============================================================

USE ecommerce_db;

-- ============================================================
-- 4.1  VIEWS
-- ============================================================

-- View 1: Complete order summary
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    u.user_id,
    u.full_name           AS customer_name,
    u.email,
    o.order_date,
    o.total_amount,
    o.status              AS order_status,
    p.method              AS payment_method,
    p.status              AS payment_status,
    s.status              AS shipping_status,
    s.tracking_number
FROM orders   o
JOIN users    u ON u.user_id    = o.user_id
LEFT JOIN payments p ON p.order_id = o.order_id
LEFT JOIN shipping s ON s.order_id = o.order_id;


-- View 2: Product catalogue with category name and rating
CREATE OR REPLACE VIEW vw_product_catalogue AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.brand,
    p.price,
    p.stock_qty,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS avg_rating,
    COUNT(r.review_id)                   AS review_count,
    p.is_active
FROM products   p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN reviews r ON r.product_id = p.product_id
GROUP BY p.product_id;


-- View 3: Revenue & sales report per category
CREATE OR REPLACE VIEW vw_category_revenue AS
SELECT
    c.category_name,
    COUNT(DISTINCT oi.item_id)   AS total_items_sold,
    SUM(oi.quantity)             AS total_quantity,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products    p  ON p.product_id  = oi.product_id
JOIN categories  c  ON c.category_id = p.category_id
GROUP BY c.category_id;


-- View 4: Customer order history
CREATE OR REPLACE VIEW vw_customer_orders AS
SELECT
    u.full_name,
    u.email,
    o.order_id,
    o.order_date,
    GROUP_CONCAT(p.product_name SEPARATOR ' | ') AS items,
    o.total_amount,
    o.status
FROM users       u
JOIN orders      o  ON o.user_id   = u.user_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products    p  ON p.product_id = oi.product_id
GROUP BY o.order_id;


-- View 5: Low stock alert (stock < 50)
CREATE OR REPLACE VIEW vw_low_stock_alert AS
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name,
    p.stock_qty
FROM products   p
JOIN categories c ON c.category_id = p.category_id
WHERE p.stock_qty < 50 AND p.is_active = 1
ORDER BY p.stock_qty ASC;


-- Query the views
SELECT * FROM vw_order_summary;
SELECT * FROM vw_product_catalogue WHERE avg_rating >= 4;
SELECT * FROM vw_category_revenue  ORDER BY total_revenue DESC;
SELECT * FROM vw_low_stock_alert;


-- ============================================================
-- 4.2  INDEXES (Performance Optimization)
-- ============================================================

-- Index on product price (range queries)
CREATE INDEX idx_product_price    ON products(price);

-- Index on product category (JOIN performance)
CREATE INDEX idx_product_category ON products(category_id);

-- Index on order user (JOIN performance)
CREATE INDEX idx_order_user       ON orders(user_id);

-- Index on order status (filter by status)
CREATE INDEX idx_order_status     ON orders(status);

-- Index on payment status
CREATE INDEX idx_payment_status   ON payments(status);

-- Composite index for order_items (covering index for reports)
CREATE INDEX idx_oi_order_product ON order_items(order_id, product_id);

-- Full-text index for product search
CREATE FULLTEXT INDEX idx_ft_product_name ON products(product_name, description);

-- Demonstrate full-text search
SELECT product_id, product_name, price
FROM   products
WHERE  MATCH(product_name, description) AGAINST ('camera battery' IN BOOLEAN MODE);


-- ============================================================
-- 4.3  TRIGGERS
-- ============================================================

DELIMITER $$

-- Trigger 1: Reduce stock when an order item is inserted
CREATE TRIGGER trg_reduce_stock_on_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET    stock_qty = stock_qty - NEW.quantity
    WHERE  product_id = NEW.product_id;
END$$


-- Trigger 2: Restore stock when an order item is deleted (e.g., cancelled order)
CREATE TRIGGER trg_restore_stock_on_cancel
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET    stock_qty = stock_qty + OLD.quantity
    WHERE  product_id = OLD.product_id;
END$$


-- Trigger 3: Prevent inserting a review for a product not purchased by user
CREATE TRIGGER trg_verify_review_purchase
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    DECLARE purchase_count INT DEFAULT 0;
    SELECT COUNT(*) INTO purchase_count
    FROM   order_items oi
    JOIN   orders       o  ON o.order_id   = oi.order_id
    WHERE  o.user_id    = NEW.user_id
      AND  oi.product_id = NEW.product_id
      AND  o.status      = 'delivered';

    IF purchase_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Review allowed only for verified purchases.';
    ELSE
        SET NEW.is_verified = 1;
    END IF;
END$$


-- Trigger 4: Automatically update order status when payment succeeds
CREATE TRIGGER trg_confirm_order_on_payment
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    IF NEW.status = 'success' AND OLD.status != 'success' THEN
        UPDATE orders
        SET    status = 'confirmed'
        WHERE  order_id = NEW.order_id
          AND  status   = 'pending';
    END IF;
END$$


-- Trigger 5: Log order status changes (requires audit_log table)
CREATE TABLE IF NOT EXISTS order_audit_log (
    log_id      INT      NOT NULL AUTO_INCREMENT,
    order_id    INT      NOT NULL,
    old_status  VARCHAR(20),
    new_status  VARCHAR(20),
    changed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
) ENGINE=InnoDB;

CREATE TRIGGER trg_log_order_status_change
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO order_audit_log (order_id, old_status, new_status)
        VALUES (NEW.order_id, OLD.status, NEW.status);
    END IF;
END$$


DELIMITER ;
