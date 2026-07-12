USE Olist_DW;
GO

-- 1. Create the Audit Log Table
IF OBJECT_ID('dbo.etl_audit_log', 'U') IS NOT NULL DROP TABLE dbo.etl_audit_log;
CREATE TABLE dbo.etl_audit_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    execution_time DATETIME DEFAULT GETDATE(),
    procedure_name VARCHAR(100),
    table_affected VARCHAR(100),
    action_description NVARCHAR(MAX),
    status VARCHAR(20)
);
GO

-- 2. Create the Reusable Logging Procedure
CREATE OR ALTER PROCEDURE dbo.sp_etl_logger
    @proc_name VARCHAR(100),
    @table_name VARCHAR(100),
    @action_desc NVARCHAR(MAX),
    @status VARCHAR(20) = 'SUCCESS'
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.etl_audit_log (procedure_name, table_affected, action_description, status)
    VALUES (@proc_name, @table_name, @action_desc, @status);
END;
GO