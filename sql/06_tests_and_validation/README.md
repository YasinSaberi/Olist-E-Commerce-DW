# 🧪 Data Validation and Testing Suite

![Tests](https://img.shields.io/badge/Tests-4%20Scenarios-brightgreen)
![Engine](https://img.shields.io/badge/Engine-T--SQL-336791)
![Scope](https://img.shields.io/badge/Scope-Source%20%E2%86%92%20Staging%20%E2%86%92%20DW-CC2927)

This directory contains the testing and validation scripts for the **Olist Data Warehouse**. These scripts verify data integrity, ensure referential consistency, and demonstrate the historical tracking capabilities of the ETL pipeline — providing a repeatable health check to run after every deployment or major release.

## 📑 Contents

- [Prerequisites](#-prerequisites)
- [File: `01_data_validation_and_scd_test.sql`](#-file-01_data_validation_and_scd_testsql)
- [Test Summary](#-test-summary)
- [Test 1 — Audit Log Check](#test-1-audit-log-check)
- [Test 2 — Row Count Verification](#test-2-row-count-verification-migration-accuracy)
- [Test 3 — Dimension Integrity & Unknown Record Check](#test-3-dimension-integrity--unknown-record-check)
- [Test 4 — SCD Type 2 Simulation](#test-4-scd-type-2-simulation-historical-tracking)
- [Usage](#-usage)
- [Resetting Test Data](#-resetting-test-data)
- [Troubleshooting](#-troubleshooting)

## ✅ Prerequisites

Before running this suite, make sure:

- The **First Load** has already been executed at least once (`EXEC dbo.sp_master_etl_load @IsFirstLoad = 1;`).
- You have `db_owner` (or equivalent read/write) permissions on `Olist_Source`, `Olist_Staging`, and `Olist_DW`.
- No other ETL job is currently running — Test 4 triggers an incremental load and concurrent executions could produce misleading results.

## 📄 File: `01_data_validation_and_scd_test.sql`

This master script runs a sequence of **4 critical tests** to validate the health of the Data Warehouse after deployment. Each test is self-contained, printed to the SSMS Messages pane for traceability, and can be run individually or as a full batch.

## 🔍 Test Summary

| # | Test | Validates | Target Object(s) |
|---|---|---|---|
| 1 | Audit Log Check | ETL execution completed without silent failures | `etl_audit_log` |
| 2 | Row Count Verification | No data loss or duplication across tiers | `order_items`, `stg_order_items`, `fact_sales` |
| 3 | Unknown Record Check | Referential integrity fallback exists | `dim_customer` |
| 4 | SCD Type 2 Simulation | Historical tracking behaves correctly on change | `dim_customer`, `sp_master_etl_load` |

---

### Test 1: Audit Log Check

- **Purpose:** Verifies the operational monitoring system.
- **What it does:** Queries the `etl_audit_log` table to ensure that the Master Orchestrator and all underlying stored procedures executed successfully. It checks for proper status transitions (`RUNNING` ➔ `SUCCESS`) and ensures no silent failures occurred.
- **Pass criteria:** No rows with `status = 'FAILED'`; every `RUNNING` entry has a matching `SUCCESS` entry for the same procedure/run.

```sql
SELECT *
FROM Olist_DW.dbo.etl_audit_log
ORDER BY log_id ASC;
```

### Test 2: Row Count Verification (Migration Accuracy)

- **Purpose:** Proves zero data loss and zero data duplication.
- **What it does:** Performs a union query across the 3 environment tiers (`Olist_Source` ➔ `Olist_Staging` ➔ `Olist_DW.fact_sales`). The total row counts must match precisely, validating that the extraction and idempotent `NOT EXISTS` logic worked flawlessly.
- **Pass criteria:** `Total_Rows` is identical across all three layers.

```sql
SELECT 'Source' AS Layer, COUNT(*) AS Total_Rows FROM Olist_Source.dbo.order_items
UNION ALL
SELECT 'Staging', COUNT(*) FROM Olist_Staging.dbo.stg_order_items
UNION ALL
SELECT 'Data Warehouse', COUNT(*) FROM Olist_DW.dbo.fact_sales;
```

> ⚠️ **Note:** If `fact_sales` is lower than `Source`/`Staging`, check for order items referencing a customer or product that failed a `NOT NULL` join. If it's higher, the idempotent `WHERE NOT EXISTS` guard may have been bypassed by a manual insert.

### Test 3: Dimension Integrity & Unknown Record Check

- **Purpose:** Validates referential integrity setup.
- **What it does:** Queries the dimension tables (e.g., `dim_customer`) to verify the existence of the default `-1` (Unknown) surrogate key. This record is vital for handling missing source data without breaking foreign key constraints in the fact tables.
- **Pass criteria:** Exactly one row is returned with `customer_sk = -1`.

```sql
SELECT *
FROM Olist_DW.dbo.dim_customer
WHERE customer_sk = -1;
```

### Test 4: SCD Type 2 Simulation (Historical Tracking)

- **Purpose:** Demonstrates Slowly Changing Dimension (Type 2) logic in real time.
- **What it does:**
  1. Simulates a real-world scenario by updating a customer's city in the raw `Olist_Source` database.
  2. Triggers the nightly Incremental ETL pipeline (`@IsFirstLoad = 0`).
  3. Queries the Data Warehouse to prove that the old record was successfully expired (`IsCurrent = 0`, `ValidTo = [Timestamp]`) and a new active surrogate key was generated for the new city (`IsCurrent = 1`, `ValidTo = NULL`).

```sql
-- 4.1 Update the source record
UPDATE Olist_Source.dbo.customers
SET customer_city = 'tehran'
WHERE customer_unique_id = '0000366f3b9a7992bf8c76cfdf3221e2';

-- 4.2 Run the incremental load
EXEC Olist_DW.dbo.sp_master_etl_load @IsFirstLoad = 0;

-- 4.3 Verify both the expired and new active rows
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
```

**Expected result:** two rows for the same `customer_unique_id` —

| customer_sk | customer_city | IsCurrent | ValidFrom | ValidTo |
|---|---|---|---|---|
| *(original sk)* | original city | `0` | original load date | timestamp of this test run |
| *(new sk)* | `tehran` | `1` | timestamp of this test run | `NULL` |

---

## ▶️ Usage

Simply open and execute the `.sql` script in **SQL Server Management Studio (SSMS)** after running the First Load of the Data Warehouse:

```sql
USE Olist_DW;
GO
:r 01_data_validation_and_scd_test.sql
```

Review the **Messages** pane for the `PRINT` markers separating each test, and inspect the **Results** grid for each corresponding query.

## 🔄 Resetting Test Data

Test 4 permanently mutates source data (`customer_city = 'tehran'`). Before re-running the full suite, restore the original value or re-seed `Olist_Source` from the Kaggle CSVs to avoid comparing against already-modified state:

```sql
UPDATE Olist_Source.dbo.customers
SET customer_city = '<original_city>'
WHERE customer_unique_id = '0000366f3b9a7992bf8c76cfdf3221e2';
```

## 🛠️ Troubleshooting

| Symptom | Likely Cause |
|---|---|
| Test 1 shows `status = 'FAILED'` | Check the `error_message` column in `etl_audit_log` for the failing procedure. |
| Test 2 counts don't match | A join in the staging → DW load may be silently dropping rows, or `NOT EXISTS` logic was bypassed. |
| Test 3 returns no rows | The `-1` Unknown record was never seeded — re-run the First Load or the dimension seed script. |
| Test 4 only shows one row | The incremental load may not have detected the change — confirm `@IsFirstLoad = 0` and that the SCD2 comparison logic includes `customer_city`. |
