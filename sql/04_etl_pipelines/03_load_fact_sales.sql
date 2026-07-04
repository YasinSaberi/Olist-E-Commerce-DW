USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_fact_sales
AS
BEGIN
    INSERT INTO dbo.fact_sales (order_id, order_item_id, customer_sk, product_sk, order_date_sk, price, freight_value)
    SELECT 
        oi.order_id,
        oi.order_item_id,
        ISNULL(c.customer_sk, -1),
        ISNULL(p.product_sk, -1),
        CAST(FORMAT(o.order_purchase_timestamp, 'yyyyMMdd') AS INT),
        oi.price,
        oi.freight_value
    FROM Olist_Staging.dbo.stg_order_items oi
    LEFT JOIN Olist_Staging.dbo.stg_orders o 
        ON oi.order_id = o.order_id
    LEFT JOIN dbo.dim_customer c 
        ON o.customer_id = c.customer_id AND c.IsCurrent = 1
    LEFT JOIN dbo.dim_product p 
        ON oi.product_id = p.product_id;
END;
GO