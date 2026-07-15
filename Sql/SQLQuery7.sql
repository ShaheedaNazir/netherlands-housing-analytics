USE NetherlandsHousingAnalytics;

CREATE TABLE staging.population_summary (
    year_value INT,
    region_name NVARCHAR(100),
    total_population INT,
    male_population INT,
    female_population INT
);