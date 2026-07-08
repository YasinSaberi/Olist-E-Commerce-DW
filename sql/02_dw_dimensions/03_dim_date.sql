USE Olist_DW;
GO

IF OBJECT_ID('dbo.dim_date', 'U') IS NOT NULL DROP TABLE dbo.dim_date;
GO

CREATE TABLE dbo.dim_date (
    date_sk INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    is_weekend BIT NOT NULL
);
GO

-- Automatically populate the calendar upon table creation
SET DATEFIRST 7; 
DECLARE @StartDate DATE = '2016-01-01';
DECLARE @EndDate DATE = '2019-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dbo.dim_date (date_sk, full_date, [year], [quarter], [month], [day], day_of_week, is_weekend)
    VALUES (
        CAST(CONVERT(VARCHAR(8), @StartDate, 112) AS INT),
        @StartDate, 
        YEAR(@StartDate), 
        DATEPART(QUARTER, @StartDate),
        MONTH(@StartDate), 
        DAY(@StartDate), 
        DATEPART(WEEKDAY, @StartDate), 
        CASE WHEN DATEPART(WEEKDAY, @StartDate) IN (1, 7) THEN 1 ELSE 0 END
    );
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;
GO