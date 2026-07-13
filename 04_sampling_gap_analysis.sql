-- ============================================================
-- 04_sampling_gap_analysis.sql
-- Sampling Gap Analysis Queries
-- Database: Sample watershed monitoring database
-- Goal: Practice monitoring gap review, date comparisons,
--       and station follow-up analysis.
-- ============================================================


-- ============================================================
-- 1. Days between sampling events for each station
-- ============================================================

WITH StationSampleDates AS (
    SELECT DISTINCT
        StationID,
        SampleDate
    FROM Measurements
    WHERE SampleDate IS NOT NULL
)

SELECT
    StationID,
    LAG(SampleDate) OVER (
        PARTITION BY StationID
        ORDER BY SampleDate
    ) AS PreviousSampleDate,
    SampleDate,
    SampleDate - LAG(SampleDate) OVER (
        PARTITION BY StationID
        ORDER BY SampleDate
    ) AS DaysBetweenSamples
FROM StationSampleDates
ORDER BY
    StationID,
    SampleDate;


-- Watershed explanation:
-- This compares each station sample date to the previous sample date.
-- It helps analysts review sampling frequency and identify unusually long gaps
-- between monitoring events.
-- The first sample for each station will not have a previous date to compare.



-- ============================================================
-- 2. Latest sample date by station
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
    MostRecentSampleDate;


-- Watershed explanation:
-- This shows the most recent sample date available for every station.
-- It is a simple monitoring status check for deciding which stations may need
-- more recent field activity.



-- ============================================================
-- 3. Stations with no samples in the last 90 days
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
HAVING MAX(m.SampleDate) IS NULL
    OR MAX(m.SampleDate) < CURRENT_DATE - INTERVAL '90' DAY
ORDER BY
    MostRecentSampleDate,
    s.StationID;


-- Watershed explanation:
-- This identifies stations with no sample records or no samples in the last
-- 90 days. It is useful for field planning, inactive station review, and
-- recurring monitoring checklists.
-- The HAVING clause filters after the latest sample date is calculated.
-- Date arithmetic may need adjustment depending on the database system.



-- ============================================================
-- 4. Station-parameter combinations not sampled recently
-- ============================================================

SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
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
HAVING MAX(m.SampleDate) < CURRENT_DATE - INTERVAL '90' DAY
ORDER BY
    MostRecentSampleDate,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This checks sampling gaps at the station and parameter level.
-- It helps analysts identify parameters that may be missing from recent
-- monitoring coverage even when the station itself has been sampled.
-- The query groups records first, then uses HAVING to keep only older activity.
-- Date arithmetic may need adjustment depending on the database system.
