-- ============================================================
--  E-COMMERCE DATABASE MANAGEMENT SYSTEM
--  Module 6: Security – User Roles & Privileges
-- ============================================================

USE ecommerce_db;

-- -------------------------------------------------------
-- 6.1  Create database users with different privileges
-- -------------------------------------------------------

-- Admin: full access
CREATE USER IF NOT EXISTS 'ecom_admin'@'localhost' IDENTIFIED BY 'Admin@Secure123';
GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'ecom_admin'@'localhost';

-- App user (backend server): DML only, no DDL, no DROP
CREATE USER IF NOT EXISTS 'ecom_app'@'localhost' IDENTIFIED BY 'App@Secure456';
GRANT SELECT, INSERT, UPDATE, DELETE ON ecommerce_db.* TO 'ecom_app'@'localhost';

-- Reporting user: read-only
CREATE USER IF NOT EXISTS 'ecom_report'@'localhost' IDENTIFIED BY 'Report@Secure789';
GRANT SELECT ON ecommerce_db.* TO 'ecom_report'@'localhost';

-- Flush to apply changes
FLUSH PRIVILEGES;

-- -------------------------------------------------------
-- 6.2  Show grants
-- -------------------------------------------------------
SHOW GRANTS FOR 'ecom_app'@'localhost';
SHOW GRANTS FOR 'ecom_report'@'localhost';

-- -------------------------------------------------------
-- 6.3  Revoke privilege example
-- -------------------------------------------------------
-- REVOKE DELETE ON ecommerce_db.* FROM 'ecom_app'@'localhost';

-- -------------------------------------------------------
-- 6.4  Drop user example (if needed)
-- -------------------------------------------------------
-- DROP USER IF EXISTS 'ecom_report'@'localhost';
