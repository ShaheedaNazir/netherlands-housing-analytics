---Measure query performance for regional population lookups---

USE NetherlandsHousingAnalytics;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    region_name,
    year_value,
    total_population
FROM staging.population_summary
WHERE region_name = 'Assen'
ORDER BY year_value;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;