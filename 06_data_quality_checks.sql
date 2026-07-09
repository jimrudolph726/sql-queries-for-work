/*
    06_data_quality_checks.sql

    Purpose:
    Identify missing, incomplete, or unusual watershed measurement records
    before using the data in reports.
*/

-- Missing required values in the Measurements table.
SELECT
    'Missing StationID' AS IssueType,
    COUNT(*) AS IssueCount
FROM Measurements
WHERE StationID IS NULL

UNION ALL

SELECT
    'Missing ParameterID' AS IssueType,
    COUNT(*) AS IssueCount
FROM Measurements
WHERE ParameterID IS NULL

UNION ALL

SELECT
    'Missing SampleDate' AS IssueType,
    COUNT(*) AS IssueCount
FROM Measurements
WHERE SampleDate IS NULL

UNION ALL

SELECT
    'Missing SampleTime' AS IssueType,
    COUNT(*) AS IssueCount
FROM Measurements
WHERE SampleTime IS NULL

UNION ALL

SELECT
    'Missing ResultValue' AS IssueType,
    COUNT(*) AS IssueCount
FROM Measurements
WHERE ResultValue IS NULL;


-- Measurement records with station IDs that do not exist in the Stations table.
SELECT
    m.MeasurementID,
    m.StationID,
    m.ParameterID,
    m.SampleDate,
    m.SampleTime
FROM Measurements AS m
LEFT JOIN Stations AS s
    ON m.StationID = s.StationID
WHERE s.StationID IS NULL
ORDER BY
    m.SampleDate,
    m.StationID;


-- Measurement records with parameter IDs that do not exist in the Parameters table.
SELECT
    m.MeasurementID,
    m.StationID,
    m.ParameterID,
    m.SampleDate,
    m.SampleTime
FROM Measurements AS m
LEFT JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE p.ParameterID IS NULL
ORDER BY
    m.SampleDate,
    m.ParameterID;


-- Negative result values for parameters where negatives are usually unexpected.
SELECT
    m.MeasurementID,
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime,
    m.ResultValue,
    m.ResultUnit
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE m.ResultValue < 0
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- pH values outside the expected 0 to 14 range.
SELECT
    m.MeasurementID,
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    m.SampleDate,
    m.SampleTime,
    m.ResultValue
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE UPPER(p.ParameterName) = 'PH'
    AND (m.ResultValue < 0 OR m.ResultValue > 14)
ORDER BY
    m.SampleDate DESC,
    s.StationID;


-- Records with unresolved QA/QC flags.
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
    m.QAQCFlag
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
WHERE m.QAQCFlag IS NOT NULL
    AND m.QAQCFlag NOT IN ('Approved', 'Reviewed')
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;
