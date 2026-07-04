CREATE TABLE FactLogistics (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,

    -- Foreign Keys (ابعاد مربوط به خودت)
    SellerKey INT NOT NULL,
    GeoKey INT NOT NULL,
    ReviewKey INT NOT NULL,

    -- Foreign Keys (ابعاد مشترک که باید با یاسین هماهنگ کنی)
    CustomerKey INT NOT NULL, -- معمولاً لجستیک بر اساس مشتری هم تحلیل می‌شود
    OrderDateKey INT NOT NULL, -- تاریخ ثبت سفارش (متصل به DimDate)
    EstimatedDeliveryDateKey INT NOT NULL, -- تاریخ تخمینی تحویل
    ActualDeliveryDateKey INT NULL, -- تاریخ واقعی تحویل (چون ممکن است هنوز تحویل نشده باشد، NULL پذیر است)

    -- Business Keys (برای Trace و جفت کردن داده‌ها در ETL)
    OrderID VARCHAR(50) NOT NULL,
    OrderItemSequence INT NOT NULL, -- اضافه شد: چون یک سفارش ممکن است چند آیتم با هزینه‌های حمل متفاوت داشته باشد

    -- Metrics (اعداد تحلیلی)
    FreightValue DECIMAL(10, 2) NOT NULL, -- تبدیل FLOAT به DECIMAL برای دقت مالی
    DeliveryDelayDays INT NULL, -- در فاز ETL محاسبه می‌شود (واقعی منهای تخمینی)
    ActualShippingDurationDays INT NULL, -- اضافه شد: زمان کل سفر کالا (واقعی منهای ثبت سفارش)

    OrderCount INT DEFAULT 1,

    -- System Fields
    LoadDate DATETIME DEFAULT GETDATE(),

    -- Relationships (تعریف کلیدهای خارجی)
    FOREIGN KEY (SellerKey) REFERENCES DimSeller(SellerKey),
    FOREIGN KEY (GeoKey) REFERENCES DimGeolocation(GeoKey),
    FOREIGN KEY (ReviewKey) REFERENCES DimReview(ReviewKey)
    -- بعد از اینکه یاسین جداول خودش را ساخت، رفرنس‌های زیر را هم فعال کن:
    -- FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    -- FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey),
    -- FOREIGN KEY (EstimatedDeliveryDateKey) REFERENCES DimDate(DateKey),
    -- FOREIGN KEY (ActualDeliveryDateKey) REFERENCES DimDate(DateKey)
);