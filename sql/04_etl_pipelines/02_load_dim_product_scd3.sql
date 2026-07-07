USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_dim_product_scd3
AS
BEGIN
    UPDATE target
    SET target.previous_product_category_name = target.product_category_name,
        target.product_category_name = source.product_category_name
    FROM dbo.dim_product AS target
    INNER JOIN Olist_Staging.dbo.stg_products AS source
        ON target.product_id = source.product_id
    WHERE target.product_category_name <> source.product_category_name
       OR (target.product_category_name IS NULL AND source.product_category_name IS NOT NULL);

    INSERT INTO dbo.dim_product (product_id, product_category_name, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
    SELECT 
        source.product_id, 
        source.product_category_name, 
        source.product_weight_g, 
        source.product_length_cm, 
        source.product_height_cm, 
        source.product_width_cm
    FROM Olist_Staging.dbo.stg_products AS source
    WHERE NOT EXISTS (
        SELECT 1 
        FROM dbo.dim_product target 
        WHERE target.product_id = source.product_id
    );
END;
GO