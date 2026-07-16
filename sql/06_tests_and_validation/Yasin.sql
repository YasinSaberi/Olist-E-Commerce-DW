-- SEC 1
USE Olist_Source;
GO

SELECT COUNT(*) AS Total_Order_Items_Over_1_Million 
FROM dbo.order_items;


-- SEC 2
USE Olist_Staging;
GO

SELECT COUNT(*) AS Stg_Orders_Empty FROM dbo.stg_orders;
SELECT COUNT(*) AS Stg_Order_Items_Empty FROM dbo.stg_order_items;


EXEC dbo.sp_extract_source_to_staging;


-- SEC 3
SELECT COUNT(*) AS Stg_Orders_Filled FROM dbo.stg_orders;
SELECT TOP 5 * FROM dbo.stg_orders; 


-- SEC 4

USE Olist_DW;
GO

SELECT COUNT(*) AS Fact_Sales_Empty FROM dbo.fact_sales;


-- SEC 5
SELECT COUNT(*) AS Fact_Sales_Filled FROM dbo.fact_sales;
SELECT TOP 5 * FROM dbo.fact_sales;