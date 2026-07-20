---Enforce unique region-year records and improve lookup performance---

USE NetherlandsHousingAnalytics;

-- Prevents duplicate records for the same region and reporting year.
CREATE UNIQUE INDEX ux_population_summary_region_year
ON staging.population_summary (
    region_name,
    year_value
);

SELECT
    i.name AS index_name,
    i.is_unique
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('staging.population_summary')
  AND i.name = 'ux_population_summary_region_year';