-- ============================================================
-- 03_parameter_result_analysis.sql
-- Parameter Result Analysis Queries
-- Database: Sample watershed monitoring database
-- Goal: Practice water quality result summaries, parameter review,
--       qualified result checks, and ranked result analysis.
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
-- 4. Highest observed result for each station and parameter
-- ============================================================

WITH RankedResults AS (
    SELECT
        m.MeasurementID,
        m.StationID,
        m.ParameterID,
        m.SampleDate,
        m.SampleTime,
        m.ResultValue,
        m.ResultUnit,
        ROW_NUMBER() OVER (
            PARTITION BY m.StationID, m.ParameterID
            ORDER BY m.ResultValue DESC, m.SampleDate DESC, m.SampleTime DESC
        ) AS ResultRank
    FROM Measurements AS m
    WHERE m.ResultValue IS NOT NULL
)

SELECT
    r.MeasurementID,
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    r.SampleDate,
    r.SampleTime,
    r.ResultValue,
    r.ResultUnit
FROM RankedResults AS r
INNER JOIN Stations AS s
    ON r.StationID = s.StationID
INNER JOIN Parameters AS p
    ON r.ParameterID = p.ParameterID
WHERE r.ResultRank = 1
ORDER BY
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This uses a window function to identify the highest observed result for each
-- station and parameter combination. It is useful for reviewing potential hot
-- spots, unusual values, or results that may need follow-up.
