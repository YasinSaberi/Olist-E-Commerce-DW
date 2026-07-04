CREATE TABLE stg_geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(50),
    LoadDate DATETIME DEFAULT GETDATE()
);