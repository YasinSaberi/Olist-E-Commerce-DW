<div align="center">

# 🛒 Olist E-Commerce Data Warehouse

**A star-schema data warehouse and nightly ETL pipeline built on the Olist marketplace dataset**, featuring full-scale data orchestration, SCD-managed dimensions, comprehensive audit logging, and fact tables for sales and logistics analytics.

![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/Language-T--SQL-336791)
![Task Scheduler](https://img.shields.io/badge/Orchestration-Windows%20Task%20Scheduler-0078D6?logo=windows&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

**Course:** Database 2
**Tech Stack:** SQL Server, T-SQL, Windows Task Scheduler, GitHub

## 📑 Table of Contents

- [1. Project Architecture & ETL Flow](#1-project-architecture--etl-flow)
- [2. Star Schema ER Diagram](#2-star-schema-entity-relationship-er-diagram)
- [3. Data Mapping & ETL Documentation](#3-data-mapping--etl-documentation)
- [4. Auditing & Validation](#4-auditing--validation)
- [5. Orchestration & Automation](#5-orchestration--automation)

## 1. Project Architecture & ETL Flow

The data architecture follows a strict, 3-tier environment model, extracting data from the highly distributed Olist marketplace into a centralized analytical engine.

```mermaid
graph TD
    A[(Olist_Source)] -->|sp_extract_source_to_staging<br/>Full Extract| B[(Olist_Staging)]
    B -->|SCD & Fact Procedures<br/>ACID Compliant| C[(Olist_DW)]

    subgraph Data Warehouse
        C --> D[Dimensions: Customer, Product, Seller, Review, Date]
        D -->|Primary Keys Established| E[Facts: Sales, Logistics]
        E -.->|Status & Error Tracking| L[(etl_audit_log)]
    end

    F[[Master Orchestrator<br/>sp_master_etl_load]] -->|Executes Step-by-Step| B
    F -->|Parameter: @IsFirstLoad| C
