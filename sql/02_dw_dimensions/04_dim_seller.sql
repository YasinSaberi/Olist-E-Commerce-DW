USE Olist_DW;
GO

IF OBJECT_ID('dbo.dim_seller', 'U') IS NOT NULL
    DROP TABLE dbo.dim_seller;
GO

CREATE TABLE dbo.dim_seller (
    seller_sk INT IDENTITY(1,1) PRIMARY KEY,
    seller_id VARCHAR(50) NOT NULL,
    seller_city VARCHAR(100) NULL,
    seller_state VARCHAR(50) NULL
);
GO