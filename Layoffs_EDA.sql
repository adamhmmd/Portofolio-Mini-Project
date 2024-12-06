-- `date` (my back tick on my keyboard is error, so i put it here then i can copy paste it when it needed)

-- Exploratory Data Analysis

SELECT * 
FROM layoffs_staging3 
;

SELECT MAX(`date`), MIN(`date`)
FROM layoffs_staging3
;

SELECT *
FROM layoffs_staging3
-- ORDER BY 6 DESC
;

-- Looking for the company with highest amount of laidoff

SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC 
;

-- Check if there any company who laidoff all their employees

SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
;

-- Proportion of layoffs per company based on their company stage

SELECT stage, ROUND(avg(percentage_laid_off),2)
FROM layoffs_staging3
GROUP BY stage
ORDER BY 1 ASC
;

-- Looking for total laidoff per year

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;

-- Looking for total laidoff per month

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging3
GROUP BY `MONTH`
ORDER BY 1 ASC
;

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as `MONTH`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging3
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_laid_off
, SUM(total_laid_off) OVER (ORDER BY `MONTH` ASC) as rolling_total_layoffs
FROM DATE_CTE
WHERE `MONTH` LIKE '2022%'
-- (incase we need spesific year)
ORDER BY 1 ASC;

-- Checking total layoff per company each year

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
ORDER BY 1 ASC
;

WITH Company_CTE (Company, Years, Total_Laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
) , Company_Ranking_CTE AS 
(
SELECT * ,
DENSE_RANK() OVER (PARTITION BY Years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_CTE
WHERE Years IS NOT NULL
)
Select *
FROM Company_Ranking_CTE
WHERE Years = '2021' 
-- LIMIT 5
;




