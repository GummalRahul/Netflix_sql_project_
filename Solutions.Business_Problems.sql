-- Solutions of the Business Problems
-- 1. How can we split the combined genres in the listed_in column so each genre appears in its own row for detailed genre analysis?.
-- A. 
SELECT DISTINCT 
    TRIM((value)) AS Genre
FROM 
    netflix_data
CROSS APPLY 
    STRING_SPLIT(listed_in, ',');

-- 2. Analyze Netflix's international content catalog (excluding U.S.) to gain insights into its global market penetration in different regions?
-- A.
select * from netfilx_data
where country != 'United States' and country is not null
	
-- 3. Find the distribution of TV Shows and Movies across genres and seasons?
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

-- 4. Categorize Movies and TV Shows as Short ,Medium,or Long based on their runtime and find the content distribution?
-- A.
WITH DurationCategories AS 
(	
	SELECT
        type,
        title,
        rating,
        CASE 
            WHEN type = 'TV Show' THEN
                CASE
                    WHEN TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) <= 1 THEN 'Short'
                    WHEN TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) BETWEEN 2 AND 3 THEN 'Medium'
                    ELSE 'Long'
                END
            WHEN type = 'Movie' THEN
                CASE
                    WHEN TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) < 90 THEN 'Short'
                    WHEN TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) BETWEEN 90 AND 120 THEN 'Medium'
                    ELSE 'Long'
                END
        END AS Duration_Category
    FROM 
        netfilx_data 
    WHERE 
        TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) IS NOT NULL 
)
SELECT 
    type,
    Duration_Category,
    COUNT(*) AS Content_Count
from
    DurationCategories 
GROUP BY 
    type,Duration_Category
ORDER BY 
    type, Duration_Category;

-- 5. Find the top 5 countries with the highest number of movies in the Netflix?
-- A.
with CTE as 
(
select country, 
count(type) as Movie_count,
row_number() over(order by count(type) desc) as rn
from netfilx_data
where type = 'Movie'and country is not null
group by country
)
select country,Movie_count from CTE
where rn <= 5
order by rn;
