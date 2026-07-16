USE Olist_DW;
GO

SET NOCOUNT ON;
PRINT '--- RESETTING DATA WAREHOUSE ---';

EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

TRUNCATE TABLE dbo.fact_sales;
TRUNCATE TABLE dbo.fact_logistics;

-- ۳. پاک‌سازی جداول ابعاد (به جز dim_date که استاتیک است)
TRUNCATE TABLE dbo.dim_customer;
TRUNCATE TABLE dbo.dim_product;
TRUNCATE TABLE dbo.dim_seller;
TRUNCATE TABLE dbo.dim_review;

TRUNCATE TABLE dbo.etl_audit_log;

EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';

PRINT 'DW Reset Completed Successfully.';
GO

USE Olist_Staging;
GO

PRINT '--- RESETTING STAGING AREA ---';

TRUNCATE TABLE dbo.stg_customers;
TRUNCATE TABLE dbo.stg_orders;
TRUNCATE TABLE dbo.stg_order_items;
TRUNCATE TABLE dbo.stg_sellers;
TRUNCATE TABLE dbo.stg_products;
TRUNCATE TABLE dbo.stg_geolocation;
TRUNCATE TABLE dbo.stg_reviews;

PRINT 'Staging Reset Completed Successfully.';
GO
