-- Project: Netherlands Housing Analytics
-- File: 10_population_performance_test.sql
-- Purpose: Measure query resource usage and execution time for regional population lookups.
-- Database: Microsoft SQL Server

USE NetherlandsHousingAnalytics;

-- Enable SQL Server statistics for logical reads and execution time.
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Test the performance of a region-based population lookup.
SELECT
    region_name,
    year_value,
    total_population
FROM staging.population_summary
WHERE region_name = 'Assen'
ORDER BY year_value;

-- Disable performance statistics after the test query completes.
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;