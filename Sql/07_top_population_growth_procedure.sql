-- Returns the top regions by annual population growth for a selected year.---

USE NetherlandsHousingAnalytics;

CREATE OR ALTER PROCEDURE analytics.usp_top_population_growth
    @year INT,
    @top_n INT = 5
AS
BEGIN
    SET NOCOUNT ON;

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

