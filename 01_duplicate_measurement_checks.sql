-- ============================================================
-- 01_duplicate_measurement_checks.sql
-- Duplicate Measurement Check Queries
-- Database: Sample watershed monitoring database
-- Goal: Practice data quality review, duplicate detection,
--       and analyst-ready watershed measurement validation.
-- ============================================================


-- ============================================================
-- 1. Basic duplicate measurement key check
-- ============================================================

SELECT
    StationID,
    ParameterID,
    SampleDate,
    SampleTime,
    COUNT(*) AS RecordCount
FROM Measurements
GROUP BY
    StationID,
    ParameterID,
    SampleDate,
    SampleTime
HAVING COUNT(*) > 1;


-- Watershed explanation:
-- This identifies station, parameter, sample date, and sample time combinations
-- that appear more than once in the Measurements table.
-- This is useful before reporting because duplicate records can overstate
-- sampling counts and distort summary statistics.



-- ============================================================
-- 2. Duplicate checks with station and parameter names
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime,
    COUNT(*) AS RecordCount
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
GROUP BY
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime
HAVING COUNT(*) > 1
ORDER BY
    m.SampleDate,
    m.SampleTime,
    s.StationID,
    p.ParameterID;


-- Watershed explanation:
-- This expands the duplicate check by adding readable station and parameter names.
-- It makes the results easier for analysts, field staff, or reviewers to interpret.



-- ============================================================
-- 3. Full duplicate record detail for analyst review
-- ============================================================

WITH DuplicateKeys AS (
    SELECT
        StationID,
        ParameterID,
        SampleDate,
        SampleTime
    FROM Measurements
    GROUP BY
        StationID,
        ParameterID,
        SampleDate,
        SampleTime
    HAVING COUNT(*) > 1
)

SELECT
    m.*
FROM Measurements AS m
INNER JOIN DuplicateKeys AS d
    ON m.StationID = d.StationID
    AND m.ParameterID = d.ParameterID
    AND m.SampleDate = d.SampleDate
    AND m.SampleTime = d.SampleTime
ORDER BY
    m.SampleDate,
    m.SampleTime,
    m.StationID,
    m.ParameterID;


-- Watershed explanation:
-- This returns the full measurement rows for records flagged as possible duplicates.
-- It supports follow-up review when analysts need to compare IDs, qualifiers,
-- result values, units, or QA/QC flags before deciding how to handle the records.
