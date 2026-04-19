# E-Commerce Database Management System
## Complete Academic Project Documentation

**Subject:** Database Management System (DBMS)  
**Level:** Final Year Diploma / Bachelor's Degree  
**DBMS Used:** MySQL 8.x  
**Prepared by:** [Your Name] | [Roll No] | [College Name]  
**Date:** April 2024

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Entity-Relationship (ER) Design](#2-entity-relationship-er-design)
3. [Normalization](#3-normalization)
4. [SQL Implementation Summary](#4-sql-implementation-summary)
5. [Advanced Database Concepts](#5-advanced-database-concepts)
6. [Frontend Overview](#6-frontend-overview)
7. [Project Output Screens](#7-project-output-screens)
8. [Viva Questions & Answers](#8-viva-questions--answers)

---

## 1. Project Overview

### 1.1 Project Title
**E-Commerce Database Management System (EDBMS)**

### 1.2 Problem Statement

Traditional retail stores are restricted by physical geography, limited operating hours, and high overhead costs. The absence of a centralized, structured data management system results in:
- Inventory mismanagement and stock overflows / shortages
- No customer purchase history for personalized service
- Manual order tracking leading to delays and errors
- Inability to generate meaningful sales reports

There is a clear need for a **relational database-backed e-commerce platform** that automates product management, order processing, payment tracking, and reporting.

### 1.3 Objectives

| # | Objective |
|---|-----------|
| 1 | Design a fully normalized relational database schema for an e-commerce system |
| 2 | Implement all CRUD operations using MySQL with proper constraints |
| 3 | Demonstrate advanced SQL: joins, subqueries, views, triggers, stored procedures |
| 4 | Apply transaction management (COMMIT / ROLLBACK) for data integrity |
| 5 | Implement database security using role-based user privileges |
| 6 | Create a simple HTML/CSS/JS frontend connected conceptually to the database |

### 1.4 Scope of the System

**In-scope:**
- User registration, login, and role management (Admin / Customer)
- Product catalogue with categories and attributes
- Shopping cart management
- Order placement and order item tracking
- Payment processing and status tracking
- Shipping / courier tracking
- Customer product reviews and ratings
- Admin reports (sales, revenue, inventory)

**Out-of-scope:**
- Live payment gateway integration (concept only)
- Mobile application
- Third-party API integration

### 1.5 Existing System vs Proposed System

| Aspect | Existing (Manual) System | Proposed (DBMS) System |
|--------|--------------------------|------------------------|
| Data Storage | Physical registers / Excel files | Centralized MySQL database |
| Data Access | Single location only | Anywhere via web browser |
| Data Integrity | Prone to duplication & errors | Enforced via keys & constraints |
| Reporting | Manual calculation | Automated SQL queries & views |
| Security | None / Basic file lock | Role-based access (GRANT/REVOKE) |
| Backup | Manual file copy | Automated mysqldump |
| Scalability | Very limited | Highly scalable |
| Speed | Slow manual search | Indexed query in milliseconds |

### 1.6 Advantages of the Proposed System

1. **Data Integrity** – PRIMARY KEY, FOREIGN KEY, CHECK, and UNIQUE constraints prevent corrupt data
2. **Automation** – Triggers automatically update stock when orders are placed or cancelled
3. **Performance** – Indexes on frequently searched columns dramatically speed up queries
4. **Security** – Separate DB users for admin, app server, and reporting (principle of least privilege)
5. **Scalability** – Relational model supports millions of records
6. **Audit Trail** – `order_audit_log` table and triggers record every status change
7. **Concurrency** – Transactions with COMMIT/ROLLBACK maintain consistency under multi-user access

---

## 2. Entity-Relationship (ER) Design

### 2.1 List of Entities

| Entity | Description |
|--------|-------------|
| **Users** | People who interact with the system (Admin or Customer) |
| **Categories** | Product classification hierarchy (supports nested sub-categories) |
| **Products** | Items available for purchase |
| **Addresses** | Delivery/billing addresses belonging to users |
| **Cart** | Items temporarily stored before ordering |
| **Orders** | Purchase transactions placed by customers |
| **Order_Items** | Individual line items within an order |
| **Payments** | Financial transaction records for orders |
| **Shipping** | Courier and delivery tracking for orders |
| **Reviews** | Customer ratings and feedback for products |

### 2.2 Attributes of Each Entity

#### Users
| Attribute | Type | Constraint |
|-----------|------|------------|
| user_id | INT | PK, AUTO_INCREMENT |
| full_name | VARCHAR(150) | NOT NULL |
| email | VARCHAR(200) | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | NOT NULL |
| phone | VARCHAR(15) | CHECK (format) |
| role | ENUM | DEFAULT 'customer' |
| is_active | TINYINT | DEFAULT 1 |
| created_at | DATETIME | DEFAULT NOW() |

#### Categories
| Attribute | Type | Constraint |
|-----------|------|------------|
| category_id | INT | PK, AUTO_INCREMENT |
| category_name | VARCHAR(100) | UNIQUE, NOT NULL |
| description | TEXT | NULL |
| parent_id | INT | FK → categories(category_id) |
| is_active | TINYINT | DEFAULT 1 |

#### Products
| Attribute | Type | Constraint |
|-----------|------|------------|
| product_id | INT | PK, AUTO_INCREMENT |
| category_id | INT | FK → categories |
| product_name | VARCHAR(200) | NOT NULL |
| description | TEXT | NULL |
| price | DECIMAL(10,2) | CHECK (≥ 0) |
| stock_qty | INT | CHECK (≥ 0), DEFAULT 0 |
| brand | VARCHAR(100) | NULL |
| image_url | VARCHAR(500) | NULL |
| is_active | TINYINT | DEFAULT 1 |

*(Attributes for remaining entities are similarly documented in the SQL scripts)*

### 2.3 Primary Keys and Foreign Keys

| Table | Primary Key | Foreign Key(s) |
|-------|-------------|----------------|
| categories | category_id | parent_id → categories.category_id |
| users | user_id | – |
| addresses | address_id | user_id → users.user_id |
| products | product_id | category_id → categories.category_id |
| cart | cart_id | user_id → users, product_id → products |
| orders | order_id | user_id → users, address_id → addresses |
| order_items | item_id | order_id → orders, product_id → products |
| payments | payment_id | order_id → orders |
| shipping | shipping_id | order_id → orders |
| reviews | review_id | product_id → products, user_id → users |

### 2.4 Cardinality & Participation

| Relationship | Cardinality | Participation |
|--------------|-------------|---------------|
| User PLACES Order | 1 : N | Partial (user) – Total (order) |
| Order HAS Order_Items | 1 : N | Total – Total |
| Order HAHAS Payment | 1 : 1 | Total – Total |
| Order HAS Shipping | 1 : 1 | Total – Partial |
| Product BELONGS TO Category | N : 1 | Total – Partial |
| User HAS Addresses | 1 : N | Partial – Total |
| User WRITES Review | M : N (resolved via reviews table) | Partial – Partial |
| User ADDS Product TO Cart | M : N (resolved via cart table) | Partial – Partial |

### 2.5 ER Diagram (Textual Representation)

```
USERS ─────────────────── ADDRESSES
  │  (1:N)                  (has)
  │
  │ (1:N)
ORDERS ─────────────────── ORDER_ITEMS ──────── PRODUCTS
  │  (1:1)                   (contains)            │  (N:1)
  │                                                 │
PAYMENTS                              CATEGORIES (hierarchy)
  │
SHIPPING

USERS ──── CART ──── PRODUCTS
       (M:N bridge)

USERS ──── REVIEWS ──── PRODUCTS
       (M:N bridge)
```

---

## 3. Normalization

### 3.1 Un-Normalized Form (UNF)

Consider a flat table capturing all order information:

```
OrderData(OrderID, CustomerName, CustomerEmail, CustomerPhone,
          Address, City, State, Pincode,
          Product1Name, Product1Price, Product1Qty,
          Product2Name, Product2Price, Product2Qty, ...
          PaymentMethod, PaymentStatus,
          CourierName, TrackingNo)
```

**Problems:**
- Repeating groups (Product1, Product2, …) → not atomic
- Data redundancy (address repeated in every order)
- Update anomalies (change customer email → update many rows)

---

### 3.2 First Normal Form (1NF)

**Rule:** Eliminate repeating groups; each column must contain atomic values.

```
Orders(OrderID, CustomerName, CustomerEmail, CustomerPhone,
       Address, City, State, Pincode,
       ProductName, ProductPrice, ProductQty,
       PaymentMethod, PaymentStatus, CourierName, TrackingNo)
```

Each row = one product in one order. Now atomic, but still has redundancy.

---

### 3.3 Second Normal Form (2NF)

**Rule:** Must be in 1NF AND no partial dependency on a composite key.

Composite key: **(OrderID, ProductName)**

**Partial dependencies identified:**
- CustomerName, CustomerEmail, Phone, Address → depend only on **OrderID** (not ProductName)
- ProductPrice → depends only on **ProductName** (not OrderID)

**Solution – Split into:**

```
Customers(CustomerID[PK], CustomerName, Email, Phone, Address, City, State, Pincode)

Products(ProductID[PK], ProductName, ProductPrice)

Orders(OrderID[PK], CustomerID[FK], PaymentMethod, PaymentStatus, CourierName, TrackingNo)

Order_Items(OrderID[FK], ProductID[FK], Qty)  ← composite PK
```

---

### 3.4 Third Normal Form (3NF)

**Rule:** Must be in 2NF AND no transitive dependency (non-key → non-key).

**Transitive dependency identified in Orders:**
> OrderID → CustomerID → CustomerEmail (CustomerEmail depends transitively on OrderID via CustomerID)

This is already resolved by extracting Customers into a separate table.

**Another transitive dependency in Products:**
> ProductID → CategoryID → CategoryName  

**Solution:**
```
Categories(CategoryID[PK], CategoryName, Description)
Products(ProductID[PK], CategoryID[FK], ProductName, Price, Stock, Brand)
```

**Final 3NF schema matches our implemented tables:**
- `users`, `addresses` → resolved customer / address transitive dependencies
- `categories`, `products` → resolved category name transitive dependency
- `orders`, `order_items` → resolved partial dependencies
- `payments`, `shipping` → extracted to eliminate multi-valued attributes
- `reviews` → isolated the M:N relationship

---

## 4. SQL Implementation Summary

All SQL is implemented across 6 files in the `sql/` directory:

| File | Contents |
|------|----------|
| `01_create_database.sql` | CREATE DATABASE, all CREATE TABLE with constraints |
| `02_insert_data.sql` | INSERT sample data for all tables |
| `03_queries.sql` | SELECT with WHERE, GROUP BY, HAVING, ORDER BY, JOINs, Subqueries |
| `04_views_indexes_triggers.sql` | 5 Views, 7 Indexes, 5 Triggers |
| `05_procedures_transactions.sql` | 6 Stored Procedures, COMMIT/ROLLBACK examples |
| `06_security_users.sql` | CREATE USER, GRANT, REVOKE, FLUSH PRIVILEGES |

### Constraints Used

| Constraint | Example |
|------------|---------|
| PRIMARY KEY | `user_id INT NOT NULL AUTO_INCREMENT, CONSTRAINT pk_users PRIMARY KEY (user_id)` |
| FOREIGN KEY | `CONSTRAINT fk_prod_category FOREIGN KEY (category_id) REFERENCES categories(category_id)` |
| UNIQUE | `CONSTRAINT uq_user_email UNIQUE (email)` |
| NOT NULL | `full_name VARCHAR(150) NOT NULL` |
| CHECK | `CONSTRAINT chk_prod_price CHECK (price >= 0)` |
| DEFAULT | `role ENUM('admin','customer') NOT NULL DEFAULT 'customer'` |
| AUTO_INCREMENT | `user_id INT NOT NULL AUTO_INCREMENT` |

---

## 5. Advanced Database Concepts

### 5.1 Transaction Control

Transactions ensure **ACID** properties:

| Property | Meaning |
|----------|---------|
| **A**tomicity | All operations succeed, or all are rolled back |
| **C**onsistency | DB transitions from one valid state to another |
| **I**solation | Concurrent transactions don't interfere |
| **D**urability | Committed data persists even after crashes |

Example from `sp_place_order`:
```sql
START TRANSACTION;
  -- Insert order header
  -- Insert order items (triggers fire to reduce stock)
  -- Clear cart
COMMIT;  -- Only if ALL succeed
-- If any error → ROLLBACK via EXIT HANDLER
```

### 5.2 Security (User Roles)

Three role levels implemented:

| User | MySQL Account | Privileges |
|------|--------------|------------|
| DBA | `ecom_admin` | ALL PRIVILEGES |
| Application Server | `ecom_app` | SELECT, INSERT, UPDATE, DELETE |
| Reporting Tool | `ecom_report` | SELECT only |

### 5.3 Backup Concept

```bash
# Full database backup
mysqldump -u ecom_admin -p ecommerce_db > backup_ecommerce_YYYYMMDD.sql

# Restore from backup
mysql -u ecom_admin -p ecommerce_db < backup_ecommerce_YYYYMMDD.sql

# Backup with gzip compression
mysqldump -u ecom_admin -p ecommerce_db | gzip > backup.sql.gz
```

### 5.4 Index Optimization

| Index Type | Used On | Benefit |
|------------|---------|---------|
| B-Tree (default) | `price`, `status`, `user_id` | Fast range queries and equality lookups |
| Composite | `(order_id, product_id)` | Covers ORDER JOIN queries without table scan |
| FULLTEXT | `product_name, description` | Enables fast product search with MATCH…AGAINST |

**EXPLAIN keyword** can be used to verify index usage:
```sql
EXPLAIN SELECT * FROM products WHERE category_id = 2 AND price < 5000;
```

---

## 6. Frontend Overview

### Technology Stack
| Layer | Technology |
|-------|------------|
| Structure | HTML5 (Semantic) |
| Styling | Vanilla CSS (Dark theme + Glassmorphism) |
| Logic | Vanilla JavaScript (ES2020+) |
| Data Store | localStorage (simulates backend DB calls) |

### How Frontend Connects to Database (Conceptual)

```
Browser (HTML/CSS/JS)
    │  HTTP Request (AJAX / fetch)
    ▼
Web Server (Node.js / PHP / Python)
    │  SQL Query (via DB Driver)
    ▼
MySQL Database (ecommerce_db)
    │  Result Set (JSON)
    ▼
Web Server → JSON Response
    │
Browser renders data
```

In a production system, the JavaScript `fetch()` API would call REST API endpoints (e.g., `GET /api/products`, `POST /api/orders`) which internally run our stored procedures against the MySQL database.

### Pages
| Page | File | Description |
|------|------|-------------|
| Product Listing | `index.html` | Browse, filter, sort, search, add to cart |
| Login / Register | `login.html` | Authentication with validation & tabs |
| Shopping Cart | `cart.html` | Review cart, update qty, see summary |
| Checkout / Order | `order.html` | 3-step checkout: address → payment → confirm |

---

## 7. Project Output Screens

### Screen 1: Home / Product Listing
- Dark-themed header with search bar and cart icon with badge count
- Hero banner with gradient text and animated floating shapes
- Category filter pills (All, Mobiles, Laptops, Fashion…)
- Responsive product grid cards with emoji, brand, name, star rating, price with discount %
- Sort dropdown (Price, Rating, Name)
- Clicking a product card opens a detail modal with Add to Cart and Buy Now buttons

### Screen 2: Login Page
- Glassmorphism card with Login / Register tab switcher
- Login tab: Email + password fields, 'Remember me', demo credentials shown
- Register tab: Full name, email, phone, password with live strength meter, confirm password, terms checkbox
- Error messages appear inline below each field
- On success: toast notification → redirect to home

### Screen 3: Shopping Cart
- Table-style list of cart items with emoji, name, brand, line total
- Quantity +/– controls per item
- Remove item button
- Sticky sidebar: Subtotal, 10% discount, shipping, Grand Total
- 'Proceed to Checkout' and 'Continue Shopping' buttons
- Empty cart illustration if no items

### Screen 4: Checkout – Step 1 (Delivery Address)
- 3-step progress indicator at the top (Address → Payment → Confirm)
- Form: Full Name, Phone, Address Line, City, State, PIN Code
- Client-side validation with red error messages
- Order summary sidebar shows items throughout checkout

### Screen 5: Checkout – Step 2 (Payment)
- 5 payment method cards: UPI, Credit/Debit Card, Net Banking, Wallet, COD
- Selected method highlighted with purple border
- Contextual sub-form: UPI ID input or Card number/expiry/CVV
- 'Back' and 'Review Order →' buttons

### Screen 6: Checkout – Step 3 (Review & Confirm)
- Summary cards: Deliver To, Payment Method, Items list
- Grand total prominently displayed
- 'Place Order' button

### Screen 7: Payment Success
- Animated green checkmark circle (CSS keyframe animation)
- Order ID displayed (#ORD-0001)
- Estimated delivery message
- 'Continue Shopping' and 'Track Order' buttons

---

## 8. Viva Questions & Answers

**Q1: What is a Primary Key?**  
A: A column (or set of columns) that uniquely identifies each row in a table. It cannot be NULL and must be unique. Example: `user_id` in the `users` table.

**Q2: Difference between INNER JOIN and LEFT JOIN?**  
A: INNER JOIN returns only rows that have matching values in both tables. LEFT JOIN returns ALL rows from the left table, and matching rows from the right table; non-matching right-side rows show NULL.

**Q3: What is Normalization? Why is it important?**  
A: Normalization is the process of organizing a database to reduce redundancy and improve data integrity. It is important because it eliminates update, insert, and delete anomalies.

**Q4: What is a Trigger and when did you use it?**  
A: A trigger is a stored program that automatically executes in response to a DML event (INSERT, UPDATE, DELETE). Example: `trg_reduce_stock_on_order` fires AFTER INSERT on `order_items` and reduces the product's `stock_qty`.

**Q5: What is a View?**  
A: A view is a virtual table based on the result set of a SQL query. It simplifies complex queries and can restrict column access for security. Example: `vw_order_summary` joins orders, users, payments, and shipping.

**Q6: What is an Index? What types did you use?**  
A: An index is a data structure that speeds up data retrieval. Types used: B-Tree index (default), Composite index, and FULLTEXT index for product search.

**Q7: Explain ACID properties.**  
A: Atomicity (all or nothing), Consistency (valid state transitions), Isolation (transactions don't interfere), Durability (committed data persists).

**Q8: What is the difference between DELETE and TRUNCATE?**  
A: DELETE removes specific rows (can have WHERE clause, fires triggers, can be rolled back). TRUNCATE removes all rows instantly (no WHERE, doesn't fire row-level triggers, cannot be rolled back).

**Q9: What is a Stored Procedure?**  
A: A stored procedure is a precompiled group of SQL statements stored in the database and executed as a unit. Example: `sp_place_order` handles the entire order placement with transaction control.

**Q10: How did you handle security in your project?**  
A: Created three MySQL users with different privilege levels: `ecom_admin` (ALL), `ecom_app` (DML only—SELECT/INSERT/UPDATE/DELETE), `ecom_report` (SELECT only). This implements the principle of least privilege.
