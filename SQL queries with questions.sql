1.	--You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work fully remotely,
--for the title 'managers’ Paying salaries Exceeding $90,000 USD

SELECT distinct company_location 
FROM salaries 
where remote_ratio = 100 and job_title  like '%manager%' and (salary_in_usd > 90000)


2.	---AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. you're tasked WITH Identifying top 5
--Country Having greatest count of large (company size) number of companies.

select distinct experience_level  from dbo.salaries 


select top 5 company_location,count(company_location) as Total_employees_per_country
from salaries 
where company_size='L' and experience_level='EN'
group by company_location 
order by Total_employees_per_country desc


3.--Imagine you are a talent Acquisition specialist Working for an International recruitment agency. Your Task is to identify the top
-- job titles that command the highest average salary Among part-time Positions IN the year 2023. However, you are Only Interested IN Countries
--WHERE there are more than 50 employees, Ensuring a robust sample size for your analysis.

select * from salaries 


select job_title, AVG(salary_in_usd) as Average_salary_amount
from [dbo].[salaries] 
where work_year=2023 and company_size not like 'S' and employment_type = 'PT'
group by job_title 
order by Average_salary_amount desc


--4.Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. Who enjoy fully remote
--roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.
declare @total Float
declare @count Float
declare @percentage Float

set @total= ( select count(*) from salaries where salary_in_usd>100000);
set @count =(select count(*) from salaries where salary_in_usd>100000 and remote_ratio=100);

if @total=0
	set @percentage=0;
else
  set @percentage=(@count/@total)*100;

select (@percentage) as percentage ;

--5.Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average salaries exceed
--the average salary for that job title IN market for entry level, helping your agency guide candidates towards lucrative opportunities.
with Jobtitle_average_salary as (
	select job_title, avg(salary_in_usd) as avg_salary 
	from salaries 
	where experience_level='EN'
	group by job_title
	),



 main_table as (
select company_location,job_title,AVG(salary_in_usd) as compare_salary
from salaries 
where experience_level='EN'
group by company_location,job_title
)



select m.company_location,m.job_title,m.compare_salary,J.avg_salary
from main_table m 
join Jobtitle_average_salary J
on m.job_title = J.job_title
where m.compare_salary>J.avg_salary
order by m.compare_salary desc




--6. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which. 
--Country pays the maximum average salary. This helps you to place your candidates IN those countries.



with JobTitleCountryAverage as (
	SELECT job_title,company_location as country ,avg(salary_in_usd) as average_salary
	from salaries 
	group by job_title,company_location
	),
MaxCountryPerJob as (
  select job_title,max(average_salary) as max_avg_salary
  from JobTitleCountryAverage
  group by job_title )


select JTCA.job_title,country,MCPJ.max_avg_salary
from JobTitleCountryAverage  JTCA
join MaxCountryPerJob MCPJ
on JTCA.average_salary=MCPJ.max_avg_salary and (JTCA.job_title=MCPJ.job_title)


--rank method

WITH Rankedsalaries as (
	select job_title,company_location as country,avg(salary_in_usd) as average_salary,
	RANK() OVER(partition by job_title order by   avg(salary_in_usd) desc) as Salary_rank 
	from salaries 
	group by job_title,company_location)
select job_title,country,average_salary,Salary_rank
from Rankedsalaries
where Salary_rank=1


--7.AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
--Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years
--Only(present year and past two years) providing Insights into Locations experiencing Sustained salary growth.


WITH CountryJobAverageByYear24 as (
	select  job_title,company_location as company,AVG(salary_in_usd) as avg_salary24
	from salaries
	where work_year=2024
	group by job_title,company_location),

	CountryJobAverageByYear23 as (
	select  job_title,company_location as company,AVG(salary_in_usd) as avg_salary23
	from salaries
	where work_year=2023
	group by job_title,company_location),

	CountryJobAverageByYear22 as (
	select  job_title,company_location as company,AVG(salary_in_usd) as avg_salary22
	from salaries
	where work_year=2022
	group by job_title,company_location)
select four.job_title,four.company,four.avg_salary24
from CountryJobAverageByYear24 as four,CountryJobAverageByYear23 Three,CountryJobAverageByYear22 two
where (four.job_title=Three.job_title and four.job_title=two.job_title) and (four.company=Three.company and four.company=two.company) and (four.avg_salary24>Three.avg_salary23 and Three.avg_salary23>two.avg_salary22)

--8.Picture yourself AS a workforce strategist employed by a global HR tech startup. Your Mission is to Determine the percentage of fully remote work for 
--each experience level IN 2021 and compare it WITH the corresponding figures for 2024, Highlighting any significant Increases or decreases IN remote work Adoption over the years.

--2021
(select a.experience_level,round(cast(b.total_employees_2021_remote as float)/cast(a.total_employees_2021 as float),4) *100 as remote_2021
from
(select experience_level,count(*) as total_employees_2021
from salaries
where work_year=2021
group by experience_level) as a
join
(select experience_level,count(*) as total_employees_2021_remote
from salaries
where work_year=2021 and remote_ratio=100
group by experience_level) as b
on a.experience_level=b.experience_level)

--2024
(select a.experience_level,round(cast(b.total_employees_2024_remote as float)/cast(a.total_employees_2024 as float),4) *100 as remote_2024
from
(select experience_level,count(*) as total_employees_2024
from salaries
where work_year=2024
group by experience_level) as a
join
(select experience_level,count(*) as total_employees_2024_remote
from salaries
where work_year=2024 and remote_ratio=100
group by experience_level) as b
on a.experience_level=b.experience_level)


--9.AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. Your objective is to calculate the average salary 
--increase percentage for each experience level and job title between the years 2023 and 2024, helping the company stay competitive IN the talent market.


select a.experience_level,a.job_title,a.avg_salary_2023,b.avg_salary_2024, round( (cast(b.avg_salary_2024 as float)- CAST(a.avg_salary_2023 as float))/(CAST(a.avg_salary_2023 as float)) *100,2) as increased_percentage
from
(select experience_level,job_title,AVG(salary_in_usd) as avg_salary_2023
from salaries
where work_year=2023
group by experience_level , job_title)  a
join 
( select experience_level,job_title,AVG(salary_in_usd) as avg_salary_2024
from salaries
where work_year=2024
group by experience_level , job_title)  b 
on (a.experience_level =b.experience_level) and (a.job_title= b.job_title)
order by increased_percentage desc

---additional questions

--10.As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data. Your Task is to know how many people were employed IN 
--different types of companies AS per their size IN 2021.

select company_size,count(*) as no_of_employees
from salaries
where work_year=2021
group by company_size

--11. Imagine you are a talent Acquisition specialist Working for an International recruitment agency. Your Task is to identify the top 3 job titles that command the
--highest average salary Among part-time Positions IN the year 2023. However, you are Only Interested IN Countries WHERE there are more than 50 employees, Ensuring a robust
--sample size for your analysis.


select job_title,AVG(salary_in_usd) as avg_salary
from salaries
where work_year=2023 and employment_type='PT'
group by job_title




--12.	As a database analyst you have been assigned the task to Select Countries where average mid-level salary is higher than overall mid-level salary for the year 2023.

select * from salaries 

select company_location as country, avg(salary_in_usd) as avg_salary 
from salaries 
where (work_year=2023 and experience_level='MI')
group by company_location 
Having (avg(salary_in_usd) >(select AVG(salary_in_usd) as overall_avg_salary from salaries  where work_year=2023 and experience_level='MI'))

--13.As a database analyst you have been assigned the task to Identify the company locations with the highest and lowest average salary for senior-level (SE) employees in 2023.

select  top 1 company_location,AVG(salary_in_usd) as avg_salary 
from salaries 
where experience_level='SE' and work_year=2023
group by company_location
order by avg_salary desc 


select  top 1 company_location,AVG(salary_in_usd) as avg_salary 
from salaries 
where experience_level='SE' and work_year=2023
group by company_location
order by avg_salary asc 

--14.You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles. By Calculating the percentage Increase
--IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN different job roles.



select a.job_title, avg_salary_23,avg_salary_24,
case 
when CAST(avg_salary_23 as float) =0  THEN 0
else round((CAST(avg_salary_24 as float)- CAST(avg_salary_23 as float))/(cast(avg_salary_23 as float) ) * 100 ,2)  
end as [change_percentage]
from 
(select  job_title, AVG(salary_in_usd) avg_salary_23
from salaries
where work_year=2023
group by job_title) a 
join 
(select  job_title, AVG(salary_in_usd) avg_salary_24
from salaries
where work_year=2024
group by job_title) b
on a.job_title=b.job_title
order by change_percentage desc

--16.You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles. Your task is to list the top three Countries with 
--the highest salary growth rate FROM 2020 to 2023, Considering Only companies with more than 50 employees, helping multinational 



select top 3 a.company_location,a.avg_sal_2020,b.avg_sal_2023, round((CAST(b.avg_sal_2023 as float)- CAST(a.avg_sal_2020 as float))/(cast(a.avg_sal_2020 as float) ) * 100 ,2) as change_percentage
from
(select company_location,avg(salary_in_usd) avg_sal_2020
from salaries 
where work_year=2020 and (company_size='L' or  company_size='M')
group by company_location) a

join
(select company_location,avg(salary_in_usd) avg_sal_2023
from salaries 
where work_year=2023 and (company_size='L' or  company_size='M')
group by company_location) b 
on a.company_location= b.company_location
order by change_percentage desc 

--17 .picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to create a hybrid model for employees they 
--decided that employees earning salaries exceeding $90000 USD, will be given work from home. You now need to update the remote work ratio for eligible employees, ensuring
--efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.
select * from salaries 




BEGIN TRY
    -- Update remote_ratio for employees in US and AU earning more than $90,000
    UPDATE salaries
    SET remote_ratio = 100  -- Assuming 100 indicates full remote eligibility
    WHERE 
        company_location IN ('US', 'AU') 
        AND salary_in_usd > 90000;  

    PRINT 'Remote work eligibility updated successfully.';
END TRY
BEGIN CATCH
    -- Error handling
    PRINT 'Error occurred while updating remote work eligibility.';
    PRINT ERROR_MESSAGE();  
END CATCH;

/*18. In year 2024, due to increase demand in data industry , there was  increase in salaries of data field employees.
                   Entry Level-35%  of the salary.
                   Mid junior – 30% of the salary.
                   Immediate senior level- 22% of the salary.
                   Expert level- 20% of the salary.
                   Director – 15% of the salary.
you have to update the salaries accordingly and update it back in the original database. */

UPDATE camp
SET salary_in_usd = 
    CASE 
        WHEN experience_level = 'EN' THEN salary_in_usd * 1.35  
        WHEN experience_level = 'MI' THEN salary_in_usd * 1.30  
        WHEN experience_level = 'SE' THEN salary_in_usd * 1.22  
        WHEN experience_level = 'EX' THEN salary_in_usd * 1.20  
        WHEN experience_level = 'DX' THEN salary_in_usd * 1.15  
        ELSE salary_in_usd  -- Keep salary unchanged for other experience levels
    END
WHERE work_year = 2024;  





/*19. You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.*/
WITH avg_salary_per_year AS 
(
    -- Calculate the average salary for each job title in each year
    SELECT work_year, job_title, AVG(salary_in_usd) AS avg_salary 
    FROM salaries
    GROUP BY work_year, job_title
)

SELECT job_title, work_year, avg_salary FROM 
    (
       -- Rank the average salaries for each job title in each year
       SELECT job_title, work_year, avg_salary, RANK() OVER (PARTITION BY job_title ORDER BY avg_salary DESC) AS rank_by_salary
	   FROM avg_salary_per_year
    ) AS ranked_salary
WHERE 
    rank_by_salary = 1; 
    
    
    
    
    
/*20. You have been hired by a market research agency where you been assigned the task to show the percentage of different employment type (full time, part time) in 
Different job roles, in the format where each row will be job title, each column will be type of employment type and  cell value  for that row and column will show 
the % value*/
SELECT 
    job_title,
    ROUND((SUM(CASE WHEN employment_type = 'PT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS PT_percentage, 
    ROUND((SUM(CASE WHEN employment_type = 'FT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS FT_percentage, 
    ROUND((SUM(CASE WHEN employment_type = 'CT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS CT_percentage,
    ROUND((SUM(CASE WHEN employment_type = 'FL' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS FL_percentage 
FROM 
    salaries
GROUP BY 
    job_title;
   
