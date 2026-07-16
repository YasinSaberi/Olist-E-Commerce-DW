# مستند نگاشت و انتقال داده‌ها (Olist ETL Mapping)

این مستند قوانین استخراج، تبدیل و بارگذاری (ETL) را که برای انتقال داده‌ها از سیستم عملیاتی خام (Source) به لایه میانی (Staging) و در نهایت به انبار داده (Data Warehouse) اعمال شده‌اند، تشریح می‌کند.

## فلوچارت کلی پایپ‌لاین ETL

```mermaid
graph LR
    A[(Olist_Source<br/>دیتابیس خام)] -->|Extract & Truncate<br/>انتقال مستقیم 1:1| B[(Olist_Staging<br/>لایه میانی)]
    B -->|Transform & Load<br/>تولید کلید و مدیریت تاریخچه| C[(Olist_DW<br/>انبار داده)]
۱. نگاشت از لایه منبع به استیجینگ (Source to Staging)استراتژی: استخراج کامل (Full Extract) و Truncate-Loadهدف: استخراج داده‌ها از سیستم عملیاتی و انتقال به محیط Staging بدون اعمال تغییرات سنگین، جهت به حداقل رساندن بار پردازشی (Overhead) روی سیستم مبدا.جدول هدف در لایه Olist_Stagingجدول مبدا در Olist_Sourceعملیات / منطق انتقال (Transformation)stg_customerscustomersدرج مستقیم داده‌ها (1:1 Direct Insert)stg_ordersordersدرج مستقیم داده‌ها (1:1 Direct Insert)stg_order_itemsorder_itemsدرج مستقیم داده‌ها (1:1 Direct Insert)stg_sellerssellersدرج مستقیم داده‌ها (1:1 Direct Insert)stg_productsproductsدرج مستقیم. هندل کردن خطای تایپی lenght در دیتاست اصلی Kaggle.stg_reviewsreviewsدرج مستقیم داده‌ها (1:1 Direct Insert)۲. نگاشت ابعاد انبار داده (Staging to Dimensions)استراتژی: تخصیص کلید جایگزین (Surrogate Key) و مدیریت ابعاد به کندی متغیر (SCD).جدول بُعد (Dimension)جدول لایه استیجینگنوع SCDمنطق نگاشت و تبدیلdim_customerstg_customersType 2نگاشت داده‌های جغرافیایی مشتری. تغییر در شهر یا استان باعث ایجاد یک سطر جدید می‌شود. مدیریت تاریخچه با فیلدهای IsCurrent، ValidFrom و ValidTo.dim_productstg_productsType 3نگاشت ویژگی‌های محصول. در صورت تغییر دسته‌بندی، سطر جدید ایجاد نمی‌شود بلکه فیلد جدیدی برای حفظ تاریخچه در نظر گرفته می‌شود.dim_sellerstg_sellersType 1به‌روزرسانی اطلاعات فروشنده با استفاده از دستور MERGE. داده‌های جدید جایگزین قبلی می‌شوند (بدون حفظ تاریخچه).dim_reviewstg_reviewsStaticنگاشت مستقیم. به منظور حفظ یکپارچگی ارجاعی (Referential Integrity)، یک رکورد پیش‌فرض با شناسه -1 برای داده‌های ناموجود تزریق می‌شود.dim_dateتولید رویه‌ایN/Aتولید خودکار توسط حلقه WHILE در T-SQL از سال ۲۰۱۶ تا ۲۰۱۹. محاسبه روزهای تعطیل با تابع DATEPART.۳. نگاشت فکت‌ها و دیتا مارت‌ها (Staging to Facts)استراتژی: بارگذاری افزایشی تکرارپذیر (Idempotent Incremental Load) و اعمال کلیدهای خارجی (Foreign Keys).جدول فکت (Fact Table)جداول لایه استیجینگمنطق نگاشت و تبدیلfact_salesstg_orders, stg_order_itemsاستخراج SK از جداول ابعاد. تبدیل order_purchase_timestamp به کلید صحیح order_date_sk. استفاده از مکانیزم WHERE NOT EXISTS برای جلوگیری از درج رکوردهای تکراری.fact_logisticsstg_orders, stg_order_itemsمحاسبه تاخیر با فرمول: DATEDIFF(day, estimated, actual). جایگزینی مقادیر NULL در فروشنده یا نظر با رکورد -1 جهت حفظ یکپارچگی دیتا مارت.
---

### ۲. مستند طراحی انبار داده (DW Design Document)
**فایل:** `docs/Data_Warehouse_Design.md`

```markdown
# مستند معماری و طراحی انبار داده (Olist DW Architecture)

## ۱. معماری سیستم (System Architecture)
این انبار داده بر اساس معماری استاندارد ۳ لایه‌ای (3-Tier Architecture) و به طور کامل در محیط Microsoft SQL Server پیاده‌سازی شده است:

```mermaid
graph TD
    subgraph Operational Environment
        S[(Olist_Source<br/>Kaggle CSVs)]
    end
    
    subgraph Staging Area
        SA[(Olist_Staging<br/>Landing Zone)]
    end
    
    subgraph Analytical Environment (DW)
        DW[(Olist_DW<br/>Star Schema)]
        DM1[Sales Data Mart<br/>مارت فروش]
        DM2[Logistics Data Mart<br/>مارت لجستیک]
        DW --> DM1
        DW --> DM2
    end
    
    S -->|00_extract_proc| SA
    SA -->|ETL Master Orchestrator| DW
۱. لایه Olist_Source: دیتابیس عملیاتی که نمایانگر داده‌های خام و توزیع‌شده است.۲. لایه Olist_Staging (SA): منطقه فرود (Landing Zone) داده‌ها. این لایه تضمین می‌کند که سیستم عملیاتی در طول فرآیندهای سنگین تبدیل داده (Transformation) قفل نشود.۳. لایه Olist_DW: دیتابیس تحلیلی اصلی که با استفاده از مدل‌سازی ابعادی (Dimensional Modeling) طراحی شده است.۲. دیتا مارت‌ها (Data Marts)این پروژه دو فرآیند تجاری مجزا را از طریق دو دیتا مارت که دارای ابعاد مشترک (Conformed Dimensions) هستند، پوشش می‌دهد:دیتا مارت فروش (Sales): متمرکز بر جدول fact_sales جهت تحلیل درآمد، رفتار قیمت‌گذاری و الگوهای خرید مشتریان در طول زمان و مکان.دیتا مارت لجستیک (Logistics): متمرکز بر جدول fact_logistics جهت نظارت بر عملکرد تحویل، تاخیر در ارسال و هزینه‌های حمل‌ونقل کالا.۳. نمودار موجودیت-رابطه مدل ستاره‌ای (Star Schema ER Diagram)Code snippeterDiagram
    fact_sales {
        int sales_sk PK
        varchar order_id
        int order_item_id
        int customer_sk FK
        int product_sk FK
        int order_date_sk FK
        decimal price
        decimal freight_value
    }

    fact_logistics {
        int logistics_sk PK
        varchar order_id
        int seller_sk FK
        int order_date_sk FK
        int review_sk FK
        decimal freight_value
        int delivery_delay_days
    }

    dim_customer {
        int customer_sk PK
        varchar customer_id
        varchar customer_city
        bit IsCurrent
    }

    dim_product {
        int product_sk PK
        varchar product_id
        varchar product_category_name
    }

    dim_seller {
        int seller_sk PK
        varchar seller_id
        varchar seller_city
    }

    dim_review {
        int review_sk PK
        int review_score
    }

    dim_date {
        int date_sk PK
        date full_date
        int is_weekend
    }

    %% روابط جداول (Relationships)
    dim_customer ||--o{ fact_sales : "analyzed by"
    dim_product ||--o{ fact_sales : "contains"
    dim_date ||--o{ fact_sales : "purchased on"

    dim_seller ||--o{ fact_logistics : "fulfilled by"
    dim_review ||--o{ fact_logistics : "rated by"
    dim_date ||--o{ fact_logistics : "purchased on"
(توجه: برای مشاهده نقشه کامل یکپارچگی ارجاعی، به محدودیت‌های کلید اصلی و کلید خارجی در کدهای SQL مراجعه شود).
