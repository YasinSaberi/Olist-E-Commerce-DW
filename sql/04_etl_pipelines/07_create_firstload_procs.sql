USE Olist_DW;
GO

-- First Load: Sales Fact
CREATE OR ALTER PROCEDURE dbo.sp_firstload_fact_sales
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_etl_logger 'sp_firstload_fact_sales', 'fact_sales', 'Started First Load Bulk Insert', 'RUNNING';
    
    BEGIN TRY
        BEGIN TRAN;
        -- Direct bulk insert without NOT EXISTS overhead
        INSERT INTO dbo.fact_sales (order_id, order_item_id, customer_sk, product_sk, order_date_sk, price, freight_value)
        SELECT 
            oi.order_id, oi.order_item_id, ISNULL(c.customer_sk, -1), ISNULL(p.product_sk, -1),
            CAST(CONVERT(VARCHAR(8), o.order_purchase_timestamp, 112) AS INT), oi.price, oi.freight_value
        FROM Olist_Staging.dbo.stg_order_items oi
        INNER JOIN Olist_Staging.dbo.stg_orders o ON oi.order_id = o.order_id
        LEFT JOIN Olist_Staging.dbo.stg_customers sc ON o.customer_id = sc.customer_id
        LEFT JOIN dbo.dim_customer c ON sc.customer_unique_id = c.customer_unique_id AND c.IsCurrent = 1
        LEFT JOIN dbo.dim_product p ON oi.product_id = p.product_id;
        COMMIT TRAN;

        EXEC dbo.sp_etl_logger 'sp_firstload_fact_sales', 'fact_sales', 'Completed First Load successfully', 'SUCCESS';
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        -- Log failure AFTER rollback so the log persists
        EXEC dbo.sp_etl_logger 'sp_firstload_fact_sales', 'fact_sales', @ErrMsg, 'FAILED';
        THROW;
    END CATCH;
END;
GO

-- First Load: Logistics Fact
CREATE OR ALTER PROCEDURE dbo.sp_firstload_fact_logistics
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_etl_logger 'sp_firstload_fact_logistics', 'fact_logistics', 'Started First Load Bulk Insert', 'RUNNING';
    
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO dbo.fact_logistics (order_id, order_item_id, customer_sk, seller_sk, review_sk, order_date_sk, freight_value, delivery_delay_days, shipping_delay_days)
        SELECT 
            oi.order_id, oi.order_item_id, ISNULL(c.customer_sk, -1), ISNULL(s.seller_sk, -1), ISNULL(r.review_sk, -1),
            CAST(CONVERT(VARCHAR(8), o.order_purchase_timestamp, 112) AS INT), oi.freight_value,
            DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date),
            DATEDIFF(day, oi.shipping_limit_date, o.order_delivered_carrier_date)
        FROM Olist_Staging.dbo.stg_order_items oi
        INNER JOIN Olist_Staging.dbo.stg_orders o ON oi.order_id = o.order_id
        LEFT JOIN Olist_Staging.dbo.stg_customers sc ON o.customer_id = sc.customer_id
        LEFT JOIN dbo.dim_customer c ON sc.customer_unique_id = c.customer_unique_id AND c.IsCurrent = 1
        LEFT JOIN dbo.dim_seller s ON oi.seller_id = s.seller_id
        LEFT JOIN dbo.dim_review r ON oi.order_id = r.order_id;
        COMMIT TRAN;

        EXEC dbo.sp_etl_logger 'sp_firstload_fact_logistics', 'fact_logistics', 'Completed First Load successfully', 'SUCCESS';
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        EXEC dbo.sp_etl_logger 'sp_firstload_fact_logistics', 'fact_logistics', @ErrMsg, 'FAILED';
        THROW;
    END CATCH;
END;
GO