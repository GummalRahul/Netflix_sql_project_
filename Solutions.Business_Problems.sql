-- Solutions of the Business Problems
-- 1. How can we split the combined genres in the listed_in column so each genre appears in its own row for detailed genre analysis?.
-- A. 

SELECT DISTINCT 
    TRIM((value)) AS Genre
FROM 
    netflix_data
CROSS APPLY 
    STRING_SPLIT(listed_in, ',');

-- 2. 


