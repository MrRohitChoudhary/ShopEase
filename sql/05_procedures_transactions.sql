-- ============================================================
--  E-COMMERCE DATABASE MANAGEMENT SYSTEM
--  Module 5: Stored Procedures & Transaction Control
-- ============================================================

USE ecommerce_db;

DELIMITER $$

-- ============================================================
-- 5.1  STORED PROCEDURES
-- ============================================================

-- -------------------------------------------------------
-- Procedure 1: Register new customer
-- -------------------------------------------------------
CREATE PROCEDURE sp_register_user(
    IN  p_full_name     VARCHAR(150),
    IN  p_email         VARCHAR(200),
    IN  p_password_hash VARCHAR(255),
    IN  p_phone         VARCHAR(15),
    OUT p_new_user_id   INT
)
BEGIN
    -- Prevent duplicate email
    IF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Email already registered.';
    END IF;

    INSERT INTO users (full_name, email, password_hash, phone, role)
    VALUES (p_full_name, p_email, p_password_hash, p_phone, 'customer');

    SET p_new_user_id = LAST_INSERT_ID();
END$$


-- -------------------------------------------------------
-- Procedure 2: Add product to cart (upsert)
-- -------------------------------------------------------
CREATE PROCEDURE sp_add_to_cart(
    IN p_user_id    INT,
    IN p_product_id INT,
    IN p_quantity   INT
)
BEGIN
    DECLARE v_stock INT;

    -- Check available stock
    SELECT stock_qty INTO v_stock
    FROM   products
    WHERE  product_id = p_product_id AND is_active = 1;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found or inactive.';
    END IF;

    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock.';
    END IF;

    -- Insert or update quantity
    INSERT INTO cart (user_id, product_id, quantity)
    VALUES (p_user_id, p_product_id, p_quantity)
    ON DUPLICATE KEY UPDATE quantity = quantity + p_quantity;

    SELECT 'Product added to cart successfully.' AS message;
END$$


-- -------------------------------------------------------
-- Procedure 3: Place order from cart (FULL TRANSACTION)
-- -------------------------------------------------------
CREATE PROCEDURE sp_place_order(
    IN  p_user_id    INT,
    IN  p_address_id INT,
    OUT p_order_id   INT
)
BEGIN
    DECLARE v_total        DECIMAL(12,2) DEFAULT 0;
    DECLARE v_product_id   INT;
    DECLARE v_quantity     INT;
    DECLARE v_price        DECIMAL(10,2);
    DECLARE v_stock        INT;
    DECLARE done           INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT c.product_id, c.quantity, p.price
        FROM   cart c
        JOIN   products p ON p.product_id = c.product_id
        WHERE  c.user_id = p_user_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Begin transaction
    START TRANSACTION;

    -- Calculate total from cart
    SELECT SUM(c.quantity * p.price)
    INTO   v_total
    FROM   cart c
    JOIN   products p ON p.product_id = c.product_id
    WHERE  c.user_id = p_user_id;

    IF v_total IS NULL OR v_total = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cart is empty.';
    END IF;

    -- Create order header
    INSERT INTO orders (user_id, address_id, total_amount, status)
    VALUES (p_user_id, p_address_id, v_total, 'pending');

    SET p_order_id = LAST_INSERT_ID();

    -- Insert order items and check stock
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_product_id, v_quantity, v_price;
        IF done THEN LEAVE read_loop; END IF;

        SELECT stock_qty INTO v_stock FROM products WHERE product_id = v_product_id;

        IF v_stock < v_quantity THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'One or more products have insufficient stock.';
        END IF;

        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (p_order_id, v_product_id, v_quantity, v_price);
        -- Stock reduction handled by trigger trg_reduce_stock_on_order
    END LOOP;
    CLOSE cur;

    -- Clear cart
    DELETE FROM cart WHERE user_id = p_user_id;

    COMMIT;
END$$


-- -------------------------------------------------------
-- Procedure 4: Process payment
-- -------------------------------------------------------
CREATE PROCEDURE sp_process_payment(
    IN  p_order_id       INT,
    IN  p_amount         DECIMAL(12,2),
    IN  p_method         VARCHAR(20),
    IN  p_txn_ref        VARCHAR(100),
    OUT p_payment_id     INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO payments (order_id, amount, method, status, transaction_ref)
    VALUES (p_order_id, p_amount, p_method, 'success', p_txn_ref);

    SET p_payment_id = LAST_INSERT_ID();

    -- Status update handled by trigger trg_confirm_order_on_payment
    -- but we force it here for COD / direct flow too
    UPDATE orders SET status = 'confirmed'
    WHERE  order_id = p_order_id AND status = 'pending';

    COMMIT;
END$$


-- -------------------------------------------------------
-- Procedure 5: Cancel order & refund stock
-- -------------------------------------------------------
CREATE PROCEDURE sp_cancel_order(
    IN p_order_id INT,
    IN p_user_id  INT
)
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
    FROM   orders
    WHERE  order_id = p_order_id AND user_id = p_user_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order not found.';
    END IF;

    IF v_status IN ('shipped','delivered') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot cancel a shipped or delivered order.';
    END IF;

    START TRANSACTION;

    UPDATE orders SET status = 'cancelled'
    WHERE  order_id = p_order_id;

    -- Mark payment as refunded (if successful payment exists)
    UPDATE payments SET status = 'refunded'
    WHERE  order_id = p_order_id AND status = 'success';

    -- Restore stock (trigger handles item deletion)
    DELETE FROM order_items WHERE order_id = p_order_id;

    COMMIT;

    SELECT 'Order cancelled and stock restored.' AS message;
END$$


-- -------------------------------------------------------
-- Procedure 6: Sales report between two dates
-- -------------------------------------------------------
CREATE PROCEDURE sp_sales_report(
    IN p_start_date DATE,
    IN p_end_date   DATE
)
BEGIN
    SELECT
        DATE(o.order_date)           AS sale_date,
        COUNT(DISTINCT o.order_id)   AS total_orders,
        SUM(oi.quantity)             AS total_items,
        SUM(oi.quantity * oi.unit_price) AS gross_revenue
    FROM orders      o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE DATE(o.order_date) BETWEEN p_start_date AND p_end_date
      AND o.status NOT IN ('cancelled', 'returned')
    GROUP BY DATE(o.order_date)
    ORDER BY sale_date;
END$$


DELIMITER ;


-- ============================================================
-- 5.2  TRANSACTION CONTROL – Standalone Examples
-- ============================================================

-- Example A: Successful transfer (simulated stock transfer)
START TRANSACTION;

    UPDATE products SET stock_qty = stock_qty - 10 WHERE product_id = 1;
    UPDATE products SET stock_qty = stock_qty + 10 WHERE product_id = 2;

COMMIT;  -- Both updates committed together

-- Example B: Rollback on error
START TRANSACTION;

    UPDATE products SET price = price * 0.9 WHERE category_id = 2;   -- 10% discount on mobiles

    -- Simulate a logic check: ensure no price drops below ₹100
    -- In a real scenario this would be a conditional
    -- ROLLBACK if condition failed, else COMMIT

ROLLBACK;   -- No change persisted (demonstration)


-- ============================================================
-- Test / Call procedures
-- ============================================================

-- Register a new user
CALL sp_register_user('Priya Singh', 'priya@gmail.com',
                      '$2a$10$sampleHash', '9876543210', @uid);
SELECT @uid AS new_user_id;

-- Add product to cart
CALL sp_add_to_cart(6, 9, 2);

-- Get sales report
CALL sp_sales_report('2024-01-01', '2024-12-31');
