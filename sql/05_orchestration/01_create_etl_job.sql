USE msdb;
GO

EXEC dbo.sp_add_job
    @job_name = N'Olist_Nightly_ETL_Load',
    @enabled = 1,
    @description = N'Executes the incremental load for the Olist Data Warehouse nightly.';

EXEC sp_add_jobstep
    @job_name = N'Olist_Nightly_ETL_Load',
    @step_name = N'01_Load_Dimensions',
    @subsystem = N'TSQL',
    @command = N'
        EXEC dbo.sp_load_dim_customer_scd2; 
        EXEC dbo.sp_load_dim_product_scd3; 
        EXEC dbo.sp_load_dim_seller_scd1; 
        EXEC dbo.sp_load_dim_review;
    ',
    @database_name = N'Olist_DW',
    @on_success_action = 3; 

EXEC sp_add_jobstep
    @job_name = N'Olist_Nightly_ETL_Load',
    @step_name = N'02_Load_Facts',
    @subsystem = N'TSQL',
    @command = N'
        EXEC dbo.sp_load_fact_sales; 
        EXEC dbo.sp_load_fact_logistics;
    ',
    @database_name = N'Olist_DW',
    @on_success_action = 1; 

EXEC sp_add_jobschedule
    @job_name = N'Olist_Nightly_ETL_Load',
    @name = N'Daily_2AM_Schedule',
    @freq_type = 4,
    @freq_interval = 1, 
    @active_start_time = 020000; 

EXEC sp_add_jobserver
    @job_name = N'Olist_Nightly_ETL_Load',
    @server_name = N'(LOCAL)';
GO