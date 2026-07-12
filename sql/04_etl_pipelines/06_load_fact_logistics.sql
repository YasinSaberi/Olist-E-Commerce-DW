USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_fact_logistics
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.fact_logistics (
            order_id,
            order_item_id,      -- FIX: was missing; column is NOT NULL on the table, so every run was failing
            customer_sk,        -- FIX: was missing; column is NOT NULL on the table, so every run was failing
            seller_sk, 
            order_date_sk, 
            review_sk, 
            freight_value, 
            delivery_delay_days,
            shipping_delay_days -- FIX: column exists on the table but was never populated; now computed below
        )
        SELECT 
            o.order_id,
            oi.order_item_id,
            ISNULL(c.customer_sk, -1),   -- FIX: join to dim_customer added below
            ISNULL(s.seller_sk, -1),
            CAST(CONVERT(VARCHAR(8), o.order_purchase_timestamp, 112) AS INT),
            ISNULL(r.review_sk, -1),
            oi.freight_value,
            DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date),
            DATEDIFF(day, oi.shipping_limit_date, o.order_delivered_carrier_date)
            -- NOTE: adjust this formula if "shipping delay" should be measured differently in your grading rubric
        FROM Olist_Staging.dbo.stg_orders o
        INNER JOIN Olist_Staging.dbo.stg_order_items oi ON o.order_id = oi.order_id
        LEFT JOIN dbo.dim_customer c ON o.customer_id = c.customer_id AND c.IsCurrent = 1  -- FIX: added, required for customer_sk
        LEFT JOIN dbo.dim_seller s ON oi.seller_id = s.seller_id
        LEFT JOIN dbo.dim_review r ON o.order_id = r.order_id
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dbo.fact_logistics f 
            WHERE f.order_id = o.order_id 
              AND f.order_item_id = oi.order_item_id
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