USE Olist_Staging;
GO

IF OBJECT_ID('dbo.stg_geolocation', 'U') IS NOT NULL
    DROP TABLE dbo.stg_geolocation;
GO

CREATE TABLE dbo.stg_geolocation (
    geolocation_zip_code_prefix VARCHAR(20) NOT NULL,
    geolocation_lat FLOAT NULL,
    geolocation_lng FLOAT NULL,
    geolocation_city VARCHAR(100) NULL,
    geolocation_state CHAR(2) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO