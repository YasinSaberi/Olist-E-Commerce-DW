-- =====================================================================
-- Abolfazl's Execution Script (Dimensions, SCD2 Demo, and Facts)
-- =====================================================================

USE Olist_DW;
GO

-- ---------------------------------------------------------------------
-- 1. Check if Dimension Tables are Empty
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS Dim_Customer_Empty FROM dbo.dim_customer;
SELECT COUNT(*) AS Dim_Product_Empty FROM dbo.dim_product;
SELECT COUNT(*) AS Dim_Seller_Empty FROM dbo.dim_seller;


-- [MANUAL ACTION]: Execute Dimension Load Scripts Here


-- ---------------------------------------------------------------------
-- 2. Verify Dimension Tables are Filled
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS Dim_Customer_Filled FROM dbo.dim_customer;
SELECT TOP 5 * FROM dbo.dim_customer;


-- ---------------------------------------------------------------------
-- 3. SCD Type 2 Demo (Before Source Update)
-- ---------------------------------------------------------------------
SELECT customer_sk, customer_id, customer_city, IsCurrent, ValidFrom, ValidTo 
FROM dbo.dim_customer 
WHERE customer_id = '0000366f3b9a7992bf8c76cfdf3221e2'; 


-- [MANUAL ACTION]: 
-- 1. Run UPDATE statement in Olist_Source for this customer.
-- 2. Re-run Dim Customer ETL Script.


-- ---------------------------------------------------------------------
-- 4. SCD Type 2 Demo (After Source Update)
-- ---------------------------------------------------------------------
SELECT customer_sk, customer_id, customer_city, IsCurrent, ValidFrom, ValidTo 
FROM dbo.dim_customer 
WHERE customer_id = '0000366f3b9a7992bf8c76cfdf3221e2'
ORDER BY customer_sk DESC;


-- ---------------------------------------------------------------------
-- 5. Check if Fact Tables are Empty
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS Fact_Sales_Empty FROM dbo.fact_sales;
SELECT COUNT(*) AS Fact_Logistics_Empty FROM dbo.fact_logistics;


-- [MANUAL ACTION]: Execute Fact Load Scripts (Sales & Logistics) Here


-- ---------------------------------------------------------------------
-- 6. Verify Fact Tables are Filled (Covers Yasin's SEC 5)
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS Fact_Sales_Filled FROM dbo.fact_sales;
SELECT TOP 5 * FROM dbo.fact_sales;

SELECT COUNT(*) AS Fact_Logistics_Filled FROM dbo.fact_logistics;
SELECT TOP 5 * FROM dbo.fact_logistics;