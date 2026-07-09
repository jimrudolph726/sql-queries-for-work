/*
    03_parameter_result_analysis.sql

    Purpose:
    Analyze water quality parameter results by station and watershed.
*/

-- Parameter result summary by station.
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


-- Parameter result summary by watershed.
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


-- Results flagged as non-detects or qualified values.
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


-- Highest observed result for each station and parameter.
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
