USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_dim_customer_scd2
AS
BEGIN
    SET NOCOUNT ON; -- Prevents network spam from row counts

    -- 1. Create a table variable to temporarily hold the SCD2 updates in memory
    DECLARE @UpdatedRecords TABLE (
        action_name NVARCHAR(10),
        customer_id NVARCHAR(50), 
        customer_unique_id NVARCHAR(50), 
        customer_zip_code_prefix INT, 
        customer_city NVARCHAR(50), 
        customer_state NVARCHAR(50)
    );

    BEGIN TRY
        -- Start the transaction. If anything fails after this point, the entire block is undone.
        BEGIN TRAN;

        -- 2. Perform the MERGE and output the results into the table variable
        MERGE dbo.dim_customer AS target
        USING Olist_Staging.dbo.stg_customers AS source
        ON (target.customer_id = source.customer_id)
        
        WHEN MATCHED AND target.IsCurrent = 1 AND (
            target.customer_zip_code_prefix <> source.customer_zip_code_prefix OR
            target.customer_city <> source.customer_city OR
            target.customer_state <> source.customer_state
        ) THEN 
            UPDATE SET target.IsCurrent = 0, target.ValidTo = GETDATE()
            
        WHEN NOT MATCHED BY TARGET THEN 
            INSERT (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, IsCurrent, ValidFrom, ValidTo)
            VALUES (source.customer_id, source.customer_unique_id, source.customer_zip_code_prefix, source.customer_city, source.customer_state, 1, GETDATE(), NULL)
            
        OUTPUT $action, source.customer_id, source.customer_unique_id, source.customer_zip_code_prefix, source.customer_city, source.customer_state
        INTO @UpdatedRecords (action_name, customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

        -- 3. Safely insert the new active records from memory into the dimension
        INSERT INTO dbo.dim_customer (
            customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, IsCurrent, ValidFrom, ValidTo
        )
        SELECT 
            customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, 1, GETDATE(), NULL
        FROM @UpdatedRecords
        WHERE action_name = 'UPDATE';

        -- If the engine reaches this line, everything worked. Save it permanently.
        COMMIT TRAN;

    END TRY
    BEGIN CATCH
        -- If any error occurs, destroy the partial transaction to protect the database.
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        
        -- Throw the error back to SSMS so you can see why it failed.
        THROW;
    END CATCH;
END;
GO