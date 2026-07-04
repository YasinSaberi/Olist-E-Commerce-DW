USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.Load_FactLogistics
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.FactLogistics;

    INSERT INTO dbo.FactLogistics (
        SellerKey, GeoKey, ReviewKey, CustomerKey,
        OrderDateKey, EstimatedDeliveryDateKey, ActualDeliveryDateKey,
        OrderID, OrderItemSequence, FreightValue, 
        DeliveryDelayDays, ActualShippingDurationDays, LoadDate
    )
    SELECT 
        ISNULL(ds.SellerKey, -1) AS SellerKey,
        ISNULL(dg.GeoKey, -1) AS GeoKey,
        ISNULL(dr.ReviewKey, -1) AS ReviewKey,
        ISNULL(dc.CustomerKey, -1) AS CustomerKey,
        
        CONVERT(VARCHAR(8), o.order_purchase_timestamp, 112) AS OrderDateKey,
        CONVERT(VARCHAR(8), o.order_estimated_delivery_date, 112) AS EstimatedDeliveryDateKey,
        CASE 
            WHEN o.order_delivered_customer_date IS NOT NULL 
            THEN CONVERT(VARCHAR(8), o.order_delivered_customer_date, 112)
            ELSE NULL 
        END AS ActualDeliveryDateKey,

        o.order_id AS OrderID,
        oi.order_item_id AS OrderItemSequence,
        CAST(oi.freight_value AS DECIMAL(10,2)) AS FreightValue,

        CASE 
            WHEN o.order_delivered_customer_date IS NOT NULL 
            THEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date)
            ELSE NULL 
        END AS DeliveryDelayDays,

        CASE 
            WHEN o.order_delivered_customer_date IS NOT NULL 
            THEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)
            ELSE NULL 
        END AS ActualShippingDurationDays,
        
        GETDATE() AS LoadDate

    FROM Olist_Staging.dbo.stg_orders o
    INNER JOIN Olist_Staging.dbo.stg_order_items oi ON o.order_id = oi.order_id
    
    LEFT JOIN dbo.DimSeller ds ON oi.seller_id = ds.SellerBusinessID
    LEFT JOIN dbo.DimCustomer dc ON o.customer_id = dc.CustomerBusinessID -- هماهنگی با یاسین
    
    LEFT JOIN dbo.DimGeolocation dg ON ds.ZipCode = dg.ZipCodePrefix 
    
    LEFT JOIN Olist_Staging.dbo.stg_reviews r ON o.order_id = r.order_id
    LEFT JOIN dbo.DimReview dr ON r.review_id = dr.ReviewBusinessID;

END;
GO