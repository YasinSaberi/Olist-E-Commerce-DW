# Olist Data Warehouse: ETL Mapping Document

This document outlines the extraction, transformation, and loading (ETL) rules applied to migrate data from the raw Olist source system to the Staging area, and finally into the Star Schema Data Warehouse.

## 1. Source to Staging (SA) Mapping
**Strategy:** Full Extract & Truncate-Load
**Purpose:** To extract data from the operational source and land it into the staging environment without heavy transformations, minimizing the load on the source system.

| Source Table (`Olist_Source`) | Target Table (`Olist_Staging`) | Action / Transformation |
| :--- | :--- | :--- |
| `customers` | `stg_customers` | 1:1 Direct Insert |
| `orders` | `stg_orders` | 1:1 Direct Insert |
| `order_items` | `stg_order_items` | 1:1 Direct Insert |
| `sellers` | `stg_sellers` | 1:1 Direct Insert |
| `products` | `stg_products` | 1:1 Direct Insert (Handled `lenght` typo in source dataset) |
| `reviews` | `stg_reviews` | 1:1 Direct Insert |

---

## 2. Staging to Dimension Mapping (Data Warehouse)
**Strategy:** Surrogate Key Assignment & Slowly Changing Dimensions (SCD)

| Target Dimension | Source Staging Table(s) | SCD Type | Mapping Logic & Transformations |
| :--- | :--- | :--- | :--- |
| **`dim_customer`** | `stg_customers` | Type 2 | Maps geographic data. Changes in `customer_city` or `customer_state` trigger a new record. Managed via `IsCurrent`, `ValidFrom`, and `ValidTo` flags. |
| **`dim_product`** | `stg_products` | Type 3 | Maps product attributes. Historical attributes are tracked via new columns (if category definitions change) rather than new rows. |
| **`dim_seller`** | `stg_sellers` | Type 1 | Maps seller contact/location. Implemented via T-SQL `MERGE`. Existing records are updated in place; no history is retained. |
| **`dim_review`** | `stg_reviews` | Static | Direct map to `order_id` and `review_score`. Injects a default `-1` Surrogate Key for facts missing review data. |
| **`dim_date`** | *Procedural Generation* | N/A | Generated dynamically via T-SQL `WHILE` loop from 2016 to 2019. Attributes like `is_weekend` are calculated using `DATEPART`. |

---

## 3. Staging to Fact Mapping (Data Marts)
**Strategy:** Idempotent Incremental Load & Foreign Key Enforcement

| Target Fact Table | Source Staging Table(s) | Mapping Logic & Transformations |
| :--- | :--- | :--- |
| **`fact_sales`** | `stg_orders`, `stg_order_items` | Extracts SKs from Dimensions. `order_purchase_timestamp` is converted to `order_date_sk` (YYYYMMDD). Uses `WHERE NOT EXISTS` to prevent duplicate loading based on `order_id` + `order_item_id`. |
| **`fact_logistics`** | `stg_orders`, `stg_order_items` | `delivery_delay_days` = `DATEDIFF(day, estimated_delivery, actual_delivery)`. Replaces missing Seller or Review data with SK `-1` (`ISNULL`) to preserve referential integrity. |
