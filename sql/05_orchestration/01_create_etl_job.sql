USE msdb;
GO

-- 1. Create the Master ETL Job
EXEC dbo.sp_add_job
    @job_name = N'Olist_Nightly_ETL_Load',
    @enabled = 1,
    @description = N'Executes the incremental load for the Olist Data Warehouse nightly.';

-- 2. Define Step 1: Load Dimensions
-- We run dimensions first to ensure primary keys exist before facts are loaded.
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
    @on_success_action = 3; -- 3 means: Go to the next step

-- 3. Define Step 2: Load Facts
-- Runs only if Step 1 succeeds.
EXEC sp_add_jobstep
    @job_name = N'Olist_Nightly_ETL_Load',
    @step_name = N'02_Load_Facts',
    @subsystem = N'TSQL',
    @command = N'
        EXEC dbo.sp_load_fact_sales; 
        EXEC dbo.sp_load_fact_logistics;
    ',
    @database_name = N'Olist_DW',
    @on_success_action = 1; -- 1 means: Quit with success

-- 4. Create the Execution Schedule (Runs Daily at 2:00:00 AM)
EXEC sp_add_jobschedule
    @job_name = N'Olist_Nightly_ETL_Load',
    @name = N'Daily_2AM_Schedule',
    @freq_type = 4, -- 4 indicates Daily
    @freq_interval = 1, -- Every 1 day
    @active_start_time = 020000; -- Format is HHMMSS (02:00:00 AM)

-- 5. Attach the Job to the Local SQL Server Engine
EXEC sp_add_jobserver
    @job_name = N'Olist_Nightly_ETL_Load',
    @server_name = N'(LOCAL)';
GO