CREATE TABLE FactLogistics (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,

    SellerKey INT NOT NULL,
    GeoKey INT NOT NULL,
    ReviewKey INT NOT NULL,

    CustomerKey INT NOT NULL,
    OrderDateKey INT NOT NULL, 
    EstimatedDeliveryDateKey INT NOT NULL,

    OrderID VARCHAR(50) NOT NULL,
    OrderItemSequence INT NOT NULL,

    FreightValue DECIMAL(10, 2) NOT NULL,
    DeliveryDelayDays INT NULL,
    ActualShippingDurationDays INT NULL,

    OrderCount INT DEFAULT 1,

    LoadDate DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (SellerKey) REFERENCES DimSeller(SellerKey),
    FOREIGN KEY (GeoKey) REFERENCES DimGeolocation(GeoKey),
    FOREIGN KEY (ReviewKey) REFERENCES DimReview(ReviewKey),
     --FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
     --FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey),
     --FOREIGN KEY (EstimatedDeliveryDateKey) REFERENCES DimDate(DateKey),
     --FOREIGN KEY (ActualDeliveryDateKey) REFERENCES DimDate(DateKey)
);