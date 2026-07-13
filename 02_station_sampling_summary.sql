-- ============================================================
-- 02_station_sampling_summary.sql
-- Station Sampling Summary Queries
-- Database: Sample SQL Server watershed monitoring database
-- Goal: Practice station-level summaries, sampling coverage checks,
--       and monitoring activity review.
-- ============================================================


-- ============================================================
-- 1. Sampling activity by station
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    s.WatershedID,
    COUNT(m.MeasurementID) AS MeasurementCount,
    COUNT(DISTINCT m.ParameterID) AS ParameterCount,
    MIN(m.SampleDate) AS FirstSampleDate,
    MAX(m.SampleDate) AS MostRecentSampleDate
FROM Stations AS s
LEFT JOIN Measurements AS m
    ON s.StationID = m.StationID
GROUP BY
    s.StationID,
    s.StationName,
    s.WatershedID
ORDER BY
    s.StationID;


-- Watershed explanation:
-- This summarizes monitoring activity for each station, including total records,
-- number of sampled parameters, and first and most recent sample dates.
-- It provides a quick station-level view for reporting and program review.



-- ============================================================
-- 2. Stations with no measurement records
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    s.WatershedID
FROM Stations AS s
LEFT JOIN Measurements AS m
    ON s.StationID = m.StationID
WHERE m.StationID IS NULL
ORDER BY
    s.StationID;


-- Watershed explanation:
-- This finds stations that exist in the station table but do not have measurement
-- records. It is useful for identifying inactive stations, setup issues, or
-- locations that may need sampling follow-up.



-- ============================================================
-- 3. Most recent sampling date by station
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    MAX(m.SampleDate) AS MostRecentSampleDate
FROM Stations AS s
LEFT JOIN Measurements AS m
    ON s.StationID = m.StationID
GROUP BY
    s.StationID,
    s.StationName
ORDER BY
    MostRecentSampleDate DESC,
    s.StationID;


-- Watershed explanation:
-- This uses MAX to show the latest sample date available for each station.
-- It is easier to explain than a separate CTE and still answers the same
-- monitoring review question.



-- ============================================================
-- 4. Station and parameter sampling coverage
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    COUNT(m.MeasurementID) AS MeasurementCount,
    MIN(m.SampleDate) AS FirstSampleDate,
    MAX(m.SampleDate) AS MostRecentSampleDate
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
GROUP BY
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName
ORDER BY
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This summarizes how often each parameter has been sampled at each station.
-- It is useful for checking monitoring coverage, parameter availability,
-- and reporting completeness across the watershed network.
