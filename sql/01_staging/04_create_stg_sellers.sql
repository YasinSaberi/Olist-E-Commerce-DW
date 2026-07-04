USE Olist_Staging;
GO

IF OBJECT_ID('dbo.stg_sellers', 'U') IS NOT NULL
    DROP TABLE dbo.stg_sellers;
GO

CREATE TABLE dbo.stg_sellers (
    seller_id VARCHAR(50) NOT NULL,
    seller_zip_code_prefix VARCHAR(20) NULL,
    seller_city VARCHAR(100) NULL,
    seller_state CHAR(2) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO