USE Olist_DW;
GO

IF OBJECT_ID('dbo.fact_logistics', 'U') IS NOT NULL DROP TABLE dbo.fact_logistics;
GO

CREATE TABLE dbo.fact_logistics (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    customer_sk INT NOT NULL,
    seller_sk INT NOT NULL,
    review_sk INT NOT NULL,
    order_date_sk INT NOT NULL,
    freight_value DECIMAL(10, 2) NULL,
    delivery_delay_days INT NULL,
    shipping_delay_days INT NULL, 
    
    CONSTRAINT FK_FactLogistics_Customer FOREIGN KEY (customer_sk) REFERENCES dbo.dim_customer(customer_sk),
    CONSTRAINT FK_FactLogistics_Seller FOREIGN KEY (seller_sk) REFERENCES dbo.dim_seller(seller_sk),
    CONSTRAINT FK_FactLogistics_Review FOREIGN KEY (review_sk) REFERENCES dbo.dim_review(review_sk),
    CONSTRAINT FK_FactLogistics_Date FOREIGN KEY (order_date_sk) REFERENCES dbo.dim_date(date_sk)
);
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactLogistics ON dbo.fact_logistics;
GO