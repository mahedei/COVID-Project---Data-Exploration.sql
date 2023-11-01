## 1/ Identify trends in movie release dates and analyze their impact on revenue.

     --- 

SELECT
    EXTRACT(YEAR FROM release_date) AS release_year,
    COUNT(*) AS movie_count,
    AVG(revenue) AS average_revenue
FROM
    movies
WHERE
    EXTRACT(YEAR FROM release_date) BETWEEN 1865 AND 2023
GROUP BY
    release_year
ORDER BY
    release_year;
	
	--- 
	
	SELECT
    r.release_year,
    r.movie_count,
    t.average_revenue
FROM
    (
        SELECT
            EXTRACT(YEAR FROM release_date) AS release_year,
            COUNT(*) AS movie_count
        FROM
            movies
        GROUP BY
            release_year
    ) r
    LEFT JOIN (
        SELECT
            EXTRACT(YEAR FROM release_date) AS release_year,
            AVG(revenue) AS average_revenue
        FROM
            movies
        GROUP BY
            release_year
    ) t ON r.release_year = t.release_year
ORDER BY
    r.release_year;
	

## 2/ Analyze the realationship between budget, revenue, and popularity to determine factors
      that contribute to a movies success. (solution_1)
	  
	  --- Calculate Basic Statistics:
	  SELECT
    COUNT(*) AS total_movies,
    AVG(budget) AS avg_budget,
    AVG(revenue) AS avg_revenue,
    AVG(popularity) AS avg_popularity,
    MIN(budget) AS min_budget,
    MAX(budget) AS max_budget,
    MIN(revenue) AS min_revenue,
    MAX(revenue) AS max_revenue,
    MIN(popularity) AS min_popularity,
    MAX(popularity) AS max_popularity
FROM movies;


       --- Correlation Analysis:
	   SELECT
    CORR(budget, revenue) AS budget_revenue_correlation,
    CORR(budget, popularity) AS budget_popularity_correlation,
    CORR(revenue, popularity) AS revenue_popularity_correlation
FROM movies;


       --- Determine Success Factors:
	   
	   WITH successful_movies AS (
    SELECT *
    FROM movies
    WHERE revenue > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) FROM movies)
)
SELECT
    AVG(budget) AS avg_budget_successful,
    AVG(revenue) AS avg_revenue_successful,
    AVG(popularity) AS avg_popularity_successful
FROM successful_movies;

WITH unsuccessful_movies AS (
    SELECT *
    FROM movies
    WHERE revenue <= (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) FROM movies)
)
SELECT
    AVG(budget) AS avg_budget_unsuccessful,
    AVG(revenue) AS avg_revenue_unsuccessful,
    AVG(popularity) AS avg_popularity_unsuccessful
FROM unsuccessful_movies;



    --- (solution_2)

 SELECT
    AVG(revenue) AS avg_revenue,
    AVG(budget) AS avg_budget,
    AVG(popularity) AS avg_popularity
FROM movies
WHERE status = 'Released'  -- Consider only released movies (you can adjust this condition as needed);




## 3/ Explopre the impact of movie genres on popularity and revenue.


WITH genre_split AS (
    SELECT id, unnest(string_to_array(genres, ', ')) AS genre
    FROM movies
)
SELECT
    genre,
    AVG(popularity) AS average_popularity,
    AVG(revenue) AS average_revenue
FROM
    genre_split
JOIN
    movies ON genre_split.id = movies.id
GROUP BY
    genre
ORDER BY
    average_popularity DESC, average_revenue DESC;
	
	--- Explopre the impact of movie genres on popularity and revenue and average_vote.
	
	SELECT
    g.genre_name AS genre,
    AVG(m.vote_average) AS average_vote,
    SUM(m.revenue) AS total_revenue,
    AVG(m.popularity) AS average_popularity
FROM
    movies m
JOIN (
    SELECT DISTINCT id, unnest(string_to_array(genres, ', ')) AS genre_name
    FROM movies
) g ON g.id = m.id
GROUP BY g.genre_name
ORDER BY total_revenue DESC;
	
	
	
	
## 4/ Identify successful production companies and analyze their strategies.

  --- Calculate the total revenue for each production company
  
SELECT
    production_companies,
    SUM(revenue) AS total_revenue
FROM
    movies
	where 
	production_companies is not null
GROUP BY
    production_companies
ORDER BY
    total_revenue DESC;
	
	--- identifies production companies with an average vote greater than 7
	     and a revenue greater than $100 million.
		 
   SELECT
    production_companies,
    AVG(vote_average) AS average_vote,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS movie_count
FROM movies
WHERE vote_average > 7 AND revenue > 100000000
GROUP BY production_companies
HAVING COUNT(*) > 5 -- You can adjust this threshold based on your definition of success
ORDER BY total_revenue DESC;


     --- Identify (top 30/20/50) Successful Production Companies.
	 SELECT
    production_companies,
    SUM(revenue) AS total_revenue
FROM movies
where production_companies is not null
GROUP BY production_companies
ORDER BY total_revenue DESC
LIMIT 50;


   --- Analyze Their Strategies.
   
WITH top_production_companies AS (
    SELECT
        production_companies AS company,
        SUM(revenue) AS total_revenue
    FROM movies
    GROUP BY company
    ORDER BY total_revenue DESC
    LIMIT 50
)
SELECT
    tpc.company,
    COUNT(*) AS movie_count,
    AVG(vote_average) AS average_vote,
    AVG(popularity) AS average_popularity,
    MAX(tpc.total_revenue) AS total_revenue
FROM movies AS m
JOIN top_production_companies AS tpc
ON m.production_companies = tpc.company
GROUP BY tpc.company
ORDER BY total_revenue DESC;




      --- Identify Successful Production Companies (only released movies).
	     
		 WITH successful_movies AS (
    SELECT
        id,
        title,
        vote_average,
        revenue,
        production_companies
    FROM
        movies
    WHERE
        status = 'Released'  
        AND revenue > 0  
)

SELECT
    pc.company_name,
    COUNT(sm.id) AS total_movies,
    AVG(sm.vote_average) AS average_vote,
    SUM(sm.revenue) AS total_revenue
FROM
    successful_movies AS sm
    CROSS JOIN LATERAL unnest(string_to_array(sm.production_companies, '|')) AS pc(company_name)
GROUP BY
    pc.company_name
ORDER BY
    total_revenue DESC;



      --- Analyze Their Strategies (only released movies).
	  
	  WITH ProductionCompanyRevenue AS (
    SELECT
        production_companies AS company,
        SUM(revenue) AS total_revenue
    FROM
        movies
    WHERE
        status = 'Released' -- Consider only released movies
    GROUP BY
        production_companies
)

SELECT
    company,
    SUM(total_revenue) AS total_revenue,
    COUNT(DISTINCT id) AS total_movies_produced,
    AVG(vote_average) AS average_vote,
    AVG(runtime) AS average_runtime
FROM
    movies
    JOIN ProductionCompanyRevenue ON movies.production_companies = ProductionCompanyRevenue.company
WHERE
    status = 'Released' -- Consider only released movies
GROUP BY
    company
ORDER BY
    total_revenue DESC
LIMIT 30; --- you can change LIMIT value.





## 5/ Investigate the correlation between runtime and audience engagement
   
   --- correlation between runtime and vote average:

  SELECT CORR(runtime, vote_average) AS correlation
FROM movies;

  --- correlation between runtime and vote_count:
SELECT CORR(runtime, vote_count) AS correlation
FROM movies;




## 6/ utilize naturle language processing techniques to extract meaningful insights from movie overviews.

SELECT id, regexp_split_to_table(overview, E'\\s+') AS token
FROM movies;

SELECT token, COUNT(*) AS frequency
FROM (
  SELECT id, regexp_split_to_table(overview, E'\\s+') AS token
  FROM movies
) AS tokenized
WHERE token != ''
GROUP BY token
ORDER BY frequency DESC;


## 7/ Visualize movie popularity over time and identify popular genres in different periods.


 -- Step 2: Extract the year from the release_date
SELECT
    EXTRACT(YEAR FROM release_date) AS release_year,
    popularity
INTO
    temp_popularity
FROM
    movies;

-- Step 3: Group by year and calculate popularity
SELECT
    release_year,
    SUM(popularity) AS total_popularity
FROM
    temp_popularity
	where 
	release_year is not null
GROUP BY
    release_year
ORDER BY
    release_year;


-- Step 4: Identify popular genres
WITH genre_popularity AS (
    SELECT
        EXTRACT(YEAR FROM m.release_date) AS release_year,
        genre AS genres,
        SUM(m.popularity) AS genre_popularity
    FROM
        movies m
    CROSS JOIN LATERAL unnest(string_to_array(m.genres, ',')) AS genre
    GROUP BY
        release_year, genre
)  
-- Step 5: Data Visualization
SELECT
    release_year,
    genres,
    SUM(genre_popularity) AS total_genre_popularity
FROM
    genre_popularity
	where release_year is not null
GROUP BY
    release_year, genres
ORDER BY
    release_year, total_genre_popularity DESC;




## 8/ top 50 movies by revenue up to 1000000, and vote_average (10, 9, 8) 


SELECT
    title,
    vote_average,
    status,
    release_date,
    revenue,
    runtime,
    adult,
    tagline,
    genres,
    production_companies
FROM movies
WHERE 
    title IS NOT NULL
    AND popularity IS NOT NULL
    AND runtime IS NOT NULL
    AND status IS NOT NULL
    AND release_date IS NOT NULL
    AND revenue IS NOT NULL
    AND adult IS NOT NULL
    AND tagline IS NOT NULL
    AND genres IS NOT NULL
    AND production_companies IS NOT NULL
    AND revenue >= 1000000
    AND vote_average IN (10, 9, 8)
	AND runtime >= 100
ORDER BY vote_average DESC, popularity DESC, runtime DESC
LIMIT 50;




