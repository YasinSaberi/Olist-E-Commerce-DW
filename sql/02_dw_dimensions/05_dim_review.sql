USE Olist_DW;
GO

IF OBJECT_ID('dbo.dim_review', 'U') IS NOT NULL
    DROP TABLE dbo.dim_review;
GO

CREATE TABLE dbo.dim_review (
    review_sk INT IDENTITY(1,1) PRIMARY KEY,
    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NULL,
    review_score INT NULL,
    review_title VARCHAR(255) NULL,
    review_message VARCHAR(MAX) NULL
);
GO