USE Olist_DW;
GO

IF OBJECT_ID('dbo.dim_customer', 'U') IS NOT NULL DROP TABLE dbo.dim_customer;
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

-- Enforce only one active row per unique customer
CREATE UNIQUE NONCLUSTERED INDEX UQ_DimCustomer_Active 
ON dbo.dim_customer(customer_unique_id) WHERE IsCurrent = 1;
GO

-- Insert Unknown Member to protect Fact Foreign Keys
SET IDENTITY_INSERT dbo.dim_customer ON;
INSERT INTO dbo.dim_customer (customer_sk, customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, IsCurrent, ValidFrom, ValidTo)
VALUES (-1, 'UNKNOWN', 'UNKNOWN', '0', 'Unknown', 'UN', 1, '1900-01-01', NULL);
SET IDENTITY_INSERT dbo.dim_customer OFF;
GO