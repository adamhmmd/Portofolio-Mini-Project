
-- DATA CLEANING --

SELECT *
FROM layoffs ;


-- Create staging

CREATE TABLE layoffs_staging1
LIKE layoffs;

INSERT layoffs_staging1
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging1;

-- Remove dupe

SELECT *,
ROW_NUMBER() OVER(PARTITION BY
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging1;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging1
)

SELECT * 
FROM duplicate_cte
WHERE row_num > 1 ;

-- Create staging 2 to delete the dupe row (cant use previous table since cte is not updatable)

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging1 ;

SELECT *
FROM layoffs_staging2;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing data

SELECT *
FROM layoffs_staging2;

-- Checking out company row

SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY company;

-- Checking out location row

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

SELECT *
FROM layoffs_staging2
WHERE location LIKE 'Malm%';

UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE location LIKE 'Malm%';

SELECT *
FROM layoffs_staging2
WHERE location LIKE 'D%ss';

-- Checking out Industry row

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Checking out Country row

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

SELECT * 
FROM layoffs_staging2
WHERE country LIKE 'United States%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Changing date format

SELECT `date`
FROM layoffs_staging2 ;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- NULL and BLANK values

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL ;

-- Looking for data we can re populate
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Populate the data into null data available
SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry = ''
AND t2.industry IS NOT NULL ;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL ;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '' ;

-- Looking other data that can be re populate

SELECT *
FROM layoffs_staging2
WHERE stage IS NULL
OR stage = '';

SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.stage IS NULL
AND t2.stage IS NOT NULL ;

SELECT *
FROM layoffs_staging2
WHERE company = 'Advata' ;

-- Since the data is not completed yet, we want to delete the data where total laid off AND percentage laid off is null, and we will be using another staging incase theres new input data to it 

INSERT layoffs_staging3
SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging3 ;

SELECT * 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL ;

DELETE 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL ;

-- DELETE our modified row (row_num)

ALTER TABLE layoffs_staging3
DROP COLUMN row_num ;
