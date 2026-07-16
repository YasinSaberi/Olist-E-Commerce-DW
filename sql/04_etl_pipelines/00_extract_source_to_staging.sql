USE Olist_Staging;
GO

CREATE OR ALTER PROCEDURE dbo.sp_extract_source_to_staging
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        TRUNCATE TABLE dbo.stg_customers;
        TRUNCATE TABLE dbo.stg_orders;
        TRUNCATE TABLE dbo.stg_order_items;
        TRUNCATE TABLE dbo.stg_sellers;
        TRUNCATE TABLE dbo.stg_products;
        TRUNCATE TABLE dbo.stg_geolocation;
        TRUNCATE TABLE dbo.stg_reviews;

        
        INSERT INTO dbo.stg_customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
        SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state
        FROM Olist_Source.dbo.customers;

        INSERT INTO dbo.stg_orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
        SELECT order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date
        FROM Olist_Source.dbo.orders;

        INSERT INTO dbo.stg_order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
        SELECT order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value
        FROM Olist_Source.dbo.order_items;

        INSERT INTO dbo.stg_sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
        SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state
        FROM Olist_Source.dbo.sellers;

        INSERT INTO dbo.stg_products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
        SELECT product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm
        FROM Olist_Source.dbo.products;

        INSERT INTO dbo.stg_geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
        SELECT geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state
        FROM Olist_Source.dbo.geolocation;

        INSERT INTO dbo.stg_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
        SELECT review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp
        FROM Olist_Source.dbo.reviews;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
GO
