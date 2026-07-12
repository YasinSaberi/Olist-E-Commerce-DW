# 🧪 Data Validation and Testing Suite

This directory contains the testing and validation scripts for the Olist Data Warehouse. These scripts are designed to verify data integrity, ensure referential consistency, and demonstrate the historical tracking capabilities of the ETL pipeline.

## 📄 File: `01_data_validation_and_scd_test.sql`

This master script runs a sequence of 4 critical tests to validate the health of the Data Warehouse after deployment. 

### Test 1: Audit Log Check
- **Purpose:** Verifies the operational monitoring system.
- **What it does:** Queries the `etl_audit_log` table to ensure that the Master Orchestrator and all underlying stored procedures executed successfully. It checks for proper status transitions (`RUNNING` ➔ `SUCCESS`) and ensures no silent failures occurred.

### Test 2: Row Count Verification (Migration Accuracy)
- **Purpose:** Proves zero data loss and zero data duplication.
- **What it does:** Performs a union query across the 3 environment tiers (`Olist_Source` ➔ `Olist_Staging` ➔ `Olist_DW.fact_sales`). The total row counts must match precisely, validating that the extraction and idempotent `NOT EXISTS` logic worked flawlessly.

### Test 3: Dimension Integrity & Unknown Record Check
- **Purpose:** Validates referential integrity setup.
- **What it does:** Queries the dimension tables (e.g., `dim_customer`) to verify the existence of the default `-1` (Unknown) surrogate key. This record is vital for handling missing source data without breaking foreign key constraints in the fact tables.

### Test 4: SCD Type 2 Simulation (Historical Tracking)
- **Purpose:** Demonstrates Slowly Changing Dimension (Type 2) logic in real-time.
- **What it does:** 
  1. Simulates a real-world scenario by updating a customer's city in the raw `Olist_Source` database.
  2. Triggers the nightly Incremental ETL pipeline (`@IsFirstLoad = 0`).
  3. Queries the Data Warehouse to prove that the old record was successfully expired (`IsCurrent = 0`, `ValidTo = [Timestamp]`) and a new active surrogate key was generated for the new city (`IsCurrent = 1`, `ValidTo = NULL`).

---

**Usage:** 
Simply open and execute the `.sql` script in SQL Server Management Studio (SSMS) after running the First Load of the Data Warehouse.
