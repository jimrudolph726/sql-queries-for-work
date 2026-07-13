-- ============================================================
-- 06_data_quality_checks.sql
-- Data Quality Check Queries
-- Database: Sample watershed monitoring database
-- Goal: Practice missing value checks, referential review,
--       range validation, and QA/QC screening.
-- ============================================================


-- ============================================================
-- 1. Missing required value count summary
-- ============================================================

SELECT
    SUM(CASE WHEN StationID IS NULL THEN 1 ELSE 0 END) AS MissingStationIDCount,
    SUM(CASE WHEN ParameterID IS NULL THEN 1 ELSE 0 END) AS MissingParameterIDCount,
    SUM(CASE WHEN SampleDate IS NULL THEN 1 ELSE 0 END) AS MissingSampleDateCount,
    SUM(CASE WHEN SampleTime IS NULL THEN 1 ELSE 0 END) AS MissingSampleTimeCount,
    SUM(CASE WHEN ResultValue IS NULL THEN 1 ELSE 0 END) AS MissingResultValueCount
FROM Measurements;


-- Watershed explanation:
-- This counts missing values in key measurement fields in one summary row.
-- Each CASE statement turns a missing value into 1, and SUM adds those flags.
-- It is a compact checklist for incomplete records before reporting.



-- ============================================================
-- 2. Measurement records with station IDs not in Stations
-- ============================================================

SELECT
    m.MeasurementID,
    m.StationID,
    m.ParameterID,
    m.SampleDate,
    m.SampleTime
FROM Measurements AS m
LEFT JOIN Stations AS s
    ON m.StationID = s.StationID
WHERE s.StationID IS NULL
ORDER BY
    m.SampleDate,
    m.StationID;


-- Watershed explanation:
-- This identifies measurement records linked to station IDs that do not exist
-- in the Stations table. It helps catch mismatched IDs, import issues, or
-- missing station reference records.



-- ============================================================
-- 3. Measurement records with parameter IDs not in Parameters
-- ============================================================

SELECT
    m.MeasurementID,
    m.StationID,
    m.ParameterID,
    m.SampleDate,
    m.SampleTime
FROM Measurements AS m
LEFT JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE p.ParameterID IS NULL
ORDER BY
    m.SampleDate,
    m.ParameterID;


-- Watershed explanation:
-- This identifies measurement records linked to parameter IDs that do not exist
-- in the Parameters table. It supports cleaner joins and more reliable
-- parameter-level reporting.



-- ============================================================
-- 4. Negative result values for unexpected parameters
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
    m.ResultUnit
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE m.ResultValue < 0
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This flags negative result values, which may be invalid for many water
-- quality measurements. These records should be reviewed before using them in
-- summaries or trend analysis.



-- ============================================================
-- 5. pH values outside the expected 0 to 14 range
-- ============================================================

SELECT
    m.MeasurementID,
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime,
    m.ResultValue
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE UPPER(p.ParameterName) = 'PH'
    AND (m.ResultValue < 0 OR m.ResultValue > 14)
ORDER BY
    m.SampleDate DESC,
    s.StationID;


-- Watershed explanation:
-- This checks for pH results outside the standard 0 to 14 scale.
-- It is a targeted validation query for one common water quality parameter.



-- ============================================================
-- 6. Records with unresolved QA/QC flags
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
    m.QAQCFlag
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE m.QAQCFlag IS NOT NULL
    AND m.QAQCFlag NOT IN ('Approved', 'Reviewed')
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This lists records with QA/QC flags that have not been marked as approved or
-- reviewed. It helps analysts separate records that are ready for reporting
-- from records that may still need quality review.
