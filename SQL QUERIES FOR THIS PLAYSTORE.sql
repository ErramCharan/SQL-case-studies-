--1.	You're working as a market analyst for a mobile app development company. Your task is to identify the
--most promising categories (TOP 5) for launching new free apps based on their average ratings.

use Lion
SELECT top 5 Category,AVG(Rating) as Average_rating
FROM PS
where Type= 'Free'
GROUP BY Category
order by Average_rating Desc 


--2.As a business strategist for a mobile app company, your objective is to pinpoint the three categories that generate the most revenue from paid apps.
--This calculation is based on the product of the app price and its number of installations

select * from PS

alter table ps
add Revenue as round((Price * Installs),2) ;

select top 3 Category,sum(Revenue) as Total_category
from ps 
where type= 'Paid'
group by Category
order by Total_category desc

--3.As a data analyst for a gaming company, you're tasked with calculating the percentage of apps within each category. This information will help the
--company understand the distribution of gaming apps across different categories
select * from PS


select category,cnt,round((cnt *1.0/total_count) * 100,2) as percentage_
from
(SELECT Category,count(APP) as cnt, (select COUNT(*) from ps) as total_count
from ps 
group by Category) as subquery
order by percentage_ desc;

--4.As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company should develop paid or free apps for each 
--category based on the ratings of that category.
select * from PS




SELECT 
    COALESCE(a.Category, b.Category) AS Category,  -- Handle categories present in either Paid or Free
    CASE 
        WHEN a.Average_rating_Paid > b.Average_rating_Free THEN 'Paid App'
        WHEN b.Average_rating_Free > a.Average_rating_Paid THEN 'Free App'
        ELSE 'Equal'  -- In case the ratings are equal, you can make a neutral recommendation
    END AS Recommended_App_Type
FROM
    (SELECT Category, ROUND(AVG(Rating), 2) AS Average_rating_Paid
     FROM ps 
     WHERE Type = 'Paid'
     GROUP BY Category) a
FULL OUTER JOIN
    (SELECT Category, ROUND(AVG(Rating), 2) AS Average_rating_Free
     FROM ps 
     WHERE Type = 'Free'
     GROUP BY Category) b
ON a.Category = b.Category;

--5. Suppose you're a database administrator your databases have been hacked and hackers are changing price of certain apps on the database,
--it is taking long for IT team to neutralize the hack, however you as a responsible manager don’t want your data to be changed, do some measure where the changes 
--in price can be recorded as you can’t stop hackers from making changes.



create table pricechangelong
(
app varchar(255),
old_price decimal(10,2),
new_price decimal(10,2),
operation_type varchar(255),
operation_date timestamp
)

select * from pricechangelong


select * into play from ps 

select * from play


update play 
set Price=4
where App='Infinite Painter';





EXEC sp_help 'pricechangelong';

DROP TRIGGER IF EXISTS price_change_long;
GO
CREATE TRIGGER price_change_long  
ON play  
AFTER UPDATE  
AS  
BEGIN  
    INSERT INTO pricechangelong (app, old_price, new_price, operation_type)  
    SELECT   
        i.app,  
        d.Price,  
        i.Price,  
        'update'  
    FROM inserted i  
    JOIN deleted d   
    ON i.App = d.App;  
END;
GO


ALTER TABLE pricechangelong DROP COLUMN operation_date;
ALTER TABLE pricechangelong ADD operation_date DATETIME DEFAULT GETDATE();


update play 
set Price=4
where App='Infinite Painter';

select * from pricechangelong

update play		
set Price=5
where App='Sketch - Draw & Paint'

--6.Your IT team have neutralized the threat; however, hackers have made some changes in the prices, but because of your measure you have noted the changes,
--now you want correct data to be inserted into the database again.


update a
set a.price=b.old_price
from 
play a
join pricechangelong b
on a.App=b.app

select * from play 

--7. As a data person you are assigned the task of investigating the correlation between two numeric factors: app ratings and the quantity of reviews.


--(x-x'), (y-y'),(x-x')^2, (y-y')^2


DECLARE @x FLOAT;
DECLARE @y FLOAT;

SET @x = (SELECT ROUND(AVG(cast(Rating as float)), 2) as Rating_average FROM play);
SET @y = (SELECT ROUND(AVG(cast (Reviews as float)), 2) as Review_average FROM play);


with deviations as (

select Rating,@x as Rating_mean,(Rating-@x) as rat,Reviews,@y as Review_mean, (Reviews-@y) as Rev,power((Rating-@x),2) as rat_square, power((Reviews-@y),2) as Rev_square, (Rating-@x)*(Reviews-@y) as cross_product 
from PS)


select round(SUM(cross_product)/ SQRT(SUM(rat_square) * SUM(Rev_square)),2) as corelation 
from deviations;

--8.Your boss noticed  that some rows in genres columns have multiple genres in them, which was creating issue when developing the  recommender 
--system from the data he/she assigned you the task to clean the genres column and make two genres out of it, rows that have only one genre will have other column as blank.


select  Genres from PS



SELECT 
    -- Extract the first genre
	genres,
    CASE 
        WHEN CHARINDEX(';', Genres) > 0 
        THEN LEFT(Genres, CHARINDEX(';', Genres) - 1) 
        ELSE Genres  
    END AS first_genre,

    -- Extract the second genre (if exists)
    CASE 
        WHEN CHARINDEX(';', Genres) > 0 
        THEN SUBSTRING(Genres, CHARINDEX(';', Genres) + 1, LEN(Genres)) 
        ELSE 'NA'
    END AS second_genre
FROM PS;



