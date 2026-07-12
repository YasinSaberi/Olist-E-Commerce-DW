USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_master_etl_load
    @IsFirstLoad BIT = 0 
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_etl_logger 'sp_master_etl_load', 'DATABASE', 'Starting Master Orchestration', 'RUNNING';

    BEGIN TRY
        EXEC dbo.sp_etl_logger 'sp_master_etl_load', 'DATABASE', 'Extracting Source to Staging', 'INFO';
        EXEC Olist_Staging.dbo.sp_extract_source_to_staging;

        EXEC dbo.sp_load_dim_customer_scd2;
        EXEC dbo.sp_load_dim_product_scd3;
        EXEC dbo.sp_load_dim_seller_scd1;
        EXEC dbo.sp_load_dim_review;
        
        IF @IsFirstLoad = 1
        BEGIN
            EXEC dbo.sp_etl_logger 'sp_master_etl_load', 'DATABASE', 'Executing First Load Path', 'INFO';
            EXEC dbo.sp_firstload_fact_sales;
            EXEC dbo.sp_firstload_fact_logistics;
        END
        ELSE
        BEGIN
            EXEC dbo.sp_etl_logger 'sp_master_etl_load', 'DATABASE', 'Executing Incremental Path', 'INFO';
            EXEC dbo.sp_load_fact_sales;
            EXEC dbo.sp_load_fact_logistics;
        END

        EXEC dbo.sp_etl_logger 'sp_master_etl_load', 'DATABASE', 'Master Orchestration Completed', 'SUCCESS';
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        EXEC dbo.sp_etl_logger 'sp_master_etl_load', 'DATABASE', @ErrMsg, 'CRITICAL FAILURE';
        THROW;
    END CATCH;
END;
GO