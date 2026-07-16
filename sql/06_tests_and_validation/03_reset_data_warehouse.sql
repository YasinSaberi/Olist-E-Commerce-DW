-- ==============================================================================
-- Script Name: 03_reset_data_warehouse.sql
-- Description: Clears all data from Data Warehouse and Staging areas safely, 
--              bypassing Foreign Key constraints where necessary.
-- ==============================================================================

USE Olist_DW;
GO

SET NOCOUNT ON;
PRINT '--- RESETTING DATA WAREHOUSE ---';

-- ۱. غیرفعال کردن موقت تمام کلیدهای خارجی برای جلوگیری از تداخل
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- ۲. پاک‌سازی جداول فکت و لاگ (چون کلیدی به آن‌ها ارجاع نداده، TRUNCATE مجاز است)
TRUNCATE TABLE dbo.fact_sales;
TRUNCATE TABLE dbo.fact_logistics;
TRUNCATE TABLE dbo.etl_audit_log;

-- ۳. پاک‌سازی جداول ابعاد (استفاده از DELETE به جای TRUNCATE به دلیل وجود FK)
--    و ریست کردن هم‌زمان شمارنده‌های IDENTITY
DELETE FROM dbo.dim_customer;
DBCC CHECKIDENT ('dbo.dim_customer', RESEED, 0); 

DELETE FROM dbo.dim_product;
DBCC CHECKIDENT ('dbo.dim_product', RESEED, 0);

DELETE FROM dbo.dim_seller;
DBCC CHECKIDENT ('dbo.dim_seller', RESEED, 0);

DELETE FROM dbo.dim_review;
DBCC CHECKIDENT ('dbo.dim_review', RESEED, 0);

-- ۴. فعال‌سازی و اعتبارسنجی مجدد تمامی کلیدهای خارجی
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';

PRINT 'DW Reset Completed Successfully.';
GO

-- ==============================================================================

USE Olist_Staging;
GO

PRINT '--- RESETTING STAGING AREA ---';

-- پاک‌سازی لایه فرود (چون استیجینگ FK ندارد، TRUNCATE بهترین و سریع‌ترین روش است)
TRUNCATE TABLE dbo.stg_customers;
TRUNCATE TABLE dbo.stg_orders;
TRUNCATE TABLE dbo.stg_order_items;
TRUNCATE TABLE dbo.stg_sellers;
TRUNCATE TABLE dbo.stg_products;
TRUNCATE TABLE dbo.stg_geolocation;
TRUNCATE TABLE dbo.stg_reviews;

PRINT 'Staging Reset Completed Successfully.';
GO