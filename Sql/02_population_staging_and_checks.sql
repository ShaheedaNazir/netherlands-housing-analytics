USE NetherlandsHousingAnalytics;

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

SELECT COUNT(*) AS total_rows
FROM staging.population_summary;

SELECT TOP 10 *
FROM staging.population_summary
ORDER BY year_value, region_name;

SELECT DISTINCT
    region_name
FROM staging.population_summary
ORDER BY region_name;

SELECT
    region_name,
    COUNT(*) AS number_of_years,
    MIN(year_value) AS first_year,
    MAX(year_value) AS last_year
FROM staging.population_summary
GROUP BY region_name
ORDER BY region_name;

