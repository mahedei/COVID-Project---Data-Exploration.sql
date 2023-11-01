-- create table & copy command is only for SQL Server Management Studio (SSMS).

CREATE TABLE coc (
    clan_tag VARCHAR(255),
    clan_name VARCHAR(255),
    clan_type VARCHAR(255),
    clan_location VARCHAR(255),
    isFamilyFriendly BOOLEAN,
    clan_level INT,
    clan_points INT,
    clan_builder_base_points INT,
    clan_versus_points INT,
    required_trophies INT,
    war_frequency VARCHAR(255),
    war_win_streak INT,
    war_wins INT,
    war_ties INT,
    war_losses INT,
    clan_war_league VARCHAR(255),
    num_members INT,
    required_builder_base_trophies INT,
    required_versus_trophies INT,
    required_townhall_level INT,
    clan_capital_hall_level INT,
    clan_capital_points INT,
    capital_league VARCHAR(255),
    mean_member_level INT,
    mean_member_trophies INT
);



COPY coc
FROM 'D:\DataAnalayst\excel\archive_10\coc.csv'
WITH CSV HEADER; -- Assuming the first row is a header

select *
from coc;



 

------------ Querys for coc

   ## 1/ Visualize the distribution of clan points and member levels to identify high-perfoming clans. 


SELECT
    clan_name,
    clan_points,
    mean_member_level
FROM
    coc
WHERE
    clan_points IS NOT NULL
    AND mean_member_level IS NOT NULL;

   ## 1/ (for dashboard) 
      Vizualize (top 100) the distribution of clan points(up to 1000) and member(up to 100) levels to identify high-perfoming clans.

SELECT 
    clan_name,
    clan_points,
    mean_member_level
FROM
    coc
WHERE
    clan_name IS NOT NULL
    AND clan_points IS NOT NULL
	AND mean_member_level IS NOT NULL
    AND clan_points >= 1000
    AND mean_member_level BETWEEN 50 AND 200
	
ORDER BY
    clan_points DESC, num_members DESC
	LIMIT 100;
	
	
	## 2/ Analyze war statistics to find the most successful clans in terms of win streaks, war wins, and ties.
	
	
SELECT
    clan_name,
    war_win_streak,
    war_wins,
    war_ties
FROM
    coc
WHERE
    war_win_streak IS NOT NULL
    AND war_wins IS NOT NULL
    AND war_ties IS NOT NULL
ORDER BY
    war_win_streak DESC, war_wins DESC, war_ties DESC;
	
	## 2/ (for dashboard) Analyze (top 100) war statistics to find the most successful clans in terms of win streaks(mini 50), war wins(mini 100), and ties(mini 10).
	
	SELECT
    clan_tag,
    clan_name,
    war_win_streak,
    war_wins,
    war_ties
FROM coc
WHERE 
    -- war_win_streak <=100
  war_wins BETWEEN 800 AND 1500
  -- AND war_ties BETWEEN 1 AND 100
    AND clan_tag IS NOT NULL
    AND clan_name IS NOT NULL
    
ORDER BY war_win_streak DESC, war_wins DESC, war_ties DESC
   LIMIT 100;
	
	
	
	## 3/ Vizu / Investigate the correlation between clan location and clan popularity
	      (or the countries where the clash of clans is most popular )
	
	
	SELECT 
    clan_location,
    COUNT(*) AS popularity_count
FROM coc
WHERE clan_location IS NOT NULL
GROUP BY clan_location
ORDER BY popularity_count DESC;


   ## 4/ Vizu / Find the countries with the highest rank players.
   
   
   SELECT
    clan_location AS Country,
    AVG(mean_member_trophies) AS Average_Trophies
FROM
    coc
WHERE
    clan_location IS NOT NULL
GROUP BY
    clan_location
ORDER BY
    Average_Trophies DESC;


	## 5/ Vizu / Determine the percentage of clans that focus on the Builder Base or Clan Capital.
	
	
	
	SELECT
    SUM(CASE WHEN clan_builder_base_points IS NOT NULL THEN 1 ELSE 0 END) AS BuilderBaseCount,
    SUM(CASE WHEN clan_capital_points IS NOT NULL THEN 1 ELSE 0 END) AS ClanCapitalCount,
    COUNT(*) AS TotalClans,
    (SUM(CASE WHEN clan_builder_base_points IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS BuilderBasePercentage,
    (SUM(CASE WHEN clan_capital_points IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS ClanCapitalPercentage
FROM coc
WHERE clan_builder_base_points IS NOT NULL OR clan_capital_points IS NOT NULL;



     ## 6/ Analyze the distribution of clans in term of clan points, clan level, clan capital points, etc.
	 
	 
	SELECT 
    clan_points,
    clan_level,
    clan_capital_points,
    COUNT(*) AS clan_count
FROM coc
WHERE clan_points IS NOT NULL
    AND clan_level IS NOT NULL
    AND clan_capital_points IS NOT NULL
GROUP BY 
    clan_points,
    clan_level,
    clan_capital_points
ORDER BY 
    clan_points,
    clan_level,
    clan_capital_points;


  ## 7/  Top 500 clan names with tagline and their league ranks.
  
   SELECT 
    clan_tag,
    clan_name,
    war_wins,
    clan_war_league
FROM coc
WHERE
    clan_tag IS NOT NULL
    AND clan_name IS NOT NULL
    AND war_wins IS NOT NULL
	AND war_wins BETWEEN 500 AND 1500
    AND clan_war_league IN (
        'Gold League I',
        'Gold League II',
        'Gold League III',
        'Bronze League I',
        'Bronze League II',
        'Bronze League III',
        'Silver League I',
        'Silver League II',
        'Silver League III',
        'Legend League',
        'Crystal League I',
        'Crystal League II',
        'Crystal League III',
        'Master League I',
        'Master League II',
        'Master League III',
        'Titan League I',
        'Titan League II',
        'Titan League III',
        'Champion League I',
        'Champion League II',
        'Champion League III'
    )
ORDER BY clan_war_league
 LIMIT 500;





	
	
	

