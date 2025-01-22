-- Fetch data from the assessment dataset to understand its structure
SELECT * FROM dbo.assessment_dataset;

-- Objective: Address missing or inconsistent data in the dataset
-- Observed that the 'CustomerAge' column has missing values

-- Replace missing CustomerAge values with the average of non-null values
UPDATE dbo.assessment_dataset
SET CustomerAge = (SELECT AVG(CustomerAge) FROM dbo.assessment_dataset WHERE CustomerAge IS NOT NULL)
WHERE CustomerAge IS NULL;

-- Objective: Categorize customers based on their age for better segmentation

-- Add a new column 'AgeGroup' to categorize customers
ALTER TABLE dbo.assessment_dataset ADD AgeGroup VARCHAR(20);

-- Update the 'AgeGroup' column based on 'CustomerAge' ranges
UPDATE dbo.assessment_dataset
SET AgeGroup = CASE
    WHEN CustomerAge < 18 THEN 'Children'
    WHEN CustomerAge BETWEEN 18 AND 25 THEN 'Young Adults'
    WHEN CustomerAge BETWEEN 26 AND 35 THEN 'Adults'
    WHEN CustomerAge BETWEEN 36 AND 50 THEN 'Middle Age'
    WHEN CustomerAge > 50 THEN 'Seniors'
    ELSE 'Unknown'  -- Handle any unexpected or missing age data
END;

-- Objective: Handle missing 'TransactionDate' by filling it with the earliest available date

UPDATE dbo.assessment_dataset
SET TransactionDate = (SELECT MIN(TransactionDate) FROM dbo.assessment_dataset WHERE TransactionDate IS NOT NULL)
WHERE TransactionDate IS NULL;

-- Objective: Fill missing categorical columns with a placeholder value 'Unknown'

UPDATE dbo.assessment_dataset
SET PaymentMethod = 'Unknown'
WHERE PaymentMethod IS NULL;

UPDATE dbo.assessment_dataset
SET StoreType = 'Unknown'
WHERE StoreType IS NULL;

UPDATE dbo.assessment_dataset
SET Region = 'Unknown'
WHERE Region IS NULL;

UPDATE dbo.assessment_dataset
SET ProductName = 'Unknown'
WHERE ProductName IS NULL;

UPDATE dbo.assessment_dataset
SET CustomerGender = 'Unknown'
WHERE CustomerGender IS NULL;

-- Fetch updated data to ensure all missing values are handled
SELECT * FROM dbo.assessment_dataset;

-- Objective: Standardize 'Region' values to ensure consistent capitalization

UPDATE dbo.assessment_dataset
SET Region = UPPER(Region);

-- Objective: Identify potential outliers in 'TransactionAmount' by using a 3-standard deviation threshold

SELECT * 
FROM dbo.assessment_dataset
WHERE TransactionAmount > 
      (SELECT AVG(TransactionAmount) + 3 * STDEV(TransactionAmount)
       FROM dbo.assessment_dataset
       WHERE TransactionAmount IS NOT NULL);

-- Data Cleansing and Standardization is complete. Moving on to Data Analysis.

-- Objective: Calculate overall sales performance metrics
SELECT 
    SUM(TransactionAmount) AS total_sales, 
    SUM(Quantity) AS total_quantity, 
    AVG(TransactionAmount) AS avg_transaction_amount
FROM dbo.assessment_dataset;

-- Objective: Identify top 10 products by total sales

SELECT TOP 10
    ProductName, 
    SUM(TransactionAmount) AS total_sales 
FROM dbo.assessment_dataset
GROUP BY ProductName
ORDER BY total_sales DESC;

-- Objective: Analyze total sales performance by Region

SELECT 
    Region, 
    SUM(TransactionAmount) AS total_sales 
FROM dbo.assessment_dataset
GROUP BY Region
ORDER BY total_sales DESC;

-- Objective: Analyze sales trends on a monthly basis

SELECT 
    FORMAT(TransactionDate, 'yyyy-MM') AS month, 
    SUM(TransactionAmount) AS total_sales 
FROM dbo.assessment_dataset
GROUP BY FORMAT(TransactionDate, 'yyyy-MM')
ORDER BY month;

-- Objective: Analyze sales performance by Age Group

SELECT 
    AgeGroup, 
    SUM(TransactionAmount) AS total_sales, 
    COUNT(*) AS total_transactions 
FROM dbo.assessment_dataset
GROUP BY AgeGroup
ORDER BY total_sales DESC;

-- Objective: Identify top products within each Age Group

SELECT 
    AgeGroup, 
    ProductName, 
    SUM(TransactionAmount) AS total_sales 
FROM dbo.assessment_dataset
GROUP BY AgeGroup, ProductName
ORDER BY AgeGroup, total_sales DESC;

-- Drill-Down Analysis for deeper insights

-- Objective: Identify the best-selling product per region

SELECT 
    Region, 
    ProductName, 
    SUM(TransactionAmount) AS total_sales 
FROM dbo.assessment_dataset
GROUP BY Region, ProductName
ORDER BY Region, total_sales DESC;

-- Objective: Compare sales for promotional and non-promotional items

SELECT 
    IsPromotional, 
    SUM(TransactionAmount) AS total_sales, 
    COUNT(*) AS total_transactions 
FROM dbo.assessment_dataset
GROUP BY IsPromotional;

-- Objective: Assess sales distribution by Payment Method

SELECT 
    PaymentMethod, 
    SUM(TransactionAmount) AS total_sales, 
    COUNT(*) AS total_transactions 
FROM dbo.assessment_dataset
GROUP BY PaymentMethod
ORDER BY total_sales DESC;

-- Objective: Analyze if higher feedback scores correlate with higher sales

SELECT 
    FeedbackScore, 
    AVG(TransactionAmount) AS avg_sales, 
    COUNT(*) AS total_transactions 
FROM dbo.assessment_dataset
GROUP BY FeedbackScore
ORDER BY FeedbackScore DESC;
