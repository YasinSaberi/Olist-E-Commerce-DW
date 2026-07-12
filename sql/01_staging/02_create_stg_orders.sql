USE Olist_Staging;
GO

IF OBJECT_ID('dbo.stg_orders', 'U') IS NOT NULL
    DROP TABLE dbo.stg_orders;
GO

CREATE TABLE dbo.stg_orders (
    order_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30) NULL,
    order_purchase_timestamp DATETIME NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO