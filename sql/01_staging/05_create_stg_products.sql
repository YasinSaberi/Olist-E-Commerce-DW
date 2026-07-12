USE Olist_Staging;
GO

IF OBJECT_ID('dbo.stg_products', 'U') IS NOT NULL
    DROP TABLE dbo.stg_products;
GO

CREATE TABLE dbo.stg_products (
    product_id VARCHAR(50) NOT NULL,
    product_category_name VARCHAR(100) NULL,
    product_name_length INT NULL,
    product_description_length INT NULL,
    product_photos_qty INT NULL,
    product_weight_g DECIMAL(10,2) NULL,
    product_length_cm DECIMAL(10,2) NULL,
    product_height_cm DECIMAL(10,2) NULL,
    product_width_cm DECIMAL(10,2) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO