USE Olist_DW;
GO

IF OBJECT_ID('dbo.dim_customer', 'U') IS NOT NULL
    DROP TABLE dbo.dim_customer;
GO

CREATE TABLE dbo.dim_customer (
    customer_sk INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(20) NULL,
    customer_city VARCHAR(100) NULL,
    customer_state CHAR(2) NULL,
    IsCurrent BIT DEFAULT 1,
    ValidFrom DATETIME DEFAULT GETDATE(),
    ValidTo DATETIME NULL
);
GO