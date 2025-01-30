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
WITH Metrics AS (
    -- Group 1: Click Metrics
    SELECT 
        'Clicks' as Metric,
        Clicks as Value
    FROM ad_staging
    
    UNION ALL
    
    -- Group 2: Time and Engagement Metrics
    SELECT 
        'Time_Spent' as Metric,
        Time_Spent as Value
    FROM ad_staging
    
    UNION ALL
    
    SELECT 
        'Engagement_Score' as Metric,
        Engagement_Score as Value
    FROM ad_staging
    
    UNION ALL
    
    -- Group 3: Rate Metrics
    SELECT 
        'Conversion_Rate' as Metric,
        Conversion_Rate as Value
    FROM ad_staging
    
    UNION ALL
    
    SELECT 
        'Bounce_Rate' as Metric,
        Bounce_Rate as Value
    FROM ad_staging
    
    UNION ALL
    
    SELECT 
        'CTR' as Metric,
        CTR as Value
    FROM ad_staging
),
RankedMetrics AS (
    SELECT 
        Metric,
        Value,
        ROW_NUMBER() OVER (PARTITION BY Metric ORDER BY Value) as rn,
        COUNT(*) OVER (PARTITION BY Metric) as total_count
    FROM (
        -- All numerical metrics
        SELECT 'Clicks' as Metric, Clicks as Value FROM ad_staging
        UNION ALL
        SELECT 'Time_Spent', Time_Spent FROM ad_staging
        UNION ALL
        SELECT 'Engagement_Score', Engagement_Score FROM ad_staging
        UNION ALL
        SELECT 'Conversion_Rate', Conversion_Rate FROM ad_staging
        UNION ALL
        SELECT 'Bounce_Rate', Bounce_Rate FROM ad_staging
        UNION ALL
        SELECT 'CTR', CTR FROM ad_staging
    ) as combined_metrics
)
SELECT 
    Metric,
    ROUND(AVG(Value), 2) as Mean,
    ROUND(STDDEV(Value), 2) as Std_Dev,
    MIN(Value) as Min_Value,
    ROUND(AVG(CASE 
        WHEN rn IN (FLOOR(total_count * 0.25), CEIL(total_count * 0.25)) 
        THEN Value 
    END), 2) as Q1,
    ROUND(AVG(CASE 
        WHEN rn IN (FLOOR(total_count * 0.5), CEIL(total_count * 0.5)) 
        THEN Value 
    END), 2) as Median,
    ROUND(AVG(CASE 
        WHEN rn IN (FLOOR(total_count * 0.75), CEIL(total_count * 0.75)) 
        THEN Value 
    END), 2) as Q3,
    MAX(Value) as Max_Value
FROM RankedMetrics
GROUP BY Metric
ORDER BY Metric;

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
