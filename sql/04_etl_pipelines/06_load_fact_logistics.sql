USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_fact_logistics
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- 1. THIS IS WHERE YOUR ACTUAL INSERT STATEMENT GOES
        INSERT INTO dbo.fact_logistics (
            order_id, 
            seller_sk, 
            order_date_sk, 
            review_sk, 
            freight_value, 
            delivery_delay_days
            -- (Plus whatever other columns you have in your table)
        )
        -- 2. THIS IS WHERE YOUR ACTUAL SELECT STATEMENT GOES
        SELECT 
            o.order_id,
            ISNULL(s.seller_sk, -1),
            CAST(CONVERT(VARCHAR(8), o.order_purchase_timestamp, 112) AS INT),
            ISNULL(r.review_sk, -1),
            oi.freight_value,
            DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date)
        FROM Olist_Staging.dbo.stg_orders o
        INNER JOIN Olist_Staging.dbo.stg_order_items oi ON o.order_id = oi.order_id
        LEFT JOIN dbo.dim_seller s ON oi.seller_id = s.seller_id
        LEFT JOIN dbo.dim_review r ON o.order_id = r.order_id
        
        -- 3. THIS IS THE NEW OPTIMIZATION TO PREVENT DUPLICATES
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dbo.fact_logistics f 
            WHERE f.order_id = o.order_id 
              AND f.order_item_id = oi.order_item_id -- Include this if logistics tracks item-level granularity
        );

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
GO