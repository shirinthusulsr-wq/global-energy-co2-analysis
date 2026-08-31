CREATE DATABASE EnergyEmissionsDB;
USE EnergyEmissionsDB;

CREATE TABLE co2_emissions (
    entity VARCHAR(150),
    code VARCHAR(20),
    year INT,
    annual_co2_emissions FLOAT
);

USE EnergyEmissionsDB;

SELECT *
FROM co2_emissions
LIMIT 10;

SELECT COUNT(*) AS total_rows
FROM co2_emissions;

USE EnergyEmissionsDB;

CREATE TABLE energy_supply (
    entity VARCHAR(150),
    code VARCHAR(20),
    year INT,
    total_energy_supply FLOAT
);

SELECT
    MIN(year) AS first_year,
    MAX(year) AS last_year
FROM co2_emissions;

SELECT
    MIN(year) AS first_year,
    MAX(year) AS last_year
FROM energy_supply;
SELECT
    SUM(entity IS NULL OR entity = '') AS missing_entity,
    SUM(code IS NULL OR code = '') AS missing_code,
    SUM(year IS NULL) AS missing_year,
    SUM(annual_co2_emissions IS NULL) AS missing_co2
FROM co2_emissions;

SELECT
    SUM(entity IS NULL OR entity = '') AS missing_entity,
    SUM(code IS NULL OR code = '') AS missing_code,
    SUM(year IS NULL) AS missing_year,
    SUM(total_energy_supply IS NULL) AS missing_energy
FROM energy_supply;

SELECT
    entity,
    code,
    year,
    COUNT(*) AS row_count
FROM co2_emissions
GROUP BY entity, code, year
HAVING COUNT(*) > 1;

SELECT
    entity,
    code,
    year,
    COUNT(*) AS row_count
FROM energy_supply
GROUP BY entity, code, year
HAVING COUNT(*) > 1;

SELECT
    c.entity,
    c.code,
    c.year,
    c.annual_co2_emissions,
    e.total_energy_supply
FROM co2_emissions c
INNER JOIN energy_supply e
    ON c.entity = e.entity
    AND c.code = e.code
    AND c.year = e.year
LIMIT 20;

SELECT COUNT(*) AS matched_rows
FROM co2_emissions c
INNER JOIN energy_supply e
    ON c.entity = e.entity
    AND c.code = e.code
    AND c.year = e.year;
    
  CREATE VIEW vw_energy_emissions AS

SELECT
    c.entity AS country,
    c.code AS country_code,
    c.year,
    c.annual_co2_emissions,
    e.total_energy_supply
FROM co2_emissions c
INNER JOIN energy_supply e
    ON c.entity = e.entity
    AND c.code = e.code
    AND c.year = e.year
WHERE c.code IS NOT NULL
  AND c.code <> '';  
  
SELECT *
FROM vw_energy_emissions
LIMIT 20;

SELECT COUNT(*) AS total_rows
FROM vw_energy_emissions;

SELECT COUNT(DISTINCT country) AS total_entities
FROM vw_energy_emissions;

SELECT
    country,
    annual_co2_emissions
FROM vw_energy_emissions
WHERE year = 2024
ORDER BY annual_co2_emissions DESC
LIMIT 10;

SELECT
    year,
    annual_co2_emissions
FROM vw_energy_emissions
WHERE country = 'India'
ORDER BY year;

SELECT
    year,
    annual_co2_emissions
FROM vw_energy_emissions
WHERE country = 'India'
AND year >= 1990
ORDER BY year;

SELECT
    country,
    year,
    annual_co2_emissions
FROM vw_energy_emissions
WHERE country IN (
    'China',
    'India',
    'United States',
    'Germany',
    'Japan'
)
AND year >= 1990
ORDER BY year, country;

SELECT
    country,
    total_energy_supply
FROM vw_energy_emissions
WHERE year = 2024
ORDER BY total_energy_supply DESC
LIMIT 10;

SELECT
    country,
    annual_co2_emissions,
    total_energy_supply
FROM vw_energy_emissions
WHERE year = 2024
ORDER BY annual_co2_emissions DESC
LIMIT 20;

SELECT
    country,
    year,
    annual_co2_emissions,
    total_energy_supply,
    annual_co2_emissions /
        NULLIF(total_energy_supply, 0) AS co2_energy_ratio
FROM vw_energy_emissions
WHERE year = 2024
ORDER BY co2_energy_ratio DESC;

SELECT
    country,
    year,
    annual_co2_emissions,
    LAG(annual_co2_emissions)
        OVER (
            PARTITION BY country
            ORDER BY year
        ) AS previous_year_co2
FROM vw_energy_emissions
WHERE country = 'India'
ORDER BY year;

WITH co2_growth AS (
    SELECT
        country,
        year,
        annual_co2_emissions,
        LAG(annual_co2_emissions)
            OVER (
                PARTITION BY country
                ORDER BY year
            ) AS previous_year_co2
    FROM vw_energy_emissions
)

USE EnergyEmissionsDB;


/* =============================================
   STEP 22 - CO2 CHANGE: 2023 vs 2024
   Simpler version without CTE
   ============================================= */

SELECT
    current_year.country,
    current_year.annual_co2_emissions AS co2_2024,
    previous_year.annual_co2_emissions AS co2_2023,

    ROUND(
        (
            current_year.annual_co2_emissions -
            previous_year.annual_co2_emissions
        )
        /
        NULLIF(previous_year.annual_co2_emissions, 0)
        * 100,
        2
    ) AS yoy_change_pct

FROM vw_energy_emissions AS current_year

INNER JOIN vw_energy_emissions AS previous_year
    ON current_year.country = previous_year.country
    AND current_year.year = previous_year.year + 1

WHERE current_year.year = 2024

ORDER BY yoy_change_pct DESC;

SELECT
    current_year.country,
    current_year.annual_co2_emissions AS co2_2024,
    previous_year.annual_co2_emissions AS co2_2023,

    ROUND(
        (
            current_year.annual_co2_emissions -
            previous_year.annual_co2_emissions
        )
        /
        NULLIF(previous_year.annual_co2_emissions, 0)
        * 100,
        2
    ) AS yoy_change_pct

FROM vw_energy_emissions AS current_year

INNER JOIN vw_energy_emissions AS previous_year
    ON current_year.country = previous_year.country
    AND current_year.year = previous_year.year + 1

WHERE current_year.year = 2024
AND previous_year.annual_co2_emissions > 0

ORDER BY yoy_change_pct DESC

LIMIT 10;

SELECT
    country,
    country_code,
    year,
    annual_co2_emissions,
    total_energy_supply
FROM vw_energy_emissions
WHERE year >= 1990
ORDER BY country, year;

SELECT COUNT(*) AS powerbi_rows
FROM vw_energy_emissions
WHERE year >= 1990;

