USE Olist_DW;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'NCI_Columnstore_FactLogistics' AND object_id = OBJECT_ID('dbo.fact_logistics'))
BEGIN
    CREATE NONCLUSTERED COLUMNSTORE INDEX NCI_Columnstore_FactLogistics
    ON dbo.fact_logistics (freight_value, delivery_delay_days, shipping_delay_days);
END;
GO