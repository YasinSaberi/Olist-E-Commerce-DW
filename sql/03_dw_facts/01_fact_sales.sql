USE Olist_DW;
GO

IF OBJECT_ID('dbo.fact_sales', 'U') IS NOT NULL DROP TABLE dbo.fact_sales;
GO

CREATE TABLE dbo.fact_sales (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    customer_sk INT NOT NULL,
    product_sk INT NOT NULL,
    order_date_sk INT NOT NULL,
    price DECIMAL(10, 2) NULL,
    freight_value DECIMAL(10, 2) NULL,
    
    CONSTRAINT FK_FactSales_Customer FOREIGN KEY (customer_sk) REFERENCES dbo.dim_customer(customer_sk),
    CONSTRAINT FK_FactSales_Product FOREIGN KEY (product_sk) REFERENCES dbo.dim_product(product_sk),
    CONSTRAINT FK_FactSales_Date FOREIGN KEY (order_date_sk) REFERENCES dbo.dim_date(date_sk)
);
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactSales ON dbo.fact_sales;
GO