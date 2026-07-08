USE Olist_DW;
GO

IF OBJECT_ID('dbo.dim_seller', 'U') IS NOT NULL DROP TABLE dbo.dim_seller;
GO

CREATE TABLE dbo.dim_seller (
    seller_sk INT IDENTITY(1,1) PRIMARY KEY,
    seller_id VARCHAR(50) NOT NULL UNIQUE,
    seller_city VARCHAR(100) NULL,
    seller_state CHAR(2) NULL
);
GO

SET IDENTITY_INSERT dbo.dim_seller ON;
INSERT INTO dbo.dim_seller (seller_sk, seller_id, seller_city, seller_state)
VALUES (-1, 'UNKNOWN', 'Unknown', 'UN');
SET IDENTITY_INSERT dbo.dim_seller OFF;
GO