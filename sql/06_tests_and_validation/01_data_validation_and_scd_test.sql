-- ==============================================================================
-- Script Name: 01_data_validation_and_scd_test.sql
-- Description: Comprehensive test suite to validate data integrity, verify 
--              ETL row counts, and demonstrate SCD Type 2 logic.
-- ==============================================================================

USE Olist_DW;
GO

-- ------------------------------------------------------------------------------
-- TEST 1: Audit Log Check
-- Purpose: Ensures the master orchestration ran successfully and logged all steps 
--          without any silent failures.
-- ------------------------------------------------------------------------------
PRINT '--- RUNNING TEST 1: AUDIT LOG CHECK ---';

SELECT * 
FROM Olist_DW.dbo.etl_audit_log 
ORDER BY log_id ASC;


-- ------------------------------------------------------------------------------
-- TEST 2: Row Count Verification (Data Loss / Duplication Check)
-- Purpose: Compares total row counts across Source, Staging, and DW layers 
--          to ensure 100% data migration accuracy.
-- ------------------------------------------------------------------------------
PRINT '--- RUNNING TEST 2: ROW COUNT VERIFICATION ---';

SELECT 'Source' AS Layer, COUNT(*) AS Total_Rows FROM Olist_Source.dbo.order_items
UNION ALL
SELECT 'Staging' AS Layer, COUNT(*) AS Total_Rows FROM Olist_Staging.dbo.stg_order_items
UNION ALL
SELECT 'Data Warehouse' AS Layer, COUNT(*) AS Total_Rows FROM Olist_DW.dbo.fact_sales;


-- ------------------------------------------------------------------------------
-- TEST 3: Dimension Integrity & Unknown Record Check
-- Purpose: Verifies the existence of the default '-1' (Unknown) record required 
--          for enforcing referential integrity with Fact tables.
-- ------------------------------------------------------------------------------
PRINT '--- RUNNING TEST 3: UNKNOWN RECORD VERIFICATION ---';

SELECT * 
FROM Olist_DW.dbo.dim_customer 
WHERE customer_sk = -1;


-- ------------------------------------------------------------------------------
-- TEST 4: SCD Type 2 Simulation (Historical Tracking)
-- Purpose: Simulates a source data update to verify that the dimension preserves 
--          history (ValidTo) and creates a new active surrogate key.
-- ------------------------------------------------------------------------------
PRINT '--- RUNNING TEST 4: SCD TYPE 2 SIMULATION ---';

-- Step 4.1: Update a specific customer's city in the raw source system
UPDATE Olist_Source.dbo.customers
SET customer_city = 'tehran'
WHERE customer_unique_id = '0000366f3b9a7992bf8c76cfdf3221e2';

-- Step 4.2: Execute the incremental ETL pipeline to capture the change automatically
EXEC Olist_DW.dbo.sp_master_etl_load @IsFirstLoad = 0;

-- Step 4.3: Verify the dimension table for both the expired and the new active records
SELECT 
    customer_sk, 
    customer_unique_id, 
    customer_city, 
    IsCurrent, 
    ValidFrom, 
    ValidTo
FROM Olist_DW.dbo.dim_customer
WHERE customer_unique_id = '0000366f3b9a7992bf8c76cfdf3221e2'
ORDER BY customer_sk ASC;