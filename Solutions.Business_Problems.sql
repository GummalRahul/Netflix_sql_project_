-- Solutions of the Business Problems
-- 1. How can we split the combined genres in the listed_in column so each genre appears in its own row for detailed genre analysis?.
-- A. 

SELECT DISTINCT 
    TRIM((value)) AS Genre
FROM 
    netflix_data
CROSS APPLY 
    STRING_SPLIT(listed_in, ',');

-- 2. Find the distribution of TV Shows and Movies across genres and seasons?
-- A.
SELECT 
    MONTH(TRY_CONVERT(DATE, date_added, 101)) AS Month_Added,
    CASE 
        WHEN MONTH(TRY_CONVERT(DATE, date_added, 101)) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(TRY_CONVERT(DATE, date_added, 101)) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(TRY_CONVERT(DATE, date_added, 101)) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS Season_Added,
    listed_in AS Genre,
    type AS Content_Type,
    COUNT(*) AS Content_Count
FROM 
    netfilx_data
WHERE 
    TRY_CONVERT(DATE, date_added, 101) IS NOT NULL
GROUP BY 
    MONTH(TRY_CONVERT(DATE, date_added, 101)),
    CASE 
        WHEN MONTH(TRY_CONVERT(DATE, date_added, 101)) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(TRY_CONVERT(DATE, date_added, 101)) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(TRY_CONVERT(DATE, date_added, 101)) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END,
    listed_in,
    type
ORDER BY 
    Month_Added, Content_Count DESC;



