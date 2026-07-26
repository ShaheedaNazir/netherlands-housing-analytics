-- Project: Netherlands Housing Analytics
-- File: 09_validated_population_growth_procedure.sql
-- Purpose: Return validated population-growth rankings for a selected year.
-- Database: Microsoft SQL Server

USE NetherlandsHousingAnalytics;

-- Update the stored procedure with input validation for year and result limit.
CREATE OR ALTER PROCEDURE analytics.usp_top_population_growth
    @year INT,
    @top_n INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    -- Reject result limits that are zero or negative.
    IF @top_n <= 0
    BEGIN
        THROW 50001, 'The @top_n parameter must be greater than zero.', 1;
    END;

    -- Reject years that are not available in the population-growth dataset.
    IF NOT EXISTS (
        SELECT 1
        FROM analytics.vw_population_growth_rank
        WHERE year_value = @year
    )
    BEGIN
        THROW 50002, 'No population growth data exists for the selected year.', 1;
    END;

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

-- Test the procedure with the default top-five style result.
EXEC analytics.usp_top_population_growth
    @year = 2025,
    @top_n = 5;

-- Test the procedure with a single-result limit.
EXEC analytics.usp_top_population_growth
    @year = 2025,
    @top_n = 1;