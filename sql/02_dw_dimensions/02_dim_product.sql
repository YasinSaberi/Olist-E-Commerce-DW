USE Olist_DW;
GO

IF OBJECT_ID('dbo.dim_product', 'U') IS NOT NULL DROP TABLE dbo.dim_product;
GO

CREATE TABLE dbo.dim_product (
    product_sk INT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL UNIQUE,
    product_category_name VARCHAR(100) NULL,
    previous_product_category_name VARCHAR(100) NULL,
    product_weight_g DECIMAL(10,2) NULL,
    product_length_cm DECIMAL(10,2) NULL,
    product_height_cm DECIMAL(10,2) NULL,
    product_width_cm DECIMAL(10,2) NULL
);
GO

SET IDENTITY_INSERT dbo.dim_product ON;
INSERT INTO dbo.dim_product (product_sk, product_id, product_category_name, previous_product_category_name)
VALUES (-1, 'UNKNOWN', 'Unknown', NULL);
SET IDENTITY_INSERT dbo.dim_product OFF;
GO