-- Project: Netherlands Housing Analytics
-- File: 02_population_staging_and_checks.sql
-- Purpose: Load selected CBS population fields into the staging table
--          and perform basic validation and summary checks.
-- Database: Microsoft SQL Server

USE NetherlandsHousingAnalytics;

-- Load population data from the raw CBS import into the cleaned staging table.
INSERT INTO staging.population_summary (
    year_value,
    region_name,
    total_population,
    male_population,
    female_population
)
SELECT
    column1,
    column2,
    column3,
    column4,
    column5
FROM raw.cbs_regionale_kerncijfers;

-- Confirm the total number of records loaded into the staging table.
SELECT
    COUNT(*) AS total_rows
FROM staging.population_summary;

-- Preview the first ten population records in chronological and regional order.
SELECT TOP 10 *
FROM staging.population_summary
ORDER BY
    year_value,
    region_name;

-- Display each unique region included in the selected CBS dataset.
SELECT DISTINCT
    region_name
FROM staging.population_summary
ORDER BY
    region_name;

-- Summarize the number of reporting years and the available date range per region.
SELECT
    region_name,
    COUNT(*) AS number_of_years,
    MIN(year_value) AS first_year,
    MAX(year_value) AS last_year
FROM staging.population_summary
GROUP BY
    region_name
ORDER BY
    region_name;