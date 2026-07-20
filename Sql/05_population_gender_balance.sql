USE NetherlandsHousingAnalytics;

CREATE OR ALTER VIEW analytics.vw_population_gender_balance AS
SELECT
    region_name,
    year_value,
    total_population,
    male_population,
    female_population,
    CAST(
        100.0 * male_population / NULLIF(total_population, 0)
        AS DECIMAL(5,2)
    ) AS male_percentage,
    CAST(
        100.0 * female_population / NULLIF(total_population, 0)
        AS DECIMAL(5,2)
    ) AS female_percentage,
    female_population - male_population AS female_minus_male
FROM staging.population_summary;

SELECT *
FROM analytics.vw_population_gender_balance
ORDER BY region_name, year_value;

