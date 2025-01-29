USE ad_project;
SELECT * FROM ad_data;

-- Create duplicate (staging table) 
-- preserves raw data in case of emergency

DROP TABLE IF EXISTS ad_staging;
CREATE TABLE ad_staging
LIKE ad_data;

INSERT INTO ad_staging
SELECT * FROM ad_data;

-- verify
SELECT * FROM ad_data
ORDER BY Ad_ID
LIMIT 5;

SELECT * FROM ad_staging
ORDER BY Ad_ID
LIMIT 5;

-- designate Ad_ID as Primary KEy
ALTER TABLE ad_staging
ADD PRIMARY KEY (Ad_ID);

-- Convert percentage columns
-- (Conversion_Rate, Bounce_Rate, CTR)
ALTER TABLE ad_staging
MODIFY COLUMN Conversion_Rate DECIMAL(5,2),
MODIFY COLUMN Bounce_Rate DECIMAL(5,2),
MODIFY COLUMN CTR DECIMAL(5,2);

-- Now update the values, removing the '%' and converting to decimal
UPDATE ad_staging
SET 
    Conversion_Rate = CAST(REPLACE(Conversion_Rate, '%', '') AS DECIMAL(5,2)),
    Bounce_Rate = CAST(REPLACE(Bounce_Rate, '%', '') AS DECIMAL(5,2)),
    CTR = CAST(REPLACE(CTR, '%', '') AS DECIMAL(5,2))
WHERE Ad_ID > 0;

-- create new age_group column
-- (useful for calculations later on)
ALTER TABLE ad_staging
ADD COLUMN Age_Group_Numeric INT;

UPDATE ad_staging
SET Age_Group_Numeric = 
    CASE 
        WHEN Age_Group = '18-24' THEN 1
        WHEN Age_Group = '25-34' THEN 2
        WHEN Age_Group = '35-44' THEN 3
        WHEN Age_Group = '45-54' THEN 4
        WHEN Age_Group = '55+' THEN 5
    END
WHERE Ad_ID > 0;

-- Verify the conversion worked
SELECT 
    Ad_ID,
    Age_Group,
    Age_Group_Numeric,
    Conversion_Rate,
    Bounce_Rate,
    CTR
FROM ad_staging
LIMIT 5;

-- Check For Missing Data
SELECT
	COUNT(*) AS Total_rows,
    SUM(CASE WHEN Ad_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Ad_ID,
    SUM(CASE WHEN Ad_Type IS NULL THEN 1 ELSE 0 END) AS Missing_Ad_Type,
	SUM(CASE WHEN Visual_Complexity IS NULL THEN 1 ELSE 0 END) AS Missing_Visual_Complexity,
    SUM(CASE WHEN Clicks IS NULL THEN 1 ELSE 0 END) AS Missing_Clicks,
    SUM(CASE WHEN Time_Spent IS NULL THEN 1 ELSE 0 END) AS Missing_Time_Spent,
    SUM(CASE WHEN Engagement_Score IS NULL THEN 1 ELSE 0 END) AS Missing_Engagement_Score,
    SUM(CASE WHEN Age_Group IS NULL THEN 1 ELSE 0 END) AS Missing_Age_Group,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Missing_Gender,
    SUM(CASE WHEN Device_Type IS NULL THEN 1 ELSE 0 END) AS Missing_Device_Type,
    SUM(CASE WHEN Conversion_Rate IS NULL THEN 1 ELSE 0 END) AS Missing_Conversion_Rate,
    SUM(CASE WHEN Bounce_Rate IS NULL THEN 1 ELSE 0 END) AS Missing_Bounce_Rate,
    SUM(CASE WHEN CTR IS NULL THEN 1 ELSE 0 END) AS Missing_CTR,
    SUM(CASE WHEN Frame_Data IS NULL THEN 1 ELSE 0 END) AS Missing_Frame_Data,
    SUM(CASE WHEN User_Movement_Data IS NULL THEN 1 ELSE 0 END) AS Missing_User_Movement_Data
FROM ad_staging;

-- summary statistics (numerical columns)
SELECT
    AVG(Clicks) AS Avg_Clicks,
    MAX(Clicks) AS Max_Clicks,
    MIN(Clicks) AS Min_Clicks,
    AVG(Time_Spent) AS Avg_Time_Spent,
    MAX(Time_Spent) AS Max_Time_Spent,
    MIN(Time_Spent) AS Min_Time_Spent,
	AVG(Engagement_Score) AS Avg_Engagement_Score,
    MAX(Engagement_Score) AS Max_Engagement_Score,
    MIN(Engagement_Score) AS Min_Engagement_Score,
	AVG(Conversion_Rate) AS Avg_Conversion_Rate,
    MAX(Conversion_Rate) AS Max_Conversion_Rate,
    MIN(Conversion_Rate) AS Min_Conversion_Rate,
	AVG(Bounce_Rate) AS Avg_Bounce_Rate,
    MAX(Bounce_Rate) AS Max_Bounce_Rate,
    MIN(Bounce_Rate) AS Min_Bounce_Rate,
	AVG(CTR) AS Avg_CTR,
    MAX(CTR) AS Max_CTR,
    MIN(CTR) AS Min_CTR
FROM ad_staging;

-- frequency distribution (categorical columns)
WITH CategoryCounts AS (
    SELECT 'Ad_Type' as Category, Ad_Type as Value, COUNT(*) AS Frequency
    FROM ad_staging
    GROUP BY Ad_Type
    UNION ALL
    SELECT 'Visual_Complexity', Visual_Complexity, COUNT(*) 
    FROM ad_staging
    GROUP BY Visual_Complexity
    UNION ALL
    SELECT 'Age_Group', Age_Group, COUNT(*) 
    FROM ad_staging
    GROUP BY Age_Group
    UNION ALL
    SELECT 'Gender', Gender, COUNT(*) 
    FROM ad_staging
    GROUP BY Gender
    UNION ALL
    SELECT 'Device_Type', Device_Type, COUNT(*) 
    FROM ad_staging
    GROUP BY Device_Type
)
SELECT 
    Category,
    Value,
    Frequency,
    CONCAT(ROUND((Frequency * 100.0 / SUM(Frequency) OVER (PARTITION BY Category)), 2), '%') as Percentage
FROM CategoryCounts
ORDER BY Category, Frequency DESC;