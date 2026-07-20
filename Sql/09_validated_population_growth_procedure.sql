---Return validated population growth rankings for a selected year---

USE NetherlandsHousingAnalytics;

CREATE OR ALTER PROCEDURE analytics.usp_top_population_growth
    @year INT,
    @top_n INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    -- Rejects invalid result limits.
    IF @top_n <= 0
    BEGIN
        THROW 50001, 'The @top_n parameter must be greater than zero.', 1;
    END;

    -- Rejects years that do not exist in the growth dataset.
    IF NOT EXISTS (
        SELECT 1
        FROM analytics.vw_population_growth_rank
        WHERE year_value = @year
    )
    BEGIN
        THROW 50002, 'No population growth data exists for the selected year.', 1;
    END;

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

EXEC analytics.usp_top_population_growth
    @year = 2025,
    @top_n = 5;

EXEC analytics.usp_top_population_growth
    @year = 2025,
    @top_n = 1;

