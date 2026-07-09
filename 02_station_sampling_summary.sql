/*
    02_station_sampling_summary.sql

    Purpose:
    Summarize watershed monitoring activity by station.
*/

-- Sampling activity by station.
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


-- Stations with no measurement records.
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


-- Most recent sampling event by station.
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
INNER JOIN LatestStationSample AS l
    ON s.StationID = l.StationID
ORDER BY
    l.MostRecentSampleDate DESC,
    s.StationID;


-- Station and parameter sampling coverage.
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
