/*
    01_duplicate_measurement_checks.sql

    Purpose:
    Identify possible duplicate watershed measurement records using station,
    parameter, sample date, and sample time.
*/

-- Duplicate measurement check requested for this repository.
SELECT
    StationID,
    ParameterID,
    SampleDate,
    SampleTime,
    COUNT(*) AS RecordCount
FROM Measurements
GROUP BY
    StationID,
    ParameterID,
    SampleDate,
    SampleTime
HAVING COUNT(*) > 1;


-- Duplicate check with station and parameter names for easier review.
SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime,
    COUNT(*) AS RecordCount
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
GROUP BY
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime
HAVING COUNT(*) > 1
ORDER BY
    m.SampleDate,
    m.SampleTime,
    s.StationID,
    p.ParameterID;


-- Full duplicate record detail for analyst review.
WITH DuplicateKeys AS (
    SELECT
        StationID,
        ParameterID,
        SampleDate,
        SampleTime
    FROM Measurements
    GROUP BY
        StationID,
        ParameterID,
        SampleDate,
        SampleTime
    HAVING COUNT(*) > 1
)
SELECT
    m.*
FROM Measurements AS m
INNER JOIN DuplicateKeys AS d
    ON m.StationID = d.StationID
    AND m.ParameterID = d.ParameterID
    AND m.SampleDate = d.SampleDate
    AND m.SampleTime = d.SampleTime
ORDER BY
    m.SampleDate,
    m.SampleTime,
    m.StationID,
    m.ParameterID;
