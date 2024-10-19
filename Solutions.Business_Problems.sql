-- Solutions of the Business Problems
-- 1. Separate the combined genres in the listed_in column so that each genre appears as a distinct row.
-- A. 

SELECT DISTINCT 
    TRIM((value)) AS Genre
FROM 
    netflix_data
CROSS APPLY 
    STRING_SPLIT(listed_in, ',');

-- 2. 

