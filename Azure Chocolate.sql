/* --Copy Table script (need to delete table first)
SELECT * INTO dbo.chocolate_data_expand
FROM dbo.chocolate_data; */

--Cleaning Ingredients/Characteristics column, some ingredients have spaces between commas, some characteristics are lengthy
UPDATE dbo.chocolate_data_expand
SET Ingredients = right(Ingredients, len(Ingredients) - charindex('-', Ingredients))
UPDATE dbo.chocolate_data_expand
SET Ingredients = REPLACE(Ingredients, CHAR(32), ''),
    Most_Memorable_Characteristics = REPLACE(Most_Memorable_Characteristics, CHAR(32), '')
--SELECT TOP 3 * FROM dbo.chocolate_data_expand

--Finding average rating of cocoa%
SELECT Cocoa_Percent, Count(*) AS [Num_Records], AVG(Rating) AS [Average_Rating]
FROM dbo.chocolate_data
GROUP BY Cocoa_Percent
HAVING Count(*) > 1
ORDER BY AVG(Rating) desc;
--Highest rated cocoa percentage between 66%-69%, with a decent sample size

--Finding average rating by Company_Location, at least 5 records
SELECT Company_Location, Count(*) AS [Num_Records], AVG(Rating) AS [Average_Rating]
FROM dbo.chocolate_data
GROUP BY Company_Location
HAVING Count(*) >= 5
ORDER BY AVG(Rating) desc;
--USA holding the most with 1227, followed by Canada/France with ~186 each
--Top average spot goes to U.A.E. followed by Poland and Denmark

--Finding average rating of ingredients
SELECT TRIM([value]) as split_ingredients, AVG(Rating) AS [Average_Rating], COUNT([value])
FROM dbo.chocolate_data_expand
    CROSS APPLY string_split(Ingredients, ',')
GROUP BY [value]
ORDER BY Average_Rating DESC;
--Show individual ingredient Average Rating, Sugar highest and non-sugar sweetener lowest
--Does not take into account interactions of ingredients

--Finding average rating of characteristics
SELECT TRIM([value]) as split_characteristics, AVG(Rating) AS [Average_Rating], COUNT([value]) AS [CNT]
FROM dbo.chocolate_data_expand
    CROSS APPLY string_split(Most_Memorable_Characteristics, ',')
GROUP BY [value]
ORDER BY Average_Rating DESC;
--Doing a quick contextual analysis, pleasant-sounding and unique characteristics yield top rated chocolates

SELECT TRIM([value]) as split_characteristics, AVG(Rating) AS [Average_Rating], COUNT([value]) AS [CNT]
FROM dbo.chocolate_data_expand
    CROSS APPLY string_split(Most_Memorable_Characteristics, ',')
GROUP BY [value]
HAVING COUNT([value]) > 10
ORDER BY Average_Rating DESC;
--For more common chocolates, balanced and strong fruity flavors reign supreme

--Exploring unique characteristics
SELECT *
FROM dbo.chocolate_data_expand
    CROSS APPLY string_split(Most_Memorable_Characteristics, ',')
WHERE value = 'longandrich';
--can see this unique characteristic comes from Belgium,
--how many of these one-off ones come from there or other places?
WITH Choco_CTE
AS
(
    SELECT *
    FROM dbo.chocolate_data_expand
        CROSS APPLY string_split(Most_Memorable_Characteristics, ',')
),
Choco_CTE_2
AS
(
    SELECT value, AVG(Rating) AS [Average_Rating], COUNT([value]) AS [CNT]
    FROM Choco_CTE
    GROUP BY [value]
),
Choco_CTE_3
AS
(
    SELECT *
    FROM Choco_CTE_2
    WHERE CNT = 1
)
-- To find all rows with unique characteristics
SELECT *
FROM Choco_CTE_3
JOIN Choco_CTE ON Choco_CTE_3.value = Choco_CTE.value;

/* SELECT Company, Company_Location, AVG(Rating) AS average, COUNT(Company)
FROM Choco_CTE_3
JOIN Choco_CTE ON Choco_CTE_3.value = Choco_CTE.value
GROUP BY Company, Company_Location
ORDER BY average DESC; */

/* SELECT Company_Location, COUNT(Company_Location)
FROM Choco_CTE_3
JOIN Choco_CTE ON Choco_CTE_3.value = Choco_CTE.value
GROUP BY Company_Location
ORDER BY COUNT(Company_Location) DESC; */
--Seems U.S.A. has lots of top rated unique chocolate characteristics, but probably due to quantity of them
--Surprisingly, Chile and Vietnam who have 1 and 2 chocolates respectively, hold top 10 spots


--Notes for future project: Generate primary key for each entry to not double count rows when analyzing ingredients/characteristics