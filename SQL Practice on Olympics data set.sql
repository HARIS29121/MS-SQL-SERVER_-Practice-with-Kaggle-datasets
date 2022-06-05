USE sql_practice
SELECT TOP(5) *  FROM [dbo].[OLYMPICS_HISTORY]
SELECT TOP(5) * FROM [dbo].[OLYMPICS_HISTORY_NOC_REGIONS]

--Q1. How many olympics games have been held?
--Problem Statement: Write a SQL query to find the total no of Olympic Games held as per the dataset. 

SELECT COUNT(DISTINCT Games) AS 'Total No.of Olympic Games'
FROM [dbo].[OLYMPICS_HISTORY]

--Q2. List down all Olympics games held so far.
--Problem Statement: Write a SQL query to list down all the Olympic Games held so far.

SELECT DISTINCT YEAR , Season, City
FROM OLYMPICS_HISTORY
ORDER BY YEAR ASC

--Q3. Mention the total no of nations who participated in each olympics game?
--Problem Statement: SQL query to fetch total no of countries participated in each olympic games.

--SELECT CONCAT(YEAR,' ',Season) AS games, COUNT(DISTINCT NOC) AS Total_Countries
--FROM OLYMPICS_HISTORY
--GROUP BY  YEAR , Season
--ORDER BY YEAR ASC

SELECT Games, COUNT(DISTINCT NOC) AS Total_Countries
FROM OLYMPICS_HISTORY
GROUP BY Games
ORDER BY Games ASC


--Q4. Which year saw the highest and lowest no of countries participating in olympics
--Problem Statement: Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.

WITH T1 AS 
(SELECT Games,COUNT(DISTINCT NOC) as TOTAL_COUNTRIES
FROM OLYMPICS_HISTORY
GROUP BY Games)
SELECT DISTINCT 
CONCAT(FIRST_VALUE(Games) OVER(ORDER BY TOTAL_COUNTRIES),
'-',FIRST_VALUE(TOTAL_COUNTRIES) OVER (ORDER BY TOTAL_COUNTRIES)) AS LOWEST_COUNTRIES,
CONCAT(FIRST_VALUE(Games) OVER(ORDER BY TOTAL_COUNTRIES DESC),
'-',FIRST_VALUE(TOTAL_COUNTRIES) OVER (ORDER BY TOTAL_COUNTRIES DESC)) AS HIGHEST_COUNTRIES
FROM T1

--5. Which nation has participated in all of the olympic games
-- Problem Statement: SQL query to return the list of countries who have been part of every Olympics games.

WITH T1 AS 
   (SELECT Team AS COUNTRY,COUNT(DISTINCT Games) AS TOTAL_GAMES
    FROM OLYMPICS_HISTORY
    GROUP BY Team)
SELECT * FROM T1
WHERE TOTAL_GAMES=(SELECT COUNT(DISTINCT Games) FROM OLYMPICS_HISTORY)

--6. Identify the sport which was played in all summer olympics.
--Problem Statement: SQL query to fetch the list of all sports which have been part of every olympics.

WITH T1 AS
(SELECT count (DISTINCT Games) AS TOTAL_GAMES
FROM OLYMPICS_HISTORY
WHERE Games LIKE '%Summer%'),
T2 AS
(SELECT Sport, COUNT(DISTINCT Games) AS No_of_Games
FROM OLYMPICS_HISTORY WHERE Season = 'Summer'
GROUP BY Sport)
SELECT * FROM T2
JOIN 
T1 ON T2.No_of_Games = T1.TOTAL_GAMES

--7. Which Sports were just played only once in the olympics.

--Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics.

WITH T1 AS
(Select sport,COUNT (DISTINCT Games) AS no_of_games
FROM OLYMPICS_HISTORY
GROUP BY Sport),
T2 AS 
(Select DISTINCT games, Sport 
FROM OLYMPICS_HISTORY)
SElECT T2.*,T1.no_of_games FROM T1
JOIN T2 ON T2.Sport = T1.sport
WHERE no_of_games=1

--8. Fetch the total no of sports played in each olympic games.
--Problem Statement: Write SQL query to fetch the total no of sports played in each olympics.

SELECT Games,COUNT(DISTINCT Sport) AS Total_Sports
FROM OLYMPICS_HISTORY
GROUP BY Games
ORDER BY Total_Sports DESC

--9. Fetch oldest athletes to win a gold medal
--Problem Statement: SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.

WITH T1 AS
(
SELECT * , CAST(CASE WHEN Age = 'NA' THEN 0 Else Age End AS int) AS Age_New
FROM OLYMPICS_HISTORY
WHERE Medal='Gold'
)
select Name,Sex,Age,Team,Games,City,Sport, Event, Medal 
From T1
WHERE Age_New=(Select MAX(Age_New) From T1)

--11. Fetch the top 5 athletes who have won the most gold medals.
--Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals.

WITH T1 AS (
SElECT TOP(50)Name,Team,COUNT(Medal) AS Total_Gold_Medals
FROM OLYMPICS_HISTORY
WHERE Medal = 'Gold'
GROUP BY Team , Name
ORDER BY Total_Gold_Medals DESC),
T2 AS 
(
SELECT *,DENSE_RANK() OVER (ORDER BY Total_Gold_Medals DESC) MY_RANK
FROM T1)
SELECT Name,Team,Total_Gold_Medals FROM T2 WHERE MY_RANK<=5

--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
--Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).

WITH T1 AS (
SElECT TOP(50)Name,Team,COUNT(Medal) AS Total_Medals
FROM OLYMPICS_HISTORY
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Team , Name
ORDER BY Total_Medals DESC),
T2 AS 
(
SELECT *,DENSE_RANK() OVER (ORDER BY Total_Medals DESC) MY_RANK
FROM T1)
SELECT Name,Team,Total_Medals FROM T2 WHERE MY_RANK<=5

--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
--Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).

--1ST SOLUTON
SELECT TOP (5) OHR.region,COUNT(ID) AS Total_Medals
FROM OLYMPICS_HISTORY OH
JOIN OLYMPICS_HISTORY_NOC_REGIONS OHR
ON OHR.NOC=OH.NOC
WHERE Medal<>'NA'
GROUP BY OHR.region
ORDER BY Total_Medals DESC

--2ND SOLUTION
WITH T1 AS (
SELECT TOP (10) OHR.region,COUNT(ID) AS Total_Medals
FROM OLYMPICS_HISTORY OH
JOIN OLYMPICS_HISTORY_NOC_REGIONS OHR
ON OHR.NOC=OH.NOC
WHERE Medal<>'NA'
GROUP BY OHR.region
ORDER BY Total_Medals DESC),
T2 AS (
SELECT *,DENSE_RANK() OVER(ORDER BY Total_Medals DESC) RNK
FROM T1)
SELECT * FROM T2 WHERE RNK <=5

--14. List down total gold, silver and bronze medals won by each country.
--Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country.

WITH T1 AS
(SELECT region,COUNT(Medal) AS Total_Gold
FROM OLYMPICS_HISTORY OH
JOIN OLYMPICS_HISTORY_NOC_REGIONS OHR
ON OHR.NOC=OH.NOC
WHERE Medal<>'NA'AND Medal='Gold'
GROUP BY OHR.region),
T2 AS 
(SELECT region,COUNT(Medal) AS Total_Silver
FROM OLYMPICS_HISTORY OH
JOIN OLYMPICS_HISTORY_NOC_REGIONS OHR
ON OHR.NOC=OH.NOC
WHERE Medal<>'NA'AND Medal='Silver'
GROUP BY OHR.region),
T3 AS 
(SELECT region,COUNT(Medal) AS Total_Bronze
FROM OLYMPICS_HISTORY OH
JOIN OLYMPICS_HISTORY_NOC_REGIONS OHR
ON OHR.NOC=OH.NOC
WHERE Medal<>'NA'AND Medal='Bronze'
GROUP BY OHR.region)
SELECT T1.region,T1.Total_Gold,T2.Total_Silver,T3.Total_Bronze FROM T1
JOIN T2 ON T1.region = T2.region
JOIN T3 ON T1.region = T3.region
ORDER BY T1.Total_Gold DESC

--15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
--Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country corresponding to each olympic games.

--1st solution

SELECT * FROM 
(SELECT Games,OHR.region,Medal
FROM OLYMPICS_HISTORY OH
JOIN OLYMPICS_HISTORY_NOC_REGIONS OHR 
ON OHR.NOC=OH.NOC
WHERE Medal<>'NA') t
PIVOT(COUNT(medal) FOR Medal in([Gold],[Silver],[Bronze])) AS Pivot_Table
ORDER BY Games,region

--2nd Solution

SELECT DISTINCT games,region,
SUM(CASE WHEN Medal='Gold' THEN 1 ELSE 0 END) AS Gold,
SUM(CASE WHEN Medal='Silver' THEN 1 ELSE 0 END) AS Silver,
SUM(CASE WHEN Medal='Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM OLYMPICS_HISTORY OH
JOIN OLYMPICS_HISTORY_NOC_REGIONS OHR
ON OH.NOC=OHR.NOC
GROUP BY Games,region
ORDER BY Games,region

