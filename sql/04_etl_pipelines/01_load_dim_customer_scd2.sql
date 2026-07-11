USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_dim_customer_scd2
AS
BEGIN
    SET NOCOUNT ON;
    -- INJECTED LOGGING
    EXEC dbo.sp_etl_logger 'sp_load_dim_customer_scd2', 'dim_customer', 'Starting SCD2 Incremental Load', 'RUNNING';

    DECLARE @UpdatedRecords TABLE (
        action_name NVARCHAR(10), customer_id NVARCHAR(50), customer_unique_id NVARCHAR(50), 
        customer_zip_code_prefix VARCHAR(20), customer_city NVARCHAR(50), customer_state NVARCHAR(50)
    );

    BEGIN TRY
        ;WITH DeduplicatedSource AS (
            SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state,
                   ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY LoadDate DESC) AS rn
            FROM Olist_Staging.dbo.stg_customers
        )
        BEGIN TRAN;

        MERGE dbo.dim_customer AS target
        USING (SELECT * FROM DeduplicatedSource WHERE rn = 1) AS source
        ON (target.customer_unique_id = source.customer_unique_id)
        
        WHEN MATCHED AND target.IsCurrent = 1 AND (
            ISNULL(target.customer_zip_code_prefix, '') <> ISNULL(source.customer_zip_code_prefix, '') OR
            ISNULL(target.customer_city, '') <> ISNULL(source.customer_city, '') OR
            ISNULL(target.customer_state, '') <> ISNULL(source.customer_state, '')
        ) THEN 
            UPDATE SET target.IsCurrent = 0, target.ValidTo = GETDATE()
            
        WHEN NOT MATCHED BY TARGET THEN 
            INSERT (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, IsCurrent, ValidFrom, ValidTo)
            VALUES (source.customer_id, source.customer_unique_id, source.customer_zip_code_prefix, source.customer_city, source.customer_state, 1, GETDATE(), NULL)
            
        OUTPUT $action, source.customer_id, source.customer_unique_id, source.customer_zip_code_prefix, source.customer_city, source.customer_state
        INTO @UpdatedRecords (action_name, customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

        INSERT INTO dbo.dim_customer (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, IsCurrent, ValidFrom, ValidTo)
        SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, 1, GETDATE(), NULL
        FROM @UpdatedRecords WHERE action_name = 'UPDATE';

        COMMIT TRAN;
        
        -- INJECTED LOGGING
        EXEC dbo.sp_etl_logger 'sp_load_dim_customer_scd2', 'dim_customer', 'SCD2 Load Completed Successfully', 'SUCCESS';

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        -- INJECTED LOGGING (Post-Rollback)
        EXEC dbo.sp_etl_logger 'sp_load_dim_customer_scd2', 'dim_customer', @ErrMsg, 'FAILED';
        THROW;
    END CATCH;
END;
GO