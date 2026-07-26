-- Project: Netherlands Housing Analytics
-- File: 07_top_population_growth_procedure.sql
-- Purpose: Return the highest population-growth regions for a selected year.
-- Database: Microsoft SQL Server

USE NetherlandsHousingAnalytics;

-- Create a reusable stored procedure with year and result-limit parameters.
CREATE OR ALTER PROCEDURE analytics.usp_top_population_growth
    @year INT,
    @top_n INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    -- Return the requested number of regions with the highest annual growth.
    SELECT TOP (@top_n)
        region_name,
        year_value,
        total_population,
        population_change,
        population_growth_percentage,
        growth_rank
    FROM analytics.vw_population_growth_rank
    WHERE year_value = @year
    ORDER BY
        population_growth_percentage DESC,
        region_name;
END;

-- Test the procedure for the five fastest-growing regions in 2025.
EXEC analytics.usp_top_population_growth
    @year = 2025,
    @top_n = 5;