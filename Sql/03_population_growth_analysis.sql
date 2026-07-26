-- Project: Netherlands Housing Analytics
-- File: 03_population_growth_analysis.sql
-- Purpose: Analyze annual population growth, rank regions by growth,
--          and create reusable analytical and data-quality views.
-- Database: Microsoft SQL Server

USE NetherlandsHousingAnalytics;

-- Compare each region's population with the previous reporting year.
SELECT
    region_name,
    year_value,
    total_population,
    LAG(total_population) OVER (
        PARTITION BY region_name
        ORDER BY year_value
    ) AS previous_year_population,
    total_population
        - LAG(total_population) OVER (
            PARTITION BY region_name
            ORDER BY year_value
        ) AS population_change
FROM staging.population_summary
ORDER BY
    region_name,
    year_value;

-- Calculate annual population change as both an absolute value and percentage.
SELECT
    region_name,
    year_value,
    total_population,
    LAG(total_population) OVER (
        PARTITION BY region_name
        ORDER BY year_value
    ) AS previous_year_population,

    total_population
        - LAG(total_population) OVER (
            PARTITION BY region_name
            ORDER BY year_value
        ) AS population_change,

    CAST(
        100.0 * (
            total_population
            - LAG(total_population) OVER (
                PARTITION BY region_name
                ORDER BY year_value
            )
        )
        / NULLIF(
            LAG(total_population) OVER (
                PARTITION BY region_name
                ORDER BY year_value
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS population_growth_percentage

FROM staging.population_summary
ORDER BY
    region_name,
    year_value;

-- Rank regions by annual population growth percentage within each year.
WITH population_growth AS (
    SELECT
        region_name,
        year_value,
        total_population,
        LAG(total_population) OVER (
            PARTITION BY region_name
            ORDER BY year_value
        ) AS previous_year_population
    FROM staging.population_summary
)
SELECT
    region_name,
    year_value,
    total_population,
    previous_year_population,
    total_population - previous_year_population AS population_change,
    CAST(
        100.0 * (total_population - previous_year_population)
        / NULLIF(previous_year_population, 0)
        AS DECIMAL(10,2)
    ) AS population_growth_percentage,
    RANK() OVER (
        PARTITION BY year_value
        ORDER BY
            100.0 * (total_population - previous_year_population)
            / NULLIF(previous_year_population, 0) DESC
    ) AS growth_rank
FROM population_growth
WHERE previous_year_population IS NOT NULL
ORDER BY
    year_value,
    growth_rank;

-- Create a reusable analytical view for annual population growth rankings.
CREATE OR ALTER VIEW analytics.vw_population_growth_rank AS
WITH population_growth AS (
    SELECT
        region_name,
        year_value,
        total_population,
        LAG(total_population) OVER (
            PARTITION BY region_name
            ORDER BY year_value
        ) AS previous_year_population
    FROM staging.population_summary
)
SELECT
    region_name,
    year_value,
    total_population,
    previous_year_population,
    total_population - previous_year_population AS population_change,
    CAST(
        100.0 * (total_population - previous_year_population)
        / NULLIF(previous_year_population, 0)
        AS DECIMAL(10,2)
    ) AS population_growth_percentage,
    RANK() OVER (
        PARTITION BY year_value
        ORDER BY
            100.0 * (total_population - previous_year_population)
            / NULLIF(previous_year_population, 0) DESC
    ) AS growth_rank
FROM population_growth
WHERE previous_year_population IS NOT NULL;

-- Review the population growth ranking view.
SELECT *
FROM analytics.vw_population_growth_rank
ORDER BY
    year_value,
    growth_rank;

-- Confirm that the analytical view exists in the analytics schema.
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'analytics'
  AND TABLE_NAME = 'vw_population_growth_rank';

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

-- Identify records containing missing population values.
SELECT *
FROM staging.population_summary
WHERE
    year_value IS NULL
    OR region_name IS NULL
    OR total_population IS NULL
    OR male_population IS NULL
    OR female_population IS NULL;

-- Identify records where male and female totals do not match total population.
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