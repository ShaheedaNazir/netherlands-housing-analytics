-- Project: Netherlands Housing Analytics
-- File: 04_population_data_quality.sql
-- Purpose: Validate population records for duplicates, missing values,
--          and inconsistencies between demographic totals.
-- Database: Microsoft SQL Server

USE NetherlandsHousingAnalytics;

-- Identify duplicate records for the same region and reporting year.
SELECT
    region_name,
    year_value,
    COUNT(*) AS duplicate_count
FROM staging.population_summary
GROUP BY
    region_name,
    year_value
HAVING COUNT(*) > 1;

-- Identify records containing missing values in required population fields.
SELECT *
FROM staging.population_summary
WHERE
    year_value IS NULL
    OR region_name IS NULL
    OR total_population IS NULL
    OR male_population IS NULL
    OR female_population IS NULL;

-- Identify records where male and female totals do not equal total population.
SELECT
    region_name,
    year_value,
    total_population,
    male_population,
    female_population,
    male_population + female_population AS calculated_total
FROM staging.population_summary
WHERE total_population <> male_population + female_population;

-- Create a reusable view that combines the main population data-quality checks.
CREATE OR ALTER VIEW quality.vw_population_data_issues AS

SELECT
    'Duplicate region-year' AS issue_type,
    region_name,
    year_value
FROM staging.population_summary
GROUP BY
    region_name,
    year_value
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'Missing value',
    region_name,
    year_value
FROM staging.population_summary
WHERE
    year_value IS NULL
    OR region_name IS NULL
    OR total_population IS NULL
    OR male_population IS NULL
    OR female_population IS NULL

UNION ALL

SELECT
    'Population total mismatch',
    region_name,
    year_value
FROM staging.population_summary
WHERE total_population <> male_population + female_population;

-- Review all detected population data-quality issues.
SELECT *
FROM quality.vw_population_data_issues;