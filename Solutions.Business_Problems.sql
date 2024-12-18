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
WITH country_movie_counts AS (
    SELECT 
        TRIM(value) AS country,
        COUNT(*) AS movie_count
    FROM 
        netfilx_data
    CROSS APPLY STRING_SPLIT(country, ',')
    WHERE 
        TRIM(value) != 'United States' 
        AND TRIM(value) IS NOT NULL
        AND type = 'Movie' -- Only consider movies
    GROUP BY 
        TRIM(value)
)
SELECT 
    cmc.country,
    cmc.movie_count,
    (cmc.movie_count * 100.0) / (
        SELECT COUNT(*) 
        FROM netfilx_data
        CROSS APPLY STRING_SPLIT(country, ',')
        WHERE TRIM(value) != 'United States'
        AND TRIM(value) IS NOT NULL
        AND type = 'Movie'
    ) AS market_penetration
FROM 
    country_movie_counts cmc
ORDER BY 
    market_penetration DESC;

	
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
    trim ((Value)) as genre,
    type AS Content_Type,
    COUNT(*) AS Content_Count
FROM 
    netfilx_data
	cross apply string_split (listed_in,',')
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
    trim(value),
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


-- 6. List all the movies directed by Rajiv Chilaka?
-- A.
with Movie_Director as 
(
select type, title, trim ((value)) as Director
from 
netfilx_data
cross apply 
string_split(director,',')
)
select title,director
from Movie_Director
where Director is not null and Director like '%Rajiv Chilaka%'and type = 'Movie';


-- 7. Classify content as 'Bad' if the description contains 'kill' or 'violence,' otherwise label it as 'Good.' Count the number of items in each category?
-- A. 
select count(*) as movie_count,
case 
when description like '%kill%' or description like '%Voilence%' then 'Bad'
else 'good'
end as Movies_Category
from netfilx_data
where description is not null
group by
case 
when description like '%kill%' or description like '%Voilence%' then 'Bad'
else 'good'
end;


-- 8. Analyze the lag between a title’s original release year and the date it was added to Netflix?
-- A. 
WITH CTE
AS
(
SELECT show_id,
type,title,
date_added,
release_year,
DATEDIFF(MM,CAST(release_year AS Date),CAST(date_added AS DATE))AS lag_in_months 
from netfilx_data WHERE date_added <>'TV-PG' AND release_year <>'40 min'
)SELECT * FROM CTE;


-- 9. Find the top 10 actors who have appeared in the highest number of movies produced in India?
-- A.
with Top_Actors as
(
select type,
country,trim((value))as Actor,
count(*) over (partition by trim (value)) as Actor_count
from
netfilx_data
cross apply 
string_split(cast,',')
where country = 'India' and type = 'Movie'
)
select top 10 Actor,
Actor_count
from
Top_Actors
group by Actor,Actor_count
order by Actor_count desc;


-- 10. Find the Average duration of movies for each genre?
-- A. 
with Avg_duration as
(
select trim((value)) as genre,
Avg(cast(Replace(duration,' min','') as int)) as Duration,
type
from
netfilx_data
cross apply string_split(listed_in,',')
where type = 'Movie' and value != 'Movies'
group by trim(value),type
)
select * from Avg_duration;

-- End of Analysis
