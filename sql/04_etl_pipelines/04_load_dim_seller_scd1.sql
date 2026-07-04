USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_dim_seller_scd1
AS
BEGIN
    -- Update existing records (SCD Type 1: Overwrite)
    UPDATE dw
    SET dw.seller_city = stg.seller_city,
        dw.seller_state = stg.seller_state
    FROM dbo.dim_seller dw
    INNER JOIN Olist_Staging.dbo.stg_sellers stg 
        ON dw.seller_id = stg.seller_id;

    -- Insert entirely new sellers
    INSERT INTO dbo.dim_seller (seller_id, seller_city, seller_state)
    SELECT 
        stg.seller_id, 
        stg.seller_city, 
        stg.seller_state
    FROM Olist_Staging.dbo.stg_sellers stg
    WHERE NOT EXISTS (
        SELECT 1 
        FROM dbo.dim_seller dw 
        WHERE dw.seller_id = stg.seller_id
    );
END;
GO