/*
    07_watershed_reporting_queries.sql

    Purpose:
    Build repeatable reporting-style queries for watershed monitoring data.
*/

-- Monthly sampling totals by station.
SELECT
    s.StationID,
    s.StationName,
    EXTRACT(YEAR FROM m.SampleDate) AS SampleYear,
    EXTRACT(MONTH FROM m.SampleDate) AS SampleMonth,
    COUNT(*) AS MeasurementCount,
    COUNT(DISTINCT m.ParameterID) AS ParameterCount
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
GROUP BY
    s.StationID,
    s.StationName,
    EXTRACT(YEAR FROM m.SampleDate),
    EXTRACT(MONTH FROM m.SampleDate)
ORDER BY
    s.StationID,
    SampleYear,
    SampleMonth;


-- Monthly sampling totals by watershed.
SELECT
    w.WatershedID,
    w.WatershedName,
    EXTRACT(YEAR FROM m.SampleDate) AS SampleYear,
    EXTRACT(MONTH FROM m.SampleDate) AS SampleMonth,
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
    EXTRACT(YEAR FROM m.SampleDate),
    EXTRACT(MONTH FROM m.SampleDate)
ORDER BY
    w.WatershedName,
    SampleYear,
    SampleMonth;


-- Recent results for a field or reporting review.
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


-- Number of sampled stations by parameter.
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


-- Station monitoring status summary.
WITH StationActivity AS (
    SELECT
        StationID,
        COUNT(*) AS MeasurementCount,
        COUNT(DISTINCT ParameterID) AS ParameterCount,
        MIN(SampleDate) AS FirstSampleDate,
        MAX(SampleDate) AS MostRecentSampleDate
    FROM Measurements
    GROUP BY
        StationID
)
SELECT
    s.StationID,
    s.StationName,
    s.WatershedID,
    COALESCE(a.MeasurementCount, 0) AS MeasurementCount,
    COALESCE(a.ParameterCount, 0) AS ParameterCount,
    a.FirstSampleDate,
    a.MostRecentSampleDate,
    CASE
        WHEN a.StationID IS NULL THEN 'No measurements'
        WHEN a.MostRecentSampleDate < CURRENT_DATE - INTERVAL '90' DAY THEN 'Needs review'
        ELSE 'Recently sampled'
    END AS MonitoringStatus
FROM Stations AS s
LEFT JOIN StationActivity AS a
    ON s.StationID = a.StationID
ORDER BY
    MonitoringStatus,
    s.StationID;
