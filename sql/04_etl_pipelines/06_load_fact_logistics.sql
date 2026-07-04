USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_fact_logistics
AS
BEGIN
    INSERT INTO dbo.fact_logistics (
        order_id, order_item_id, customer_sk, seller_sk, review_sk, 
        order_date_sk, freight_value, delivery_delay_days, shipping_delay_days
    )
    SELECT 
        oi.order_id,
        oi.order_item_id,
        ISNULL(c.customer_sk, -1),
        ISNULL(s.seller_sk, -1),
        ISNULL(r.review_sk, -1),
        CAST(FORMAT(o.order_purchase_timestamp, 'yyyyMMdd') AS INT),
        oi.freight_value,
        -- Calculate delivery delay (Actual Delivery vs Estimated Delivery)
        DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS delivery_delay_days,
        -- Calculate shipping delay (Actual Carrier Date vs Shipping Limit Date)
        DATEDIFF(day, oi.shipping_limit_date, o.order_delivered_carrier_date) AS shipping_delay_days
    FROM Olist_Staging.dbo.stg_order_items oi
    LEFT JOIN Olist_Staging.dbo.stg_orders o 
        ON oi.order_id = o.order_id
    LEFT JOIN dbo.dim_customer c 
        ON o.customer_id = c.customer_id AND c.IsCurrent = 1
    LEFT JOIN dbo.dim_seller s 
        ON oi.seller_id = s.seller_id
    LEFT JOIN dbo.dim_review r 
        ON oi.order_id = r.order_id;
END;
GO