SELECT *
FROM layoffs;

-- 1. remove dupllicates
-- 2. standardize the data
-- 3. Filling Null values
-- 4. remove any columns

-- creating a table like layoffs
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

-- copying everything from layoffs to layoffs_staging
INSERT layoffs_staging
SELECT *
FROM layoffs;


-- creating a duplicate file for safety using copy to clipboard > create statement
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

-- copying data and assigning row number 
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2;

-- temporary sql safe update off
SET SQL_SAFE_UPDATES = 0;

-- delete duplicate rows 
DELETE 
FROM layoffs_staging2 
WHERE row_num > 1 ;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing the data 
-- trimming
UPDATE layoffs_staging2
SET company = trim(company);

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

-- correcting '.' and basic mistakes 
UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE "crypto%";

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

-- trimming "." from the end
UPDATE layoffs_staging2
SET country = trim(trailing'.' From country)
WHERE country LIKE "United States%";

SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;

-- formating the date using str_to_date
SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

-- updating datatype of date from text to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Filling the null values 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

-- Droping the column row-num after data cleaning
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_staging2;
