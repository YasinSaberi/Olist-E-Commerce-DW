USE Olist_Staging;
GO

IF OBJECT_ID('dbo.stg_order_items', 'U') IS NOT NULL
    DROP TABLE dbo.stg_order_items;
GO

CREATE TABLE dbo.stg_order_items (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date DATETIME NULL,
    price DECIMAL(10, 2) NULL,
    freight_value DECIMAL(10, 2) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO