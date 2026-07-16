USE Olist_Source;
GO

SET NOCOUNT ON;
PRINT '--- STARTING DATA AUGMENTATION ---';
DECLARE @Counter INT = 1;

BEGIN TRY
    BEGIN TRAN;

    WHILE @Counter <= 4
    BEGIN
        INSERT INTO dbo.order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
        SELECT 
            order_id, 
            order_item_id + (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) * 100) + @Counter AS order_item_id,
            product_id, 
            seller_id, 
            shipping_limit_date, 
            price, 
            freight_value
        FROM dbo.order_items;

        PRINT 'Iteration ' + CAST(@Counter AS VARCHAR) + ' completed successfully.';
        SET @Counter = @Counter + 1;
    END;

    COMMIT TRAN;
    PRINT '--- DATA AUGMENTATION COMPLETED ---';
        SELECT COUNT(*) AS Total_Order_Items_Count 
    FROM Olist_Source.dbo.order_items;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ERROR: Augmentation failed.';
    THROW;
END CATCH;
GO
