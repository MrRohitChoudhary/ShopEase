-- ============================================================
--  E-COMMERCE DATABASE MANAGEMENT SYSTEM
--  Module 3: SELECT Queries – Beginner to Advanced
--  Covers: WHERE, ORDER BY, GROUP BY, HAVING, JOINs,
--          Subqueries, Aggregates
-- ============================================================

USE ecommerce_db;

-- ============================================================
-- 3.1  Basic SELECT & WHERE
-- ============================================================

-- All active products
SELECT product_id, product_name, price, stock_qty
FROM   products
WHERE  is_active = 1
ORDER BY price ASC;

-- Products cheaper than ₹5,000
SELECT product_name, brand, price
FROM   products
WHERE  price < 5000
ORDER BY price;

-- Search product by name (LIKE)
SELECT product_id, product_name, price
FROM   products
WHERE  product_name LIKE '%phone%' OR product_name LIKE '%Galaxy%';

-- Customer list registered in 2024
SELECT user_id, full_name, email, created_at
FROM   users
WHERE  role = 'customer'
  AND  YEAR(created_at) = 2024
ORDER BY full_name;


-- ============================================================
-- 3.2  Aggregate Functions
-- ============================================================

-- Total number of products per category
SELECT c.category_name,
       COUNT(p.product_id) AS total_products,
       MIN(p.price)        AS min_price,
       MAX(p.price)        AS max_price,
       ROUND(AVG(p.price), 2)  AS avg_price
FROM   categories c
LEFT JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC;

-- Total revenue from successful payments
SELECT SUM(amount) AS total_revenue
FROM   payments
WHERE  status = 'success';

-- Count of orders by status
SELECT status,
       COUNT(*) AS order_count,
       SUM(total_amount) AS revenue
FROM   orders
GROUP BY status;


-- ============================================================
-- 3.3  GROUP BY + HAVING
-- ============================================================

-- Categories that have MORE than 2 products
SELECT c.category_name, COUNT(p.product_id) AS total
FROM   categories c
JOIN   products   p ON p.category_id = c.category_id
GROUP BY c.category_id
HAVING total > 2;

-- Users who placed more than 1 order
SELECT u.full_name,
       COUNT(o.order_id) AS order_count,
       SUM(o.total_amount) AS total_spent
FROM   users  u
JOIN   orders o ON o.user_id = u.user_id
GROUP BY u.user_id
HAVING order_count > 1;

-- Products with average rating above 4
SELECT p.product_name,
       ROUND(AVG(r.rating), 2) AS avg_rating,
       COUNT(r.review_id)      AS review_count
FROM   products p
JOIN   reviews  r ON r.product_id = p.product_id
GROUP BY p.product_id
HAVING avg_rating >= 4
ORDER BY avg_rating DESC;


-- ============================================================
-- 3.4  INNER JOIN
-- ============================================================

-- Full order details: user, address, total, status
SELECT o.order_id,
       u.full_name        AS customer_name,
       u.email,
       CONCAT(a.address_line, ', ', a.city, ', ', a.state) AS shipping_address,
       o.total_amount,
       o.status,
       o.order_date
FROM   orders    o
INNER JOIN users     u ON u.user_id    = o.user_id
INNER JOIN addresses a ON a.address_id = o.address_id
ORDER BY o.order_date DESC;

-- Order items with product details
SELECT oi.item_id,
       o.order_id,
       p.product_name,
       p.brand,
       oi.quantity,
       oi.unit_price,
       (oi.quantity * oi.unit_price) AS line_total
FROM   order_items oi
INNER JOIN orders   o ON o.order_id   = oi.order_id
INNER JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id, oi.item_id;

-- Payment details joined with order and user
SELECT p.payment_id,
       u.full_name,
       o.order_id,
       p.amount,
       p.method,
       p.status,
       p.transaction_ref,
       p.payment_date
FROM   payments p
INNER JOIN orders o ON o.order_id = p.order_id
INNER JOIN users  u ON u.user_id  = o.user_id;


-- ============================================================
-- 3.5  LEFT JOIN
-- ============================================================

-- All users with their order count (include users with NO orders)
SELECT u.user_id,
       u.full_name,
       u.email,
       COUNT(o.order_id) AS orders_placed
FROM   users  u
LEFT JOIN orders o ON o.user_id = u.user_id
GROUP BY u.user_id
ORDER BY orders_placed DESC;

-- All products with their average rating (include unrated products)
SELECT p.product_id,
       p.product_name,
       p.price,
       COALESCE(ROUND(AVG(r.rating), 1), 'No Reviews') AS avg_rating
FROM   products p
LEFT JOIN reviews r ON r.product_id = p.product_id
GROUP BY p.product_id
ORDER BY p.product_name;

-- All categories with product count (include empty categories)
SELECT c.category_name,
       COALESCE(COUNT(p.product_id), 0) AS total_products
FROM   categories c
LEFT JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id
ORDER BY total_products DESC;


-- ============================================================
-- 3.6  Subqueries
-- ============================================================

-- Products priced above the overall average price
SELECT product_name, price
FROM   products
WHERE  price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- Users who have placed at least one order
SELECT full_name, email
FROM   users
WHERE  user_id IN (SELECT DISTINCT user_id FROM orders);

-- Most expensive product in each category
SELECT p.product_name,
       c.category_name,
       p.price
FROM   products p
JOIN   categories c ON c.category_id = p.category_id
WHERE  p.price = (
           SELECT MAX(p2.price)
           FROM   products p2
           WHERE  p2.category_id = p.category_id
       )
ORDER BY p.price DESC;

-- Orders where payment is still pending
SELECT o.order_id,
       u.full_name,
       o.total_amount,
       o.status
FROM   orders o
JOIN   users  u ON u.user_id = o.user_id
WHERE  o.order_id IN (
           SELECT order_id
           FROM   payments
           WHERE  status = 'pending'
       );

-- Top 3 best-selling products by quantity
SELECT p.product_name,
       SUM(oi.quantity) AS total_qty_sold
FROM   order_items oi
JOIN   products    p  ON p.product_id = oi.product_id
GROUP BY oi.product_id
ORDER BY total_qty_sold DESC
LIMIT 3;
