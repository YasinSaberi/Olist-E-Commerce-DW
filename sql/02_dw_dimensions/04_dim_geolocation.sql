CREATE TABLE DimGeolocation (
    GeoKey INT IDENTITY(1,1) PRIMARY KEY,
    ZipCodePrefix INT,
    City VARCHAR(100),
    State VARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT
);