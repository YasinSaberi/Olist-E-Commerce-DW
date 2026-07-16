# مستند معماری و طراحی انبار داده (Olist DW Architecture)

## ۱. معماری سیستم (System Architecture)
این انبار داده بر اساس معماری استاندارد ۳ لایه‌ای (3-Tier Architecture) و به طور کامل در محیط Microsoft SQL Server پیاده‌سازی شده است:

```mermaid
graph TD
    subgraph Operational_Environment [Operational Environment]
        S[(Olist_Source<br/>Kaggle CSVs)]
    end
    
    subgraph Staging_Area [Staging Area]
        SA[(Olist_Staging<br/>Landing Zone)]
    end
    
    subgraph Analytical_Environment [Analytical Environment DW]
        DW[(Olist_DW<br/>Star Schema)]
        DM1[Sales Data Mart<br/>مارت فروش]
        DM2[Logistics Data Mart<br/>مارت لجستیک]
        DW --> DM1
        DW --> DM2
    end
    
    S -->|00_extract_proc| SA
    SA -->|ETL Master Orchestrator| DW
```

۱. **لایه Olist_Source:** دیتابیس عملیاتی که نمایانگر داده‌های خام و توزیع‌شده است.
۲. **لایه Olist_Staging (SA):** منطقه فرود (Landing Zone) داده‌ها. این لایه تضمین می‌کند که سیستم عملیاتی در طول فرآیندهای سنگین تبدیل داده (Transformation) قفل نشود.
۳. **لایه Olist_DW:** دیتابیس تحلیلی اصلی که با استفاده از مدل‌سازی ابعادی (Dimensional Modeling) طراحی شده است.

## ۲. دیتا مارت‌ها (Data Marts)
این پروژه دو فرآیند تجاری مجزا را از طریق دو دیتا مارت که دارای ابعاد مشترک (Conformed Dimensions) هستند، پوشش می‌دهد:
*   **دیتا مارت فروش (Sales):** متمرکز بر جدول `fact_sales` جهت تحلیل درآمد، رفتار قیمت‌گذاری و الگوهای خرید مشتریان در طول زمان و مکان.
*   **دیتا مارت لجستیک (Logistics):** متمرکز بر جدول `fact_logistics` جهت نظارت بر عملکرد تحویل، تاخیر در ارسال و هزینه‌های حمل‌ونقل کالا.

## ۳. نمودار موجودیت-رابطه مدل ستاره‌ای (Star Schema ER Diagram)

```mermaid
erDiagram
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
```
*(توجه: برای مشاهده نقشه کامل یکپارچگی ارجاعی، به محدودیت‌های کلید اصلی و کلید خارجی در کدهای SQL مراجعه شود).*
