CREATE TABLE DimReview (
    ReviewKey INT IDENTITY(1,1) PRIMARY KEY,
    ReviewID VARCHAR(50) NOT NULL,
    OrderID VARCHAR(50),
    ReviewScore INT,
    ReviewTitle VARCHAR(255),
    ReviewMessage VARCHAR(MAX)
);