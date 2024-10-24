# Netflix_Dataset_Analysis_using_SQL

![Netflix](https://github.com/GummalRahul/Netflix_sql_project_/blob/main/Netflix.logo.jpg)

## **Objectives** 

- Examine the top genres for each country and year, and correlate these genres with global or regional viewing trends.
- Analyze the genre composition and identify the most frequent genres by country and release year.
- Compare the performance of content types based on popularity metrics (views, ratings, or reviews) across different regions.
- Compare the ratio of movies to TV shows across different countries and identify regions with content type preferences.
- Analyze the release patterns of movies and TV shows over time, identifying seasonal or year-over-year trends.

## **Dataset** ##

The data for this project is sourced from the Kaggle dataset:

- The Dataset Link [Netflix_Dataset](https://www.kaggle.com/datasets/paramvir705/netflix-dataset)

## Schema of Netflix Table ##

``` sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions ##
### 1. How can we split the combined genres in the listed_in column so each genre appears in its own row for detailed genre analysis?.
``` sql
SELECT DISTINCT 
    TRIM((value)) AS Genre
FROM 
    netflix_data
CROSS APPLY 
    STRING_SPLIT(listed_in, ',');
```

### 2. Analyze Netflix's international content catalog (excluding U.S.) to gain insights into its global market penetration in different regions?
```sql
select * from netfilx_data
where country != 'United States' and country is not null
```

### 3. Find the distribution of TV Shows and Movies across genres and seasons?
``` sql
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
```

### 4. Categorize Movies and TV Shows as Short ,Medium,or Long based on their runtime and find the content distribution? 
``` sql
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
```

### 5. Find the top 5 countries with the highest number of movies in the Netflix?
```sql
with Movies_count as 
(
select country, 
count(type) as Movie_count,
row_number() over(order by count(type) desc) as rn
from netfilx_data
where type = 'Movie'and country is not null
group by country
)
select country,Movie_count from Movies_count
where rn <= 5
order by rn;
```
