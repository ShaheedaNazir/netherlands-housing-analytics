-- Project: Netherlands Housing Analytics
-- File: 08_population_summary_index.sql
-- Purpose: Prevent duplicate region-year records and improve lookup performance.
-- Database: Microsoft SQL Server

USE NetherlandsHousingAnalytics;

-- Create a unique index to enforce one record per region and reporting year.
CREATE UNIQUE INDEX ux_population_summary_region_year
ON staging.population_summary (
    region_name,
    year_value
);

-- Confirm that the index exists and is configured as unique.
SELECT
    i.name AS index_name,
    i.is_unique
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('staging.population_summary')
  AND i.name = 'ux_population_summary_region_year';