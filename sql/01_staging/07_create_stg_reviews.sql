USE Olist_Staging;
GO

IF OBJECT_ID('dbo.stg_reviews', 'U') IS NOT NULL
    DROP TABLE dbo.stg_reviews;
GO

CREATE TABLE dbo.stg_reviews (
    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    review_score INT NULL,
    review_comment_title VARCHAR(255) NULL,
    review_comment_message VARCHAR(MAX) NULL,
    review_creation_date DATETIME NULL,
    review_answer_timestamp DATETIME NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO