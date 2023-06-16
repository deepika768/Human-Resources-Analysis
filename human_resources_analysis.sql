use project
drop table human_resources

SELECT * FROM human_resources;
ALTER TABLE human_resources
CHANGE COLUMN ï»¿id emp_id VARCHAR(30) NULL;

SELECT birthdate FROM human_resources;

SET sql_safe_updates =0;

ALTER TABLE human_resources
MODIFY COLUMN birthdate DATE;

UPDATE human_resources
SET birthdate = CASE
    WHEN birthdate LIKE'%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN birthdate LIKE'%-%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    ELSE NULL
END;

SELECT * FROM human_resources;

SELECT birthdate FROM human_resources;

UPDATE human_resources
SET hire_date= CASE
    WHEN hire_date LIKE'%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN hire_date LIKE'%-%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    ELSE NULL
END;
ALTER TABLE human_resources
MODIFY COLUMN hire_date DATE;

UPDATE human_resources
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from human_resources;

SET sql_mode = 'ALLOW_INVALID_DATES';


ALTER TABLE human_resources
MODIFY COLUMN termdate DATE;

SELECT termdate from human_resources;

DESCRIBE human_resources

ALTER TABLE human_resources 
ADD COLUMN age INT

SELECT * FROM human_resources

UPDATE human_resources
SET age=timestampdiff(YEAR,birthdate,curdate());

SELECT
   MIN(age) AS youngest,
   MAX(age) AS oldest
FROM human_resources;

select count(*) FROM human_resources WHERE age<18;
#1.What is the gender breakdown of employees in the company?
SELECT gender , count(*) AS count
FROM human_resources
WHERE age>=18 AND termdate='0000-00-00'
GROUP BY gender;

#2-what is the race/ethnicity breakdown of employees in the company?
SELECT race,COUNT(*) AS count
FROM human_resources
WHERE age>=18  AND termdate='0000-00-00'
GROUP BY race
ORDER BY count(*) DESC;

#3-WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY?
SELECT
    min(age) AS youngest,
    max(age) AS oldest
FROM human_resources
WHERE age>=18 AND termdate='0000-00-00';

SELECT
  CASE
     WHEN age>=18 AND age<=24 THEN'18-24'
     WHEN age>=25 AND age<=34 THEN'25-34'
     WHEN age>=35 AND age<=44 THEN'35-44'
     WHEN age>=45 AND age<=54 THEN'45-54'
     WHEN age>=55 AND age<=64 THEN'55-64'
     ELSE '65+'
END AS age_group,
COUNT(*) as count
FROM human_resources
WHERE age>=18 AND termdate='0000-00-00'
GROUP BY age_group
ORDER BY age_group;

SELECT
  CASE
     WHEN age>=18 AND age<=24 THEN'18-24'
     WHEN age>=25 AND age<=34 THEN'25-34'
     WHEN age>=35 AND age<=44 THEN'35-44'
     WHEN age>=45 AND age<=54 THEN'45-54'
     WHEN age>=55 AND age<=64 THEN'55-64'
     ELSE '65+'
END AS age_group,gender,
COUNT(*) as count
FROM human_resources
WHERE age>=18 AND termdate='0000-00-00'
GROUP BY age_group,gender
ORDER BY age_group,gender;

#4.how many employee work at headquarters versus remote location?
SELECT location,count(*) AS count
FROM human_resources
WHERE age>=18 AND termdate='0000-00-00'
GROUP BY location;

#5-what is the average of employment for employees who have been terminated?
SELECT 
round(avg(datediff(termdate,hire_date))/365,0) as ang_length_employement
FROM human_resources
WHERE termdate<=curdate() AND termdate<>'0000-00-00' AND age>=18;

#6-How does the gender distribution vary across department and job titles?
SELECT department,gender,COUNT(*) AS count
FROM human_resources
WHERE age>=18 AND termdate='0000-00-00'
GROUP BY department,gender
ORDER BY department; 

#7-what is the distribution of job titles across the company?
SELECT jobtitle,count(*) AS count
FROM human_resources
WHERE age>=18 AND termdate='0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

#8-which deartment has the highest turnover rate?
SELECT department ,
total_count,
terminated_count,
terminated_count/total_count AS termination_rate
FROM(
 SELECT department,
 count(*) AS total_count,
 SUM(CASE WHEN termdate<>'0000-00-00' AND termdate<=curdate() THEN 1 ELSE 0 END) AS terminated_count
 FROM human_resources
 WHERE age>=18
 GROUP BY department
 )AS subquery
 ORDER BY termination_rate desc;
 #9-what is the distribution of employees across locations by city and state?
 SELECT location_state,COUNT(*) as count
 FROM human_resources
 GROUP BY location_state
 ORDER BY count DESC;
 
 #10-How has the company's employee count changed over time based on hire and term date ?
 SELECT 
   year,
   hires,
   terminations,
   hires - terminations AS net_change,
   round((hires-terminations)/hires*100,2)
   AS net_change_percent
   FROM (
      SELECT YEAR(hire_date) AS year,
             count(*) AS hires,
             SUM(CASE WHEN termdate<>'0000-00-00' AND termdate<=curdate() THEN 1 ELSE 0 END)AS terminations
             FROM human_resources
             WHERE AGE>=18
             GROUP BY YEAR(hire_date)
             ) AS subquery
		ORDER BY year ASC ;
        
#11-what is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM human_resources
WHERE termdate<=curdate() AND termdate<>'000-00-00' AND age>=18
GROUP BY department;