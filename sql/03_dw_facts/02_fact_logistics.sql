CREATE TABLE FactLogistics (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,

    -- Foreign Keys
    SellerKey INT,
    GeoKey INT,
    ReviewKey INT,

    -- Business Keys (???? trace)
    OrderID VARCHAR(50),

    -- Metrics (????? ??????)
    FreightValue FLOAT,
    DeliveryDelayDays INT,
    EstimatedDelayDays INT,

    OrderCount INT DEFAULT 1,

    -- Relationships
    FOREIGN KEY (SellerKey) REFERENCES DimSeller(SellerKey),
    FOREIGN KEY (GeoKey) REFERENCES DimGeolocation(GeoKey),
    FOREIGN KEY (ReviewKey) REFERENCES DimReview(ReviewKey)
);