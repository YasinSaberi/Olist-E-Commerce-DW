-- =====================================================================
-- اسکریپت ارائه ابوالفضل - بخش دوم ویدیو (تمرکز بر Dimensions, SCD 2, Facts)
-- =====================================================================

-- ---------------------------------------------------------------------
-- مرحله ۱: اثبات خالی بودن ابعاد انبار داده (دقیقه ۱۵ تا ۲۰)
-- توضیح در ویدیو: "همان‌طور که می‌بینید جداول دایمنشن ما کاملاً خالی هستند."
-- ---------------------------------------------------------------------
USE Olist_DW;
GO

SELECT COUNT(*) AS Dim_Customer_Empty FROM dbo.dim_customer;
SELECT COUNT(*) AS Dim_Product_Empty FROM dbo.dim_product;
SELECT COUNT(*) AS Dim_Seller_Empty FROM dbo.dim_seller;

-- 🔴 [اقدام دستی در ویدیو]: فایل‌های زیر را از پوشه sql/04_etl_pipelines باز کرده و اجرا کنید:
-- 1. 01_load_dim_customer_scd2.sql
-- 2. 02_load_dim_product_scd3.sql
-- 3. 04_load_dim_seller_scd1.sql
-- 4. 05_load_dim_review.sql

-- ---------------------------------------------------------------------
-- اثبات پر شدن ابعاد پس از اجرای ETL
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS Dim_Customer_Filled FROM dbo.dim_customer;
SELECT TOP 5 * FROM dbo.dim_customer; -- نمایش مقادیر پر شده به استاد


-- ---------------------------------------------------------------------
-- مرحله ۲: دموی زنده SCD Type 2 (دقیقه ۲۰ تا ۲۴)
-- توضیح در ویدیو: "حالا می‌خواهیم نشان دهیم که سیستم تاریخچه مشتریان را حفظ می‌کند."
-- ---------------------------------------------------------------------
-- الف) نمایش وضعیت فعلی یک مشتری تستی (مثلاً مشتری با ID شماره ۱)
SELECT customer_sk, customer_id, customer_city, IsCurrent, ValidFrom, ValidTo 
FROM dbo.dim_customer 
WHERE customer_id = 'شناسه_یک_مشتری_را_اینجا_قرار_دهید'; 

-- 🔴 [اقدام دستی در ویدیو]: تب فایل 01_data_validation_and_scd_test.sql را باز کنید.
-- دستور UPDATE سورس را اجرا کنید (مثلاً شهر این مشتری را به 'Tehran' تغییر دهید).
-- 🔴 [اقدام دستی در ویدیو]: به فایل 01_load_dim_customer_scd2.sql برگردید و آن را مجدداً اجرا کنید.

-- ب) نمایش تغییرات (رکورد قبلی بسته شده و رکورد جدید فعال است)
SELECT customer_sk, customer_id, customer_city, IsCurrent, ValidFrom, ValidTo 
FROM dbo.dim_customer 
WHERE customer_id = 'شناسه_همان_مشتری_قبلی'
ORDER BY customer_sk DESC;


-- ---------------------------------------------------------------------
-- مرحله ۳: دیتا مارت‌ها - اثبات خالی بودن و سپس پر شدن (دقیقه ۲۴ تا ۲۸)
-- توضیح در ویدیو: "حالا که دایمنشن‌ها آماده‌اند، فکت فروش و لجستیک را لود می‌کنیم."
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS Fact_Sales_Empty FROM dbo.fact_sales;
SELECT COUNT(*) AS Fact_Logistics_Empty FROM dbo.fact_logistics;

-- 🔴 [اقدام دستی در ویدیو]: فایل‌های 03_load_fact_sales.sql و 06_load_fact_logistics.sql را اجرا کنید.

-- اثبات پر شدن فکت‌ها و نمایش دیتا مارت‌ها به استاد
SELECT COUNT(*) AS Fact_Sales_Filled FROM dbo.fact_sales;
SELECT TOP 5 * FROM dbo.fact_sales;

SELECT COUNT(*) AS Fact_Logistics_Filled FROM dbo.fact_logistics;
SELECT TOP 5 * FROM dbo.fact_logistics;

-- (در دقایق پایانی، ابوالفضل فایل Run_Olist_ETL.bat را برای نمره اضافه نمایش می‌دهد)