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

