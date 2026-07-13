-- ============================================================
-- 05_water_quality_criteria_screening.sql
-- Water Quality Criteria Screening Queries
-- Database: Sample SQL Server watershed monitoring database
-- Goal: Practice criteria joins, exceedance review,
--       and environmental reporting support.
-- ============================================================


-- ============================================================
-- 1. Measurement results above a maximum criterion
-- ============================================================

SELECT
    m.MeasurementID,
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime,
    m.ResultValue,
    m.ResultUnit,
    c.MaximumCriterionValue,
    c.CriterionUnit
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
INNER JOIN ParameterCriteria AS c
    ON m.ParameterID = c.ParameterID
WHERE c.MaximumCriterionValue IS NOT NULL
    AND m.ResultValue > c.MaximumCriterionValue
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This finds measurement results that are greater than a maximum water quality
-- criterion. It supports exceedance review and helps identify results that may
-- require additional attention before reporting.



-- ============================================================
-- 2. Measurement results below a minimum criterion
-- ============================================================

SELECT
    m.MeasurementID,
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime,
    m.ResultValue,
    m.ResultUnit,
    c.MinimumCriterionValue,
    c.CriterionUnit
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
INNER JOIN ParameterCriteria AS c
    ON m.ParameterID = c.ParameterID
WHERE c.MinimumCriterionValue IS NOT NULL
    AND m.ResultValue < c.MinimumCriterionValue
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This finds measurement results that are lower than a minimum water quality
-- criterion. It is useful for parameters where low values may indicate a
-- potential concern or require follow-up review.



-- ============================================================
-- 3. Exceedance count by station and parameter
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    COUNT(*) AS ExceedanceCount
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
INNER JOIN ParameterCriteria AS c
    ON m.ParameterID = c.ParameterID
WHERE (
        c.MaximumCriterionValue IS NOT NULL
        AND m.ResultValue > c.MaximumCriterionValue
    )
    OR (
        c.MinimumCriterionValue IS NOT NULL
        AND m.ResultValue < c.MinimumCriterionValue
    )
GROUP BY
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName
ORDER BY
    ExceedanceCount DESC,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This summarizes how many criterion exceedances occurred for each station and
-- parameter. It helps prioritize stations or parameters with repeated results
-- outside expected water quality ranges.



-- ============================================================
-- 4. Exceedance detail with review type
-- ============================================================

SELECT
    m.MeasurementID,
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime,
    m.ResultValue,
    m.ResultUnit,
    CASE
        WHEN c.MaximumCriterionValue IS NOT NULL
            AND m.ResultValue > c.MaximumCriterionValue
            THEN 'Above maximum criterion'
        WHEN c.MinimumCriterionValue IS NOT NULL
            AND m.ResultValue < c.MinimumCriterionValue
            THEN 'Below minimum criterion'
    END AS ReviewType
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
INNER JOIN ParameterCriteria AS c
    ON m.ParameterID = c.ParameterID
WHERE (
        c.MaximumCriterionValue IS NOT NULL
        AND m.ResultValue > c.MaximumCriterionValue
    )
    OR (
        c.MinimumCriterionValue IS NOT NULL
        AND m.ResultValue < c.MinimumCriterionValue
    )
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This returns exceedance records and labels whether each result is above a
-- maximum criterion or below a minimum criterion.
-- It avoids ranking logic and gives a clear review list for reporting follow-up.
