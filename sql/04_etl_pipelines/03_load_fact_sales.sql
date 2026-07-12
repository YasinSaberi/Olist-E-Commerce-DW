USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_fact_sales
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.fact_sales (
            order_id, 
            order_item_id, 
            customer_sk, 
            product_sk, 
            order_date_sk, 
            price, 
            freight_value
        )
        SELECT 
            oi.order_id,
            oi.order_item_id,
            c.customer_sk,
            p.product_sk,
            CAST(CONVERT(VARCHAR(8), o.order_purchase_timestamp, 112) AS INT) AS order_date_sk,
            oi.price,
            oi.freight_value
        FROM Olist_Staging.dbo.stg_order_items oi
        INNER JOIN Olist_Staging.dbo.stg_orders o 
            ON oi.order_id = o.order_id
        INNER JOIN dbo.dim_customer c 
            ON o.customer_id = c.customer_id AND c.IsCurrent = 1
        INNER JOIN dbo.dim_product p 
            ON oi.product_id = p.product_id -- SCD Type 3 does not use IsCurrent
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dbo.fact_sales f 
            WHERE f.order_id = oi.order_id 
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