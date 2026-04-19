# 📖 Project Documentation & Viva Guide

This folder contains the complete academic documentation and guides for the E-Commerce DBMS project.

## 📂 Contents
*   [**PROJECT_DOCUMENTATION.md**](./PROJECT_DOCUMENTATION.md) — The full 20+ page project report including ER diagrams, normalization (1NF, 2NF, 3NF), and project scope.

---

## 🚀 Quick Demo Guide (For Viva/Submission)

If you need to show the project working to your teacher or during a viva, follow these steps in the **Command Prompt (CMD)**.

### 1. Login to MySQL
Open CMD and type:
```bash
mysql -u root -p
```
*(Enter your password when prompted)*

### 2. Run the SQL Scripts
Run these commands inside the MySQL prompt to build everything:
```sql
-- Create database and tables
source c:/Code/React/Ecommerce DB/sql/01_create_database.sql

-- Insert sample data
source c:/Code/React/Ecommerce DB/sql/02_insert_data.sql

-- Setup Views, Triggers, and Logic
source c:/Code/React/Ecommerce DB/sql/04_views_indexes_triggers.sql
source c:/Code/React/Ecommerce DB/sql/05_procedures_transactions.sql
```

### 3. Key Working Features to Demonstrate
Use these queries to show "Ma'am" that the database is smart:

#### A. Show the Order Summary (View)
Shows how you can simplify complex data from 5 tables into one view.
```sql
SELECT * FROM vw_order_summary;
```

#### B. Show the Stock Trigger (Automation)
Prove that stock decreases automatically when an order is placed.
```sql
-- 1. Note the current stock
SELECT product_name, stock_qty FROM products WHERE product_id = 1;

-- 2. Insert an order item manually
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (1, 1, 5, 28999);

-- 3. Show that stock decreased by exactly 5
SELECT product_name, stock_qty FROM products WHERE product_id = 1;
```

#### C. Generate a Sales Report (Procedure)
Show a professional reporting feature using stored procedures.
```sql
CALL sp_sales_report('2024-01-01', '2024-12-31');
```

---

## 🎓 Viva Tip: Normalization
If asked about normalization, refer to Section 3 of the [Full Documentation](./PROJECT_DOCUMENTATION.md#3-normalization). You can explain that this database is in **3NF** because:
1.  All values are atomic (**1NF**).
2.  There are no partial dependencies on composite keys (**2NF**).
3.  There are no transitive dependencies—each non-key attribute depends solely on the Primary Key (**3NF**).
