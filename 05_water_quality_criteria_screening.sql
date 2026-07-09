/*
    05_water_quality_criteria_screening.sql

    Purpose:
    Screen watershed measurement results against water quality criteria.
*/

-- Measurement results above a maximum water quality criterion.
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
    c.MaximumCriterionValue,
    c.CriterionUnit
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
INNER JOIN ParameterCriteria AS c
    ON m.ParameterID = c.ParameterID
WHERE c.MaximumCriterionValue IS NOT NULL
    AND m.ResultValue > c.MaximumCriterionValue
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- Measurement results below a minimum water quality criterion.
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
    c.MinimumCriterionValue,
    c.CriterionUnit
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
INNER JOIN ParameterCriteria AS c
    ON m.ParameterID = c.ParameterID
WHERE c.MinimumCriterionValue IS NOT NULL
    AND m.ResultValue < c.MinimumCriterionValue
ORDER BY
    m.SampleDate DESC,
    s.StationID,
    p.ParameterName;


-- Exceedance count by station and parameter.
SELECT
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    COUNT(*) AS ExceedanceCount
FROM Measurements AS m
INNER JOIN Stations AS s
    ON m.StationID = s.StationID
INNER JOIN Parameters AS p
    ON m.ParameterID = p.ParameterID
INNER JOIN ParameterCriteria AS c
    ON m.ParameterID = c.ParameterID
WHERE (
        c.MaximumCriterionValue IS NOT NULL
        AND m.ResultValue > c.MaximumCriterionValue
    )
    OR (
        c.MinimumCriterionValue IS NOT NULL
        AND m.ResultValue < c.MinimumCriterionValue
    )
GROUP BY
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName
ORDER BY
    ExceedanceCount DESC,
    s.StationID,
    p.ParameterName;


-- Most recent exceedance by station and parameter.
WITH Exceedances AS (
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
            ORDER BY m.SampleDate DESC, m.SampleTime DESC
        ) AS ExceedanceRank
    FROM Measurements AS m
    INNER JOIN ParameterCriteria AS c
        ON m.ParameterID = c.ParameterID
    WHERE (
            c.MaximumCriterionValue IS NOT NULL
            AND m.ResultValue > c.MaximumCriterionValue
        )
        OR (
            c.MinimumCriterionValue IS NOT NULL
            AND m.ResultValue < c.MinimumCriterionValue
        )
)
SELECT
    e.MeasurementID,
    s.StationID,
    s.StationName,
    p.ParameterID,
    p.ParameterName,
    e.SampleDate,
    e.SampleTime,
    e.ResultValue,
    e.ResultUnit
FROM Exceedances AS e
INNER JOIN Stations AS s
    ON e.StationID = s.StationID
INNER JOIN Parameters AS p
    ON e.ParameterID = p.ParameterID
WHERE e.ExceedanceRank = 1
ORDER BY
    s.StationID,
    p.ParameterName;
