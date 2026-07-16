# Olist Data Warehouse: Architecture & Design

## 1. System Architecture
The data warehouse is built using a classic 3-tier architecture implemented entirely within Microsoft SQL Server:
1. **Olist_Source:** The operational database representing the raw Kaggle dataset.
2. **Olist_Staging (SA):** The landing zone for untransformed data, ensuring the source system is not locked during complex transformations.
3. **Olist_DW:** The analytical database utilizing a Star Schema design.

## 2. Enterprise Data Bus & Data Marts
The project serves two distinct business processes (Data Marts) sharing conformed dimensions:
*   **Sales Data Mart:** Centered around `fact_sales` to analyze revenue, pricing behavior, and customer purchasing patterns across time and geography.
*   **Logistics Data Mart:** Centered around `fact_logistics` to monitor delivery performance, shipping delays, and freight costs associated with sellers and customer reviews.

## 3. Star Schema ER Diagram

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

    %% Relationships
    dim_customer ||--o{ fact_sales : "analyzed by"
    dim_product ||--o{ fact_sales : "contains"
    dim_date ||--o{ fact_sales : "purchased on"

    dim_seller ||--o{ fact_logistics : "fulfilled by"
    dim_review ||--o{ fact_logistics : "rated by"
    dim_date ||--o{ fact_logistics : "purchased on"
