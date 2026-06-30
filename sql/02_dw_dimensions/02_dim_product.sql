USE Olist_DW;
GO

IF OBJECT_ID('dbo.dim_product', 'U') IS NOT NULL
    DROP TABLE dbo.dim_product;
GO

CREATE TABLE dbo.dim_product (
    product_sk INT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_category_name VARCHAR(100) NULL,
    previous_product_category_name VARCHAR(100) NULL,
    product_weight_g DECIMAL(10,2) NULL,
    product_length_cm DECIMAL(10,2) NULL,
    product_height_cm DECIMAL(10,2) NULL,
    product_width_cm DECIMAL(10,2) NULL
);
GO