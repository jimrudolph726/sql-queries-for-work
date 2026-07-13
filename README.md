# Watershed SQL Queries for Work

This repository contains SQL queries written for watershed data analyst workflows. The examples focus on monitoring stations, water quality parameters, sample dates, sample times, measurement results, data quality review, and repeatable reporting-style queries.

The goal of this project is to demonstrate how SQL can be used not only to retrieve environmental data, but also to support clean datasets, reliable reporting, field and lab review, and watershed decision-making.

## Purpose

This project was created as part of my continued development as a data analyst working with environmental and watershed data. The queries are designed around practical data analyst tasks such as:

* Finding duplicate station, parameter, date, and time records
* Summarizing sampling activity by station
* Reviewing parameter results and water quality trends
* Checking missing or incomplete measurement records
* Identifying sampling gaps and inactive stations
* Screening results against water quality criteria
* Building repeatable watershed reporting queries
* Documenting SQL in a clear, job-focused way

Rather than treating SQL as an isolated technical skill, this repository focuses on applying SQL to realistic watershed monitoring, water quality, and environmental data workflows.

## Tools Used

* DataGrip
* SQL Server / T-SQL
* Relational databases
* GitHub

## Database

The queries in this repository are written using a sample SQL Server watershed monitoring database structure containing tables such as:

* `Measurements`
* `Stations`
* `Parameters`
* `Watersheds`
* `SampleEvents`
* `ParameterCriteria`

Common fields used throughout the queries include:

* `StationID`
* `ParameterID`
* `SampleDate`
* `SampleTime`
* `ResultValue`
* `ResultUnit`
* `ResultQualifier`
* `QAQCFlag`

This structure allows for practice with station-level analysis, parameter summaries, sampling frequency checks, duplicate detection, missing value review, criteria screening, and reporting-style queries.

## Repository Structure

```text
sql-queries-for-work/
    README.md
    01_duplicate_measurement_checks.sql
    02_station_sampling_summary.sql
    03_parameter_result_analysis.sql
    04_sampling_gap_analysis.sql
    05_water_quality_criteria_screening.sql
    06_data_quality_checks.sql
    07_watershed_reporting_queries.sql
```

## Query Topics

### 01_duplicate_measurement_checks.sql

Queries for finding duplicate measurement records based on station, parameter, sample date, and sample time.
Examples include duplicate record counts, duplicate review details, and duplicate checks with station and parameter names.

Skills demonstrated:

* `GROUP BY`
* `HAVING`
* `COUNT`
* duplicate detection
* data quality validation

### 02_station_sampling_summary.sql

Station-level sampling summaries.
Examples include total records by station, first and most recent sample dates, number of sampled parameters, and stations with no measurement records.

Skills demonstrated:

* `LEFT JOIN`
* station-level aggregation
* date summaries
* missing activity checks

### 03_parameter_result_analysis.sql

Parameter-level result summaries for watershed monitoring.
Examples include minimum, maximum, average, and count of results by station and parameter.

Skills demonstrated:

* `JOIN`
* `MIN`
* `MAX`
* `AVG`
* parameter-level aggregation

### 04_sampling_gap_analysis.sql

Queries for reviewing sampling gaps and monitoring activity.
Examples include days between sample events, latest sample by station, and stations that may need follow-up sampling.

Skills demonstrated:

* common table expressions
* `LAG`
* `PARTITION BY`
* date comparison
* sampling schedule review

### 05_water_quality_criteria_screening.sql

Queries for screening measurement results against parameter criteria.
Examples include exceedance review, exceedance counts by station, and exceedance detail records with review labels.

Skills demonstrated:

* criteria joins
* conditional filtering
* exceedance reporting
* environmental compliance support

### 06_data_quality_checks.sql

Queries for identifying possible data quality issues before reporting.
Examples include missing station IDs, missing parameters, missing sample dates, missing result values, negative results, and unresolved QA/QC flags.

Skills demonstrated:

* `CASE WHEN`
* aggregate validation summaries
* null checks
* validation logic
* field and lab data review

### 07_watershed_reporting_queries.sql

Reporting-style queries for watershed summaries.
Examples include monthly sampling totals, parameter coverage, recent monitoring results, and station activity summaries.

Skills demonstrated:

* reporting queries
* grouping by station, parameter, and time period
* `CASE WHEN` status labels
* reusable SQL documentation

## Example Query

```sql
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
```

## Watershed Explanation

This query identifies possible duplicate measurement records where the same station, parameter, sample date, and sample time appear more than once. This type of query is useful before producing monitoring reports because duplicate records can overstate sample counts, affect averages, and create confusion during data review.

## Skills Demonstrated

This repository demonstrates practical SQL skills including:

* Selecting and filtering watershed monitoring records
* Joining station, parameter, and measurement tables
* Aggregating results by station, parameter, date, and watershed
* Checking for duplicate and missing records
* Reviewing sampling coverage and monitoring gaps
* Screening results against water quality criteria
* Using common table expressions
* Using window functions
* Writing SQL with clear environmental data purpose and documentation

## Why This Project Matters

Watershed monitoring depends on clean, reliable, and well-structured data. This project demonstrates how SQL can be used to validate source data, summarize field and lab measurements, identify possible data issues, and create repeatable reporting logic.

The emphasis is on writing queries that are not only technically correct, but also understandable, reusable, and connected to real watershed data questions.

## SQL Dialect Note

These queries are written using Microsoft SQL Server syntax, also known as T-SQL. The project uses SQL Server date functions such as `YEAR`, `MONTH`, `DATEADD`, `DATEDIFF`, and `GETDATE`.
