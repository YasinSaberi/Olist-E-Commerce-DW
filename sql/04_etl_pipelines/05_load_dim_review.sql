USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.Load_DimReview
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.DimReview AS Target
    USING (
        SELECT DISTINCT
            review_id AS ReviewBusinessID,
            review_score AS ReviewScore
        FROM Olist_Staging.dbo.stg_reviews
        WHERE review_id IS NOT NULL
    ) AS Source
    ON (Target.ReviewBusinessID = Source.ReviewBusinessID)
    
    WHEN NOT MATCHED THEN
        INSERT (ReviewBusinessID, ReviewScore, LoadDate)
        VALUES (Source.ReviewBusinessID, Source.ReviewScore, GETDATE());
END;
GO