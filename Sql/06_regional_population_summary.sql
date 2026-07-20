---create a regional summary view---

USE NetherlandsHousingAnalytics;

CREATE OR ALTER VIEW analytics.vw_regional_population_summary AS
SELECT
    g.region_name,
    g.year_value,
    g.total_population,
    g.male_percentage,
    g.female_percentage,
    p.population_change,
    p.population_growth_percentage,
    p.growth_rank
FROM analytics.vw_population_gender_balance AS g
LEFT JOIN analytics.vw_population_growth_rank AS p
    ON g.region_name = p.region_name
   AND g.year_value = p.year_value;


SELECT *
FROM analytics.vw_regional_population_summary
ORDER BY year_value, growth_rank, region_name;