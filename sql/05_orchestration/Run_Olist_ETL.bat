@echo off
echo Starting Olist Data Warehouse ETL Pipeline...

sqlcmd -S YASINSABERI\SQLEXPRESS -d Olist_DW -E -Q "EXEC dbo.sp_load_dim_customer_scd2; EXEC dbo.sp_load_dim_product_scd3; EXEC dbo.sp_load_dim_seller_scd1; EXEC dbo.sp_load_dim_review; EXEC dbo.sp_load_fact_sales; EXEC dbo.sp_load_fact_logistics;"

echo ETL Pipeline Completed Successfully.