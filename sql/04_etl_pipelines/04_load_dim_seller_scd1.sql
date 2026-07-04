USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.Load_DimSeller_SCD1
AS
BEGIN
    SET NOCOUNT ON;

    -- استفاده از دستور MERGE برای مدیریت مقایسه استیجینگ و جدول بعد (Dimension)
    MERGE dbo.DimSeller AS Target
    USING (
        SELECT DISTINCT 
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state
        FROM dbo.stg_sellers -- دقیقاً نام جدولی که خودت ساختی
    ) AS Source
    ON (Target.SellerBusinessID = Source.seller_id) -- جفت کردن بر اساس شناسه بیزینسی فروشنده
    
    -- SCD Type 1: اگر فروشنده وجود داشت و اطلاعاتش تغییر کرده بود، روی قبلی اوررایت کن
    WHEN MATCHED AND (
        Target.ZipCode <> Source.seller_zip_code_prefix 
        OR Target.City <> Source.seller_city 
        OR Target.[State] <> Source.seller_state
    ) THEN
        UPDATE SET 
            Target.ZipCode = Source.seller_zip_code_prefix,
            Target.City = Source.seller_city,
            Target.[State] = Source.seller_state,
            Target.LoadDate = GETDATE() -- بروزرسانی زمان آخرین تغییر

    -- اگر فروشنده جدید بود، یک ردیف جدید درج کن
    WHEN NOT MATCHED THEN
        INSERT (SellerBusinessID, ZipCode, City, [State], LoadDate)
        VALUES (Source.seller_id, Source.seller_zip_code_prefix, Source.seller_city, Source.seller_state, GETDATE());
END;
GO