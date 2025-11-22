create database walmart;
use walmart;

-- 1. List all stores and the store types. 
SELECT store,
       type
FROM stores;

-- 2. Retrieve all rows where weekly sales were more than 50,000. 
SELECT *
FROM train
WHERE weekly_sales > 50000;

-- 3. Find the number of departments in each store. 
SELECT store,
       COUNT(DISTINCT dept) AS no_dept
FROM train
GROUP BY store;

-- 4. Show the top 5 highest weekly sales entries. 
SELECT *
FROM train
ORDER BY Weekly_Sales DESC
LIMIT 5;

-- 5. Display holiday weeks where weekly sales were higher than non-holiday weeks. 
SELECT IsHoliday,
       AVG(Weekly_Sales) AS Avg_Sales
FROM train
GROUP BY IsHoliday;

-- 6. Find total weekly sales per store (order highest → lowest). 
SELECT store,
       SUM(weekly_sales) AS total_sales
FROM train
GROUP BY store
ORDER BY total_sales DESC;

-- 7. Find average weekly sales per department.
SELECT Dept, AVG(Weekly_Sales) AS Avg_Dept_Sales
FROM train
 GROUP BY Dept;

-- 8. Determine which store has the highest average weekly sales.
SELECT store,
       AVG(weekly_sales) AS avg_weekly_sales
FROM train
GROUP BY store
ORDER BY avg_weekly_sales DESC
LIMIT 1;

-- 9. For each year, calculate total sales across all stores. 
SELECT YEAR(Date) AS Year, SUM(Weekly_Sales) AS Total_Sales
FROM train
GROUP BY YEAR(Date)
ORDER BY Year;

-- 10. Does temperature impact sales? Group temperature ranges vs avg sales. 
SELECT temp_range, AVG(Weekly_Sales)
FROM (
    SELECT Weekly_Sales,
           CASE
               WHEN Temperature < 32 THEN 'Cold'
               WHEN Temperature BETWEEN 32 AND 60 THEN 'Mild'
               ELSE 'Hot'
           END AS temp_range
    FROM train
    JOIN features USING (Store, Date)
 ) AS t
 GROUP BY temp_range;

-- 11. Join train, stores, and features (store, dept, date, sales, type, temp, fuel). 
SELECT 
    t.Store, 
    t.Dept, 
    t.Date, 
    t.Weekly_Sales, 
    s.Type, 
    f.Temperature, 
    f.Fuel_Price
FROM train t
JOIN stores s
      ON s.Store = t.Store
JOIN features f
      ON f.Store = t.Store
     AND f.Date = t.Date
ORDER BY t.Store, t.Date;

-- 12. Which store type (A/B/C) generates the highest yearly revenue? 
SELECT Type, YEAR(Date) AS Year, SUM(Weekly_Sales)
FROM train t JOIN stores s USING (Store)
GROUP BY Type, YEAR(Date);

-- 13. Does unemployment rate affect sales? 
SELECT 
    CASE
        WHEN F.Unemployment < 5 THEN 'Very Low (0–5%)'
        WHEN F.Unemployment BETWEEN 5 AND 7 THEN 'Low (5–7%)'
        WHEN F.Unemployment BETWEEN 7 AND 9 THEN 'Medium (7–9%)'
        ELSE 'High (9%+)'
    END AS Unemployment_Range,
    AVG(T.Weekly_Sales) AS Avg_Sales
FROM train T
JOIN features F
      ON T.Store = F.Store 
     AND T.Date  = F.Date
GROUP BY Unemployment_Range
ORDER BY Avg_Sales DESC;

-- 14. Compare sales on holiday vs non-holiday for each store. 
SELECT Store, IsHoliday, AVG(Weekly_Sales)
FROM train
GROUP BY Store, IsHoliday;

-- 15. Which 5 stores show the highest YoY sales growth? 
WITH yearly_sales AS (
    SELECT 
        Store,
        YEAR(Date) AS Year,
        SUM(Weekly_Sales) AS Total_Sales
    FROM train
    GROUP BY Store, YEAR(Date)
),

yoy_calc AS (
    SELECT 
        Store,
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (PARTITION BY Store ORDER BY Year) AS Prev_Year_Sales,
        (Total_Sales - LAG(Total_Sales) OVER (PARTITION BY Store ORDER BY Year)) 
            / LAG(Total_Sales) OVER (PARTITION BY Store ORDER BY Year) * 100 
            AS YoY_Growth_Percent
    FROM yearly_sales
)

SELECT Store, Year, YoY_Growth_Percent
FROM yoy_calc
WHERE YoY_Growth_Percent IS NOT NULL   -- Remove first year (no previous data)
ORDER BY YoY_Growth_Percent DESC
LIMIT 5;

-- 16. Top 3 hottest days per store (ROW_NUMBER). 
WITH TempRank AS (
    SELECT 
        t.Store,
        t.Date,
        f.Temperature,
        t.Weekly_Sales,
        ROW_NUMBER() OVER (
            PARTITION BY t.Store 
            ORDER BY f.Temperature DESC
        ) AS rn
    FROM train t
    JOIN features f
          ON f.Store = t.Store
         AND f.Date = t.Date
)
SELECT *
FROM TempRank
WHERE rn <= 3
ORDER BY Store, rn;

-- 17. Compute moving 4-week average of sales for each store. 
SELECT Store, Date, Weekly_Sales,
        AVG(Weekly_Sales) OVER (PARTITION BY Store ORDER BY Date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS 4_WEEK_AVG
 FROM train;

-- 18. Week-over-week difference (LAG). 
WITH WoW AS (
    SELECT 
        store,
        dept,
        date,
        weekly_sales,
        LAG(weekly_sales) OVER (PARTITION BY store, dept ORDER BY date) AS prev_week_sales
    FROM train
)
SELECT *,
       weekly_sales - prev_week_sales AS wow_change
FROM WoW;

-- 19. Top department per store using ROW_NUMBER / RANK. 
WITH dept_sales AS (
    SELECT 
        store,
        dept,
        SUM(weekly_sales) AS total_sales
    FROM train
    GROUP BY store, dept
), 
ranked AS (
    SELECT 
        store,
        dept,
        total_sales,
        RANK() OVER (PARTITION BY store ORDER BY total_sales DESC) AS rnk
    FROM dept_sales
)
SELECT *
FROM ranked
WHERE rnk <= 3
ORDER BY store, rnk;

-- 20. Compute cumulative yearly sales for each store. 
SELECT Store, YEAR(Date),
        SUM(Weekly_Sales) OVER (PARTITION BY Store, YEAR(Date) ORDER BY Date) AS CUMULATIVE_YEARLY_SALES
 FROM train;

-- 21. Holiday sales ≥ 20% higher than non-holiday. 

WITH holiday_vs_nonholiday AS (
    SELECT 
        Store,
        AVG(CASE WHEN IsHoliday = 1 THEN Weekly_Sales END) AS Holiday_Avg,
        AVG(CASE WHEN IsHoliday = 0 THEN Weekly_Sales END) AS NonHoliday_Avg
    FROM train
    GROUP BY Store
)

SELECT 
    Store,
    Holiday_Avg,
    NonHoliday_Avg,
    ((Holiday_Avg - NonHoliday_Avg) / NonHoliday_Avg) * 100 AS Percent_Increase
FROM holiday_vs_nonholiday
WHERE Holiday_Avg >= 1.20 * NonHoliday_Avg
ORDER BY Percent_Increase DESC;

-- 22. 3-year continuous growth by department. 
WITH yearly_sales AS (
    SELECT 
        Dept,
        Store,
        YEAR(Date) AS Year,
        SUM(Weekly_Sales) AS Total_Sales
    FROM train
    GROUP BY Dept, Store, YEAR(Date)
),

growth_calc AS (
    SELECT 
        Dept,
        Store,
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (PARTITION BY Store, Dept ORDER BY Year) AS Prev_Year_Sales,
        LAG(Total_Sales, 2) OVER (PARTITION BY Store, Dept ORDER BY Year) AS Prev2_Year_Sales
    FROM yearly_sales
)

SELECT 
    Store,
    Dept,
    Year,
    Total_Sales
FROM growth_calc
WHERE Total_Sales > Prev_Year_Sales
  AND Prev_Year_Sales > Prev2_Year_Sales;
  
-- 23. Bottom 10 stores by profitability after markdowns. 
WITH sales_markdowns AS (
    SELECT 
        t.Store,
        SUM(t.Weekly_Sales) AS Total_Sales,
        SUM(IFNULL(f.MarkDown1,0) +
            IFNULL(f.MarkDown2,0) +
            IFNULL(f.MarkDown3,0) +
            IFNULL(f.MarkDown4,0) +
            IFNULL(f.MarkDown5,0)) AS Total_Markdowns
    FROM train t
    JOIN features f
        ON t.Store = f.Store
       AND t.Date = f.Date
    GROUP BY t.Store
),

profit_calc AS (
    SELECT
        Store,
        Total_Sales,
        Total_Markdowns,
        (Total_Sales - Total_Markdowns) AS Profit
    FROM sales_markdowns
)

SELECT *
FROM profit_calc
ORDER BY Profit ASC
LIMIT 10;

-- 24. Stores outperforming chain-wide average each year. 
WITH yearly_sales AS (
    SELECT 
        Store,
        YEAR(Date) AS Year,
        SUM(Weekly_Sales) AS Store_Year_Sales
    FROM train
    GROUP BY Store, YEAR(Date)
),

chain_average AS (
    SELECT 
        YEAR(Date) AS Year,
        AVG(Weekly_Sales) AS Chain_Avg_Sales
    FROM train
    GROUP BY YEAR(Date)
),

comparison AS (
    SELECT 
        y.Store,
        y.Year,
        y.Store_Year_Sales,
        c.Chain_Avg_Sales
    FROM yearly_sales y
    JOIN chain_average c
        ON y.Year = c.Year
    WHERE y.Store_Year_Sales > c.Chain_Avg_Sales
)

SELECT Store
FROM comparison
GROUP BY Store
HAVING COUNT(*) = (SELECT COUNT(DISTINCT YEAR(Date)) FROM train);

-- 25. Seasonality trend: highest selling month for each store.
WITH monthly_sales AS (
    SELECT 
        Store,
        MONTH(Date) AS Month,
        SUM(Weekly_Sales) AS Total_Sales
    FROM train
    GROUP BY Store, MONTH(Date)
),

ranked AS (
    SELECT
        Store,
        Month,
        Total_Sales,
        ROW_NUMBER() OVER (PARTITION BY Store ORDER BY Total_Sales DESC) AS rn
    FROM monthly_sales
)

SELECT Store, Month AS Best_Month, Total_Sales
FROM ranked
WHERE rn = 1
ORDER BY Store;

-- 26. Create view: vw_store_sales_summary. 
CREATE OR REPLACE VIEW vw_store_sales_summary AS
SELECT
    T.Store,
    YEAR(T.Date) AS Year,
    SUM(T.Weekly_Sales) AS TotalSales,
    AVG(T.Weekly_Sales) AS AvgSales,
    MAX(T.Weekly_Sales) AS MaxSales,
    S.Type AS StoreType,
    S.Size
FROM train T
JOIN stores S
      ON S.Store = T.Store
GROUP BY 
    T.Store,
    YEAR(T.Date),
    S.Type,
    S.Size;
    
-- 27. Create combined view (train + features + stores). 
CREATE OR REPLACE VIEW vw_walmart_full AS
SELECT
    T.Store,
    T.Dept,
    T.Date,
    T.Weekly_Sales,
    T.IsHoliday AS Train_IsHoliday,
    S.Type AS StoreType,
    S.Size AS StoreSize,
    F.Temperature,
    F.Fuel_Price,
    F.MarkDown1,
    F.MarkDown2,
    F.MarkDown3,
    F.MarkDown4,
    F.MarkDown5,
    F.CPI,
    F.Unemployment,
    F.IsHoliday AS Feature_IsHoliday
FROM train T
JOIN stores S
      ON S.Store = T.Store
JOIN features F
      ON F.Store = T.Store
     AND F.Date = T.Date;

-- 28. Stored Procedure: get_store_performance(store_id). 
DELIMITER $$

CREATE PROCEDURE get_store_performance(IN p_store INT)
BEGIN
    -- Basic KPIs
    SELECT 
        Store,
        SUM(Weekly_Sales) AS Total_Sales,
        AVG(Weekly_Sales) AS Avg_Sales,
        MIN(Weekly_Sales) AS Min_Sales,
        MAX(Weekly_Sales) AS Max_Sales
    FROM train
    WHERE Store = p_store
    GROUP BY Store;

    -- Year-over-year trend
    SELECT
        YEAR(Date) AS Year,
        SUM(Weekly_Sales) AS Yearly_Sales
    FROM train
    WHERE Store = p_store
    GROUP BY YEAR(Date)
    ORDER BY Year;
END $$

DELIMITER ;

CALL get_store_performance(5);

-- 29. Stored Procedure: compare_stores(store1_id, store2_id). 
DELIMITER $$

CREATE PROCEDURE compare_stores(
    IN p_store1 INT,
    IN p_store2 INT
)
BEGIN
    SELECT
        Store,
        SUM(Weekly_Sales) AS Total_Sales,
        AVG(Weekly_Sales) AS Avg_Sales,
        MIN(Weekly_Sales) AS Min_Sales,
        MAX(Weekly_Sales) AS Max_Sales
    FROM train
    WHERE Store IN (p_store1, p_store2)
    GROUP BY Store;
END $$

DELIMITER ;

CALL compare_stores(1, 2);

-- 30. Trigger to log inserts to audit table. 
-- Audit table to store insert logs
CREATE TABLE IF NOT EXISTS sales_audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    store INT,
    dept INT,
    date DATE,
    weekly_sales DECIMAL(10,2),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER trg_sales_insert_audit
AFTER INSERT ON train
FOR EACH ROW
BEGIN
    INSERT INTO sales_audit_log (store, dept, date, weekly_sales)
    VALUES (NEW.Store, NEW.Dept, NEW.Date, NEW.Weekly_Sales);
END $$

DELIMITER ;
-- 31. Trigger to prevent weekly_sales < 0. 
DELIMITER $$

CREATE TRIGGER trg_prevent_negative_sales
BEFORE INSERT ON train
FOR EACH ROW
BEGIN
    IF NEW.Weekly_Sales < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: Weekly_Sales cannot be negative.';
    END IF;
END $$

DELIMITER ;

-- 32. Identify 10 underperforming stores. 
WITH yearly_sales AS (
    SELECT 
        Store,
        YEAR(Date) AS Year,
        SUM(Weekly_Sales) AS Total_Sales
    FROM train
    GROUP BY Store, YEAR(Date)
),

yoy AS (
    SELECT 
        Store,
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (PARTITION BY Store ORDER BY Year) AS Prev_Year_Sales,
        (Total_Sales - LAG(Total_Sales) OVER (PARTITION BY Store ORDER BY Year)) 
            AS YoY_Change
    FROM yearly_sales
),

store_summary AS (
    SELECT
        Store,
        SUM(Total_Sales) AS Total_Store_Sales,
        AVG(YoY_Change) AS Avg_YoY_Change
    FROM yoy
    GROUP BY Store
),

unemployment_effect AS (
    SELECT
        T.Store,
        AVG(F.Unemployment) AS Avg_Unemployment
    FROM train T
    JOIN features F
        ON T.Store = F.Store
       AND T.Date  = F.Date
    GROUP BY T.Store
)

SELECT 
    s.Store,
    s.Total_Store_Sales,
    s.Avg_YoY_Change,
    u.Avg_Unemployment
FROM store_summary s
JOIN unemployment_effect u USING (Store)
ORDER BY 
    s.Total_Store_Sales ASC,      -- low sales
    s.Avg_YoY_Change ASC          -- negative or low growth
LIMIT 10;

-- 33. Store format for highest next-quarter inventory. 
WITH store_metrics AS (
    SELECT
        T.Store,
        S.Type,
        AVG(T.Weekly_Sales) AS Avg_Sales,
        SUM(T.Weekly_Sales) AS Total_Sales
    FROM train T
    JOIN stores S ON S.Store = T.Store
    GROUP BY T.Store, S.Type
),

type_summary AS (
    SELECT
        Type,
        AVG(Avg_Sales) AS Type_Avg_Sales,
        SUM(Total_Sales) AS Type_Total_Sales,
        COUNT(*) AS Store_Count
    FROM store_metrics
    GROUP BY Type
)

SELECT 
    Type,
    Type_Avg_Sales,
    Type_Total_Sales,
    Store_Count
FROM type_summary
ORDER BY Type_Avg_Sales DESC;

-- 34. Price sensitivity model using Fuel Price + CPI. 

WITH econ_buckets AS (
    SELECT
        T.Store,
        T.Weekly_Sales,
        CASE 
            WHEN F.Fuel_Price < 3 THEN 'Low Fuel Price'
            WHEN F.Fuel_Price BETWEEN 3 AND 3.75 THEN 'Medium Fuel Price'
            ELSE 'High Fuel Price'
        END AS Fuel_Range,
        CASE 
            WHEN F.CPI < 150 THEN 'Low CPI'
            WHEN F.CPI BETWEEN 150 AND 200 THEN 'Medium CPI'
            ELSE 'High CPI'
        END AS CPI_Range
    FROM train T
    JOIN features F
        ON T.Store = F.Store
       AND T.Date  = F.Date
)

SELECT
    Fuel_Range,
    CPI_Range,
    AVG(Weekly_Sales) AS Avg_Sales
FROM econ_buckets
GROUP BY Fuel_Range, CPI_Range
ORDER BY Fuel_Range, CPI_Range;
