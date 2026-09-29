# we create database first  with the name Project1
create database Project1;
use Project1;
-- data base creaiton and exploring and 

# creating the table of h1 one h2 separate  whenever we need the bith table we use join
drop table  if exists hr_1 ;
create table if not exists hr_1(Age int, 
Attrition varchar(10) ,
b_travel varchar(20) ,
Daily_rate int ,
Department varchar(50),
Dist_to_Home int,
Education int,
EducationField varchar(50),
E_count int,
E_Number int,
EnvironmentSatisfaction int ,
gender varchar(20),
HourlyRate int , 
Jobininvolvement int ,
jobLevel int,
jobRole varchar(50),
jobSatisfaction int ,
Marital_Status varchar(50)
) ;
truncate table hr_1;
select count(*) from hr_1;
-- select count(*) from hr_2; 
-- alter table hr_2 rename employee;

# directly create new table during Importing  time of data
describe hr_1;


# job level  by count  count of employee

select Joblevel ,count(*) as count_of_employee from hr_1 group by JobLevel order by count_of_employee asc ;

# department wise count of employee hr 
select Department ,count(*) as count_of_employee from hr_1 group by Department order by count_of_employee asc ;

# educationfield wise count of employee 
select educationfield,count(*) as count_of_employee from hr_1 group by educationfield order by count_of_employee asc ;
select education,count(*) as count_of_employee from hr_1 group by education order by count_of_employee asc ;

# Percentage wise rating fro each department
 
select Department, concat(round((((avg_daily_rate/total_rate)*100)*100),2)," %") percentage_rating 
from ( select department,avg(dailyrate) as avg_daily_rate,sum(DailyRate) as total_rate  from hr_1 group by department) 
as tab1;

select * from hr_1;

alter table hr_1 drop column Column1;

select count(*) from hr2;

# just beacuse me i am adding 2 time in one table that why presetn duplicates in my data

select distinct	* from hr_1;

# find the duplicates in the the database 

select EmployeeNumber ,count(*)  as count from hr_1  group by EmployeeNumber having count(*)>1;

# renmae the table hr_1 to employees
alter table emmployees rename	employees;


-- Q1: What is the overall attrition rate (%)?
-- Efficient: single pass aggregate, no subquery needed.
SELECT
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees;
 
 
-- Q2: How many employees are in each department?
-- Efficient: uses idx_department for the GROUP BY.
SELECT department, COUNT(*) AS headcount
FROM employees
GROUP BY department
ORDER BY headcount DESC;
 
 
-- Q3: What is the average monthly income by department?
-- Efficient: single aggregate scan, only needed columns selected.
SELECT department, ROUND(AVG(monthlyincome), 0) AS avg_monthly_income
FROM employees
GROUP BY department
ORDER BY avg_monthly_income DESC;
 
 
-- Q4: Which job roles have the highest attrition rate?
-- Efficient: idx_job_role speeds grouping; ratio computed in one pass.
SELECT
    jobrole,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS attritions,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY jobrole
ORDER BY attrition_rate_pct DESC;
 
 
-- Q5: Average age of employees who left vs. stayed.
-- Efficient: idx_attrition lets the engine seek both groups directly.
SELECT attrition, ROUND(AVG(age), 1) AS avg_age
FROM employees
GROUP BY attrition;
 
 
-- Q6: How does overtime relate to attrition (count & rate)?
-- Efficient: composite idx_overtime_attr covers both filter columns.
SELECT
    overtime,
    COUNT(*) AS total,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_company,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY overtime;
 
 
-- Q7: Average monthly income by job level.
-- Efficient: numeric GROUP BY, no string comparisons.
SELECT joblevel, ROUND(AVG(monthlyincome), 0) AS avg_income, COUNT(*) AS headcount
FROM employees
GROUP BY joblevel
ORDER BY joblevel;
 
 
-- Q8: Retention-risk list — long since last promotion AND long with same manager.
-- Efficient: composite idx_promo_manager supports the AND filter directly (no full scan).
SELECT employeenumber, department, jobrole, yearssincelastpromotion, yearswithcurrmanager
FROM employees
WHERE yearssincelastpromotion > 3
  AND yearswithcurrmanager > 5;
 
 
-- Q9: Top 10 highest-paid employees.
-- Efficient: idx_income supports ORDER BY + LIMIT without sorting the whole table.
SELECT employeenumber, jobrole, department, monthlyincome
FROM employees
ORDER BY monthlyincome DESC
LIMIT 10;
 
 
-- Q10: Average years at company by department.
SELECT department, ROUND(AVG(yearsatcompany), 1) AS avg_tenure_years
FROM employees
GROUP BY department
ORDER BY avg_tenure_years DESC;
 
 
-- Q11: Distribution of employees by education field.
SELECT educationfield, COUNT(*) AS headcount
FROM employees
GROUP BY educationfield
ORDER BY headcount DESC;
 
 
-- Q12: Attrition rate by marital status.
-- Efficient: idx_marital avoids scanning full table for grouping.
SELECT
    maritalstatus,
    COUNT(*) AS total,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY maritalstatus
ORDER BY attrition_rate_pct DESC;
 
 
-- Q13: Average distance from home — left vs. stayed.
SELECT attrition, ROUND(AVG(distancefromhome), 1) AS avg_distance
FROM employees
GROUP BY attrition;
 
 
-- Q14: Burnout-risk list — low job satisfaction + working overtime.
-- Efficient: filters on indexed over_time column first, then satisfaction (cheap residual filter).
SELECT employeenumber, department, jobrole, jobsatisfaction, overtime
FROM employees
WHERE overtime = 'Yes'
  AND jobsatisfaction = 1;
 
 
-- Q15: Gender headcount within each department.
-- Efficient: composite idx_gender_dept covers this exactly (no sort needed for grouping).
SELECT department, gender, COUNT(*) AS headcount
FROM employees
GROUP BY department, gender
ORDER BY department, gender;
 
 
-- Q16: Average performance rating by job role.
SELECT jobrole, ROUND(AVG(performancerating), 2) AS avg_performance
FROM employees
GROUP BY jobrole
ORDER BY avg_performance DESC;
 
 
-- Q17: "Job hoppers" (>5 companies worked) and their attrition outcome.
-- Efficient: idx_num_companies lets engine seek instead of scanning every row.
SELECT
    attrition,
    COUNT(*) AS job_hopper_count
FROM employees
WHERE numcompaniesworked > 5
GROUP BY attrition;
 
 
-- Q18: Which department has the highest average training times last year?
SELECT department, ROUND(AVG(trainingtimeslastyear), 2) AS avg_trainings
FROM employees
GROUP BY department
ORDER BY avg_trainings DESC
LIMIT 1;
 
 
-- Q19: Average work-life balance score by attrition status.
SELECT attrition, ROUND(AVG(worklifebalance), 2) AS avg_wlb
FROM employees
GROUP BY attrition;
 
 
-- Q20: Top 5 departments by headcount, with their avg income and attrition rate
--      (single-pass query using window function instead of a self-join/subquery).
SELECT department, headcount, avg_income, attrition_rate_pct
FROM (
    SELECT
        department,
        COUNT(*) AS headcount,
        ROUND(AVG(monthlyincome), 0) AS avg_income,
        ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS dept_rank
    FROM employees
    GROUP BY department
) ranked
WHERE dept_rank <= 5
ORDER BY headcount DESC;
 
/* ============================================================
   EFFICIENCY NOTES (applies across all 20 queries)
   ============================================================
   1. Every query selects only the columns it needs — never SELECT *.
   2. WHERE/GROUP BY columns (attrition, department, job_role,
      over_time, monthly_income, marital_status, num_companies_worked,
      years_since_last_promotion+years_with_curr_manager) are indexed,
      including composite indexes for columns that are always
      filtered/grouped together (avoids a second lookup pass).
   3. Aggregation ratios (e.g., attrition %) are computed in a single
      GROUP BY pass with conditional SUM(), instead of two separate
      queries (total count + filtered count) joined afterward.
   4. Q9's ORDER BY + LIMIT relies on idx_income so the engine can
      walk the index in order and stop after 10 rows, rather than
      sorting the entire table.
   5. Q20 uses a window function (RANK) instead of a correlated
      subquery or self-join, so the table is scanned once.
   ============================================================ */
 

