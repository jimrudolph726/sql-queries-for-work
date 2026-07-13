-- ============================================================
-- 07_watershed_reporting_queries.sql
-- Watershed Reporting Queries
-- Database: Sample SQL Server watershed monitoring database
-- Goal: Practice repeatable reporting summaries, monthly totals,
--       coverage review, and monitoring status outputs.
-- ============================================================


-- ============================================================
-- 1. Monthly sampling totals by station
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    YEAR(m.SampleDate) AS SampleYear,
    MONTH(m.SampleDate) AS SampleMonth,
    COUNT(*) AS MeasurementCount,
    COUNT(DISTINCT m.ParameterID) AS ParameterCount
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
GROUP BY
    s.StationID,
    s.StationName,
    YEAR(m.SampleDate),
    MONTH(m.SampleDate)
ORDER BY
    s.StationID,
    SampleYear,
    SampleMonth;


-- Watershed explanation:
-- This summarizes measurement counts and parameter coverage by station and month.
-- It can support recurring monitoring reports, dashboard exports, or monthly
-- watershed activity summaries.



-- ============================================================
-- 2. Monthly sampling totals by watershed
-- ============================================================

SELECT
    w.WatershedID,
    w.WatershedName,
    YEAR(m.SampleDate) AS SampleYear,
    MONTH(m.SampleDate) AS SampleMonth,
    COUNT(*) AS MeasurementCount,
    COUNT(DISTINCT m.StationID) AS StationCount,
    COUNT(DISTINCT m.ParameterID) AS ParameterCount
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Watersheds AS w
    ON s.WatershedID = w.WatershedID
GROUP BY
    w.WatershedID,
    w.WatershedName,
    YEAR(m.SampleDate),
    MONTH(m.SampleDate)
ORDER BY
    w.WatershedName,
    SampleYear,
    SampleMonth;


-- Watershed explanation:
-- This rolls monthly sampling activity up to the watershed level.
-- It helps compare monitoring volume, active stations, and parameter coverage
-- across watershed areas.



-- ============================================================
-- 3. Recent results for field or reporting review
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
    m.ResultQualifier,
    m.QAQCFlag
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
ORDER BY
    m.SampleDate DESC,
    m.SampleTime DESC,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This provides a recent-results view with station names, parameter names,
-- result values, qualifiers, and QA/QC flags. It is useful for routine field,
-- lab, or reporting review.



-- ============================================================
-- 4. Number of sampled stations by parameter
-- ============================================================

SELECT
    p.ParameterID,
    p.ParameterName,
    COUNT(DISTINCT m.StationID) AS SampledStationCount,
    COUNT(*) AS MeasurementCount,
    MIN(m.SampleDate) AS FirstSampleDate,
    MAX(m.SampleDate) AS MostRecentSampleDate
FROM Measurements AS m
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
GROUP BY
    p.ParameterID,
    p.ParameterName
ORDER BY
    SampledStationCount DESC,
    p.ParameterName;


-- Watershed explanation:
-- This shows how widely each parameter has been sampled across monitoring
-- stations. It helps analysts understand parameter coverage and decide which
-- measures have enough data for broader reporting.



-- ============================================================
-- 5. Station monitoring status summary
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    s.WatershedID,
    COUNT(m.MeasurementID) AS MeasurementCount,
    COUNT(DISTINCT m.ParameterID) AS ParameterCount,
    MIN(m.SampleDate) AS FirstSampleDate,
    MAX(m.SampleDate) AS MostRecentSampleDate,
    CASE
        WHEN COUNT(m.MeasurementID) = 0 THEN 'No measurements'
        WHEN MAX(m.SampleDate) < DATEADD(DAY, -90, CAST(GETDATE() AS date)) THEN 'Needs review'
        ELSE 'Recently sampled'
    END AS MonitoringStatus
FROM Stations AS s
LEFT JOIN Measurements AS m
    ON s.StationID = m.StationID
GROUP BY
    s.StationID,
    s.StationName,
    s.WatershedID
ORDER BY
    MonitoringStatus,
    s.StationID;


-- Watershed explanation:
-- This creates a reusable station monitoring status summary.
-- It uses one grouped query to combine record counts, parameter coverage,
-- sample date ranges, and a simple status label.
-- DATEADD and GETDATE are SQL Server date functions.
