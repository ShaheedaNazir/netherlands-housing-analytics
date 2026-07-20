USE NetherlandsHousingAnalytics;
---Calculate population growth with LAG()--

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

---Calculate population growth percentage---

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

---Rank regions by growth---

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

---Save this as a reusable view---

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


SELECT *
FROM analytics.vw_population_growth_rank
ORDER BY year_value, growth_rank;

---Confirm the view exists---

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'analytics'
  AND TABLE_NAME = 'vw_population_growth_rank';


---Add a data quality check--- 

SELECT
    region_name,
    year_value,
    COUNT(*) AS duplicate_count
FROM staging.population_summary
GROUP BY
    region_name,
    year_value
HAVING COUNT(*) > 1;

---checking for missing values---

SELECT *
FROM staging.population_summary
WHERE
    year_value IS NULL
    OR region_name IS NULL
    OR total_population IS NULL
    OR male_population IS NULL
    OR female_population IS NULL;

---Checking whether men + women equals total population---

SELECT
    region_name,
    year_value,
    total_population,
    male_population,
    female_population,
    male_population + female_population AS calculated_total
FROM staging.population_summary
WHERE total_population <> male_population + female_population;

---Save these checks as a reusable view---

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

SELECT *
FROM quality.vw_population_data_issues;


