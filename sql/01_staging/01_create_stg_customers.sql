USE Olist_Staging;
GO

IF OBJECT_ID('dbo.stg_customers', 'U') IS NOT NULL
    DROP TABLE dbo.stg_customers;
GO

CREATE TABLE dbo.stg_customers (
    customer_id VARCHAR(50) NOT NULL,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(20) NULL,
    customer_city VARCHAR(100) NULL,
    customer_state CHAR(2) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO