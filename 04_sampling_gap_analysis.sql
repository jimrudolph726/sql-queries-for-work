/*
    04_sampling_gap_analysis.sql

    Purpose:
    Review sampling gaps and identify stations that may need follow-up.
*/

-- Days between sampling events for each station.
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


-- Latest sample date by station.
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


-- Stations with no samples in the last 90 days.
-- Date arithmetic may need adjustment depending on the database system.
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


-- Station-parameter combinations that have not been sampled recently.
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
