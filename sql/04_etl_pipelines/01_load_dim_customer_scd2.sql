USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_dim_customer_scd2
AS
BEGIN
    INSERT INTO dbo.dim_customer (
        customer_id, 
        customer_unique_id, 
        customer_zip_code_prefix, 
        customer_city, 
        customer_state, 
        IsCurrent, 
        ValidFrom, 
        ValidTo
    )
    SELECT 
        customer_id, 
        customer_unique_id, 
        customer_zip_code_prefix, 
        customer_city, 
        customer_state, 
        1, 
        GETDATE(), 
        NULL
    FROM (
        MERGE dbo.dim_customer AS target
        USING Olist_Staging.dbo.stg_customers AS source
        ON (target.customer_id = source.customer_id)
        
        WHEN MATCHED AND target.IsCurrent = 1 AND (
            target.customer_zip_code_prefix <> source.customer_zip_code_prefix OR
            target.customer_city <> source.customer_city OR
            target.customer_state <> source.customer_state
        ) THEN 
            UPDATE SET target.IsCurrent = 0, target.ValidTo = GETDATE()
            
        -- Insert completely new customers
        WHEN NOT MATCHED BY TARGET THEN 
            INSERT (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, IsCurrent, ValidFrom, ValidTo)
            VALUES (source.customer_id, source.customer_unique_id, source.customer_zip_code_prefix, source.customer_city, source.customer_state, 1, GETDATE(), NULL)
                    OUTPUT $action, source.customer_id, source.customer_unique_id, source.customer_zip_code_prefix, source.customer_city, source.customer_state
    ) AS changes (action, customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
    WHERE action = 'UPDATE';
END;
GO