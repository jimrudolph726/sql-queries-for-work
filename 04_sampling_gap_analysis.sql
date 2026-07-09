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
),
StationSampleSequence AS (
    SELECT
        StationID,
        SampleDate,
        LAG(SampleDate) OVER (
            PARTITION BY StationID
            ORDER BY SampleDate
        ) AS PreviousSampleDate
    FROM StationSampleDates
)

SELECT
    StationID,
    PreviousSampleDate,
    SampleDate,
    SampleDate - PreviousSampleDate AS DaysBetweenSamples
FROM StationSampleSequence
WHERE PreviousSampleDate IS NOT NULL
ORDER BY
    StationID,
    SampleDate;


-- Watershed explanation:
-- This compares each station sample date to the previous sample date.
-- It helps analysts review sampling frequency and identify unusually long gaps
-- between monitoring events.



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

WITH LatestStationSample AS (
    SELECT
        StationID,
        MAX(SampleDate) AS MostRecentSampleDate
    FROM Measurements
    GROUP BY
        StationID
)

SELECT
    s.StationID,
    s.StationName,
    l.MostRecentSampleDate
FROM Stations AS s
LEFT JOIN LatestStationSample AS l
    ON s.StationID = l.StationID
WHERE l.MostRecentSampleDate IS NULL
    OR l.MostRecentSampleDate < CURRENT_DATE - INTERVAL '90' DAY
ORDER BY
    l.MostRecentSampleDate,
    s.StationID;


-- Watershed explanation:
-- This identifies stations with no sample records or no samples in the last
-- 90 days. It is useful for field planning, inactive station review, and
-- recurring monitoring checklists.
-- Date arithmetic may need adjustment depending on the database system.



-- ============================================================
-- 4. Station-parameter combinations not sampled recently
-- ============================================================

WITH LatestStationParameterSample AS (
    SELECT
        StationID,
        ParameterID,
        MAX(SampleDate) AS MostRecentSampleDate
    FROM Measurements
    GROUP BY
        StationID,
        ParameterID
)

SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    l.MostRecentSampleDate
FROM LatestStationParameterSample AS l
INNER JOIN Stations AS s
    ON l.StationID = s.StationID
INNER JOIN Parameters AS p
    ON l.ParameterID = p.ParameterID
WHERE l.MostRecentSampleDate < CURRENT_DATE - INTERVAL '90' DAY
ORDER BY
    l.MostRecentSampleDate,
    s.StationID,
    p.ParameterName;


-- Watershed explanation:
-- This checks sampling gaps at the station and parameter level.
-- It helps analysts identify parameters that may be missing from recent
-- monitoring coverage even when the station itself has been sampled.
-- Date arithmetic may need adjustment depending on the database system.
