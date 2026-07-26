-- Project: Netherlands Housing Analytics
-- File: 05_population_gender_balance.sql
-- Purpose: Calculate the male and female population distribution for each region and year.
-- Database: Microsoft SQL Server

USE NetherlandsHousingAnalytics;

-- Create a reusable analytical view for regional gender balance.
CREATE OR ALTER VIEW analytics.vw_population_gender_balance AS
SELECT
    region_name,
    year_value,
    total_population,
    male_population,
    female_population,

    -- Calculate the male share of the total population.
    CAST(
        100.0 * male_population / NULLIF(total_population, 0)
        AS DECIMAL(5,2)
    ) AS male_percentage,

    -- Calculate the female share of the total population.
    CAST(
        100.0 * female_population / NULLIF(total_population, 0)
        AS DECIMAL(5,2)
    ) AS female_percentage,

    -- Show the numerical difference between female and male population totals.
    female_population - male_population AS female_minus_male

FROM staging.population_summary;

-- Review the gender-balance results by region and reporting year.
SELECT *
FROM analytics.vw_population_gender_balance
ORDER BY
    region_name,
    year_value;