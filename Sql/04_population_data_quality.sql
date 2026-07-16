---Add a data quality check--- 

SELECT
    region_name,
    year_value,
    COUNT(*) AS duplicate_count
FROM staging.population_summary
GROUP BY
    region_name,
    year_value
HAVING COUNT(*) > 1;

---checking for missing values---

SELECT *
FROM staging.population_summary
WHERE
    year_value IS NULL
    OR region_name IS NULL
    OR total_population IS NULL
    OR male_population IS NULL
    OR female_population IS NULL;

---Checking whether men + women equals total population---

SELECT
    region_name,
    year_value,
    total_population,
    male_population,
    female_population,
    male_population + female_population AS calculated_total
FROM staging.population_summary
WHERE total_population <> male_population + female_population;

---Save these checks as a reusable view---

CREATE OR ALTER VIEW quality.vw_population_data_issues AS

SELECT
    'Duplicate region-year' AS issue_type,
    region_name,
    year_value
FROM staging.population_summary
GROUP BY
    region_name,
    year_value
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'Missing value',
    region_name,
    year_value
FROM staging.population_summary
WHERE
    year_value IS NULL
    OR region_name IS NULL
    OR total_population IS NULL
    OR male_population IS NULL
    OR female_population IS NULL

UNION ALL

SELECT
    'Population total mismatch',
    region_name,
    year_value
FROM staging.population_summary
WHERE total_population <> male_population + female_population;

SELECT *
FROM quality.vw_population_data_issues;


