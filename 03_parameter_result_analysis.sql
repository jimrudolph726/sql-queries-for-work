-- ============================================================
-- 03_parameter_result_analysis.sql
-- Parameter Result Analysis Queries
-- Database: Sample SQL Server watershed monitoring database
-- Goal: Practice water quality result summaries, parameter review,
--       qualified result checks, and high result review.
-- ============================================================


-- ============================================================
-- 1. Parameter result summary by station
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.ResultUnit,
    COUNT(*) AS ResultCount,
    MIN(m.ResultValue) AS MinimumResult,
    MAX(m.ResultValue) AS MaximumResult,
    AVG(m.ResultValue) AS AverageResult
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE m.ResultValue IS NOT NULL
GROUP BY
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.ResultUnit
ORDER BY
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This summarizes result counts, minimums, maximums, and averages for each
-- station and parameter. It provides a compact view of water quality conditions
-- at each monitoring location.



-- ============================================================
-- 2. Parameter result summary by watershed
-- ============================================================

SELECT
    w.WatershedID,
    w.WatershedName,
    p.ParameterID,
    p.ParameterName,
    m.ResultUnit,
    COUNT(*) AS ResultCount,
    MIN(m.ResultValue) AS MinimumResult,
    MAX(m.ResultValue) AS MaximumResult,
    AVG(m.ResultValue) AS AverageResult
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Watersheds AS w
    ON s.WatershedID = w.WatershedID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE m.ResultValue IS NOT NULL
GROUP BY
    w.WatershedID,
    w.WatershedName,
    p.ParameterID,
    p.ParameterName,
    m.ResultUnit
ORDER BY
    w.WatershedName,
    p.ParameterName;


-- Watershed explanation:
-- This rolls parameter results up to the watershed level.
-- It is useful when comparing water quality patterns across watersheds instead
-- of reviewing each station separately.



-- ============================================================
-- 3. Results flagged as non-detects or qualified values
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
    m.ResultQualifier
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE m.ResultQualifier IS NOT NULL
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This lists records with result qualifiers, such as non-detects or other
-- lab notes. These records often need special attention before averages,
-- exceedance checks, or public reports are finalized.



-- ============================================================
-- 4. Highest result value by station and parameter
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.ResultUnit,
    MAX(m.ResultValue) AS HighestResult
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE m.ResultValue IS NOT NULL
GROUP BY
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.ResultUnit
ORDER BY
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This shows the highest measured result for each station and parameter.
-- It uses a simple MAX summary instead of a window function, which makes the
-- query easier to explain while still supporting high-value review.
