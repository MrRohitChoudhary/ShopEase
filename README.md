# 🛒 ShopEase – E-Commerce Database Management System

<div align="center">

![MySQL](https://img.shields.io/badge/MySQL-8.x-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![License](https://img.shields.io/badge/License-Academic-green?style=for-the-badge)

**A complete, production-grade E-Commerce Database project built for Final Year DBMS submission.**

[View Documentation](#-project-documentation) · [SQL Scripts](#-sql-scripts) · [Frontend](#-frontend) · [Setup Guide](#-installation--setup)

</div>

---

## 📋 Project Description

**ShopEase** is a fully designed and implemented E-Commerce Database Management System built as a final-year academic project for the Database Management System (DBMS) subject.

The project demonstrates:
- **Complete relational database design** normalized to 3NF
- **MySQL implementation** with all constraint types (PK, FK, UNIQUE, CHECK, DEFAULT, NOT NULL)
- **Advanced SQL** — JOINs, Subqueries, Views, Indexes, Triggers, Stored Procedures
- **Transaction management** with COMMIT and ROLLBACK
- **Database security** with role-based user privileges
- **Frontend** — A beautiful, dark-themed HTML/CSS/JS web interface

---

## 🛠️ Technologies Used

| Category | Technology |
|----------|------------|
| **Database** | MySQL 8.x |
| **Database Client** | MySQL Workbench / phpMyAdmin / CLI |
| **Frontend** | HTML5, Vanilla CSS3, Vanilla JavaScript |
| **Fonts** | Google Fonts (Inter) |
| **Version Control** | Git / GitHub |

---

## 🗃️ Database Schema Overview

The database `ecommerce_db` contains **10 tables**:

```
ecommerce_db
├── categories      → Product categories (with nested hierarchy)
├── users           → Admin and customer accounts
├── addresses       → User delivery/billing addresses
├── products        → Product catalogue
├── cart            → Active shopping cart items
├── orders          → Order headers
├── order_items     → Order line items
├── payments        → Payment transactions
├── shipping        → Courier / delivery tracking
├── reviews         → Product ratings and written reviews
└── order_audit_log → Automatic status change audit trail (created by trigger)
```

### Key Relationships

```
users (1) ──── (N) orders (1) ──── (N) order_items (N) ──── (1) products
users (1) ──── (N) addresses           |                           |
users (M) ──── (N) products [via cart] orders (1) ──── (1) payments
users (M) ──── (N) products [via reviews]
                                    orders (1) ──── (1) shipping
products (N) ──── (1) categories
```

---

## 📁 Folder Structure

```
Ecommerce DB/
│
├── 📂 sql/
│   ├── 01_create_database.sql       ← CREATE DATABASE & all tables with constraints
│   ├── 02_insert_data.sql           ← Sample INSERT data for all tables
│   ├── 03_queries.sql               ← SELECT queries (WHERE, JOIN, GROUP BY, Subqueries…)
│   ├── 04_views_indexes_triggers.sql← 5 Views, 7 Indexes, 5 Triggers
│   ├── 05_procedures_transactions.sql← 6 Stored Procedures, COMMIT/ROLLBACK
│   └── 06_security_users.sql        ← CREATE USER, GRANT, REVOKE
│
├── 📂 frontend/
│   ├── index.html                   ← Product listing & home page
│   ├── login.html                   ← Login / Register page
│   ├── cart.html                    ← Shopping cart
│   ├── order.html                   ← 3-step checkout & payment
│   ├── style.css                    ← Complete design system (dark theme)
│   └── app.js                       ← All frontend JavaScript
│
├── 📂 docs/
│   └── PROJECT_DOCUMENTATION.md     ← Full academic documentation
│
└── README.md                        ← This file
```

---

## ⚙️ Installation & Setup

### Prerequisites

- MySQL Server 8.0 or above
- MySQL Workbench **or** phpMyAdmin **or** MySQL CLI
- Any modern web browser (Chrome, Firefox, Edge)

### Step 1: Install MySQL

Download and install MySQL Community Server from:  
👉 https://dev.mysql.com/downloads/mysql/

### Step 2: Clone or Download the Project

```bash
# If using Git
git clone https://github.com/yourusername/shopease-ecommerce-dbms.git
cd shopease-ecommerce-dbms
```

Or download the ZIP and extract it.

### Step 3: Execute SQL Scripts

Open **MySQL Workbench** or the **MySQL command line** and run the scripts **in order**:

#### Option A: MySQL Command Line

```bash
# Login to MySQL
mysql -u root -p

# Run scripts in order
source /path/to/sql/01_create_database.sql
source /path/to/sql/02_insert_data.sql
source /path/to/sql/03_queries.sql
source /path/to/sql/04_views_indexes_triggers.sql
source /path/to/sql/05_procedures_transactions.sql
source /path/to/sql/06_security_users.sql
```

#### Option B: MySQL Workbench

1. Open MySQL Workbench → Connect to your local instance
2. File → Open SQL Script → Select `01_create_database.sql` → Execute (⚡)
3. Repeat for files `02` through `06` in order

#### Option C: phpMyAdmin

1. Open phpMyAdmin in browser (`http://localhost/phpmyadmin`)
2. Click **Import** tab → Choose file → Select each `.sql` file → Click Go
3. Execute in order: 01 → 02 → 03 → 04 → 05 → 06

---

## 🚀 How to Run the Frontend

No installation is needed – the frontend uses pure HTML/CSS/JS.

1. Navigate to the `frontend/` folder
2. **Double-click** `index.html` to open it in your browser

**or** use VS Code Live Server:
1. Install the **Live Server** extension in VS Code
2. Right-click `index.html` → **Open with Live Server**
3. Browser opens at `http://127.0.0.1:5500/frontend/index.html`

> ⚠️ **Note:** The frontend uses `localStorage` to simulate database operations. In a production system, JavaScript `fetch()` calls would communicate with a Node.js/PHP backend that queries the MySQL database.

---

## 🔐 Sample Login Credentials

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@ecommerce.com | Admin@123 |
| **Customer** | riya@gmail.com | Riya@123 |
| **Customer** | arjun@gmail.com | Arjun@123 |

---

## 🧪 How to Execute & Test SQL Scripts

### Verify Tables Created
```sql
USE ecommerce_db;
SHOW TABLES;
DESCRIBE users;
DESCRIBE products;
```

### Test Sample Queries
```sql
-- List all products with category
SELECT p.product_name, c.category_name, p.price
FROM products p
JOIN categories c ON c.category_id = p.category_id;

-- Test a view
SELECT * FROM vw_order_summary;
SELECT * FROM vw_product_catalogue;

-- Test stored procedure
CALL sp_sales_report('2024-01-01', '2024-12-31');
```

### Test a Trigger
```sql
-- Check stock before
SELECT product_id, product_name, stock_qty FROM products WHERE product_id = 1;

-- Insert an order item (trigger fires automatically)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 2, 28999.00);

-- Verify stock reduced by 2
SELECT product_id, product_name, stock_qty FROM products WHERE product_id = 1;
```

### Test a Stored Procedure
```sql
SET @new_id = 0;
CALL sp_register_user('Test User', 'test@demo.com', 'hashXXX', '9999999999', @new_id);
SELECT @new_id;
```

---

## 📊 SQL Concepts Demonstrated

| Concept | Location |
|---------|----------|
| CREATE DATABASE / TABLE | `01_create_database.sql` |
| PRIMARY KEY, FOREIGN KEY | `01_create_database.sql` |
| UNIQUE, NOT NULL, CHECK, DEFAULT | `01_create_database.sql` |
| AUTO_INCREMENT | `01_create_database.sql` |
| INSERT statements | `02_insert_data.sql` |
| SELECT + WHERE + ORDER BY | `03_queries.sql` |
| GROUP BY + HAVING | `03_queries.sql` |
| INNER JOIN + LEFT JOIN | `03_queries.sql` |
| Subqueries | `03_queries.sql` |
| Aggregate Functions | `03_queries.sql` |
| CREATE VIEW | `04_views_indexes_triggers.sql` |
| CREATE INDEX + FULLTEXT | `04_views_indexes_triggers.sql` |
| CREATE TRIGGER | `04_views_indexes_triggers.sql` |
| STORED PROCEDURE | `05_procedures_transactions.sql` |
| START TRANSACTION / COMMIT / ROLLBACK | `05_procedures_transactions.sql` |
| CREATE USER / GRANT / REVOKE | `06_security_users.sql` |

---

## 🔮 Future Enhancements

| Enhancement | Description |
|------------|-------------|
| REST API Backend | Node.js + Express connecting frontend to MySQL |
| JWT Authentication | Secure token-based login instead of localStorage |
| Live Payment Gateway | Integration with Razorpay / Stripe |
| Admin Dashboard | Charts for sales analytics (Chart.js) |
| Product Images | AWS S3 / Cloudinary image storage |
| Email Notifications | Order confirmation emails via Nodemailer |
| Redis Caching | Cache frequently accessed product lists |
| Full-Text Search | Elasticsearch for advanced product search |
| Mobile App | React Native frontend using same MySQL backend |

---

## 📝 Normalization Summary

| Form | Status |
|------|--------|
| UNF | Raw, un-normalized flat data identified |
| 1NF | Atomic values, no repeating groups |
| 2NF | No partial dependencies on composite keys |
| 3NF | No transitive dependencies |

All 10 tables in `ecommerce_db` satisfy **Third Normal Form (3NF)**.

---

## 👨‍💻 Author

| Field | Details |
|-------|---------|
| **Name** | Rohitkumar,Uzma, Parth, Apurva |
| **Roll Number** | 67,68,69 |
| **College** | Modern Education Society College of Engineering Wadia |
| **Course** | B.Tech / Diploma – Computer Science / IT |
| **Subject** | Database Management System (DBMS) |
| **Academic Year** | 2025-2026 |
| **Guide** | Sharadha Maam |

---

## 📄 License

This project is submitted as an academic assignment. All SQL scripts and frontend code are original work created for educational purposes.

---

<div align="center">

**⭐ If this project helped you, please give it a star on GitHub! ⭐**

Made with ❤️ for academic excellence

</div>
