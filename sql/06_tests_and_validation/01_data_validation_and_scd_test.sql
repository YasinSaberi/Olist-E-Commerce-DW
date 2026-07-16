USE Olist_DW;
GO

PRINT '--- RUNNING TEST 1: AUDIT LOG CHECK ---';

SELECT * 
FROM Olist_DW.dbo.etl_audit_log 
ORDER BY log_id ASC;

PRINT '--- RUNNING TEST 2: ROW COUNT VERIFICATION ---';

SELECT 'Source' AS Layer, COUNT(*) AS Total_Rows FROM Olist_Source.dbo.order_items
UNION ALL
SELECT 'Staging' AS Layer, COUNT(*) AS Total_Rows FROM Olist_Staging.dbo.stg_order_items
UNION ALL
SELECT 'Data Warehouse' AS Layer, COUNT(*) AS Total_Rows FROM Olist_DW.dbo.fact_sales;

PRINT '--- RUNNING TEST 3: UNKNOWN RECORD VERIFICATION ---';

SELECT * 
FROM Olist_DW.dbo.dim_customer 
WHERE customer_sk = -1;

PRINT '--- RUNNING TEST 4: SCD TYPE 2 SIMULATION ---';

UPDATE Olist_Source.dbo.customers
SET customer_city = 'tehran'
WHERE customer_unique_id = '0000366f3b9a7992bf8c76cfdf3221e2';

EXEC Olist_DW.dbo.sp_master_etl_load @IsFirstLoad = 0;

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