USE Olist_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_load_dim_review
AS
BEGIN
    INSERT INTO dbo.dim_review (review_id, order_id, review_score, review_title, review_message)
    SELECT 
        review_id, 
        order_id, 
        review_score, 
        review_comment_title, 
        review_comment_message
    FROM Olist_Staging.dbo.stg_reviews stg
    WHERE NOT EXISTS (
        SELECT 1 
        FROM dbo.dim_review dw 
        WHERE dw.review_id = stg.review_id
    );
END;
GO