CREATE TABLE stg_products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT,
    LoadDate DATETIME DEFAULT GETDATE()
);