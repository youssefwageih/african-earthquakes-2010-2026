-- Project : African Seismic Activity Analysis
-- Author  : youssef
-- Source  : earthquakes_africa.csv  (2,740 events, 2010-01-09 .. 2026-10-07)
-- Purpose : Exploratory analysis of African seismic activity, trends,
--           magnitude distribution and data quality.
--


-- Most active countries, with average and peak magnitude
SELECT
    country_display AS country,
    COUNT(*) AS total_earthquakes,
    ROUND(AVG(mag), 2) AS avg_magnitude,
    MAX(mag) AS max_magnitude,
    MIN(mag) AS min_magnitude,
    ROUND(100.0 * SUM(CASE WHEN any_measurement_flag = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)AS pct_low_quality_records
FROM earthquakes
GROUP BY country_display
HAVING COUNT(*) >= 20
ORDER BY total_earthquakes DESC;   -- DESC, because we're going down... like the tectonic plates


-- Year-over-year trend in event frequency
WITH yearly AS (
    SELECT
        event_year AS event_year,
        COUNT(*) AS quake_count,
        ROUND(AVG(mag), 3) AS avg_magnitude,
        MAX(mag) AS peak_magnitude
    FROM earthquakes
    GROUP BY event_year),
with_change AS (
    SELECT
        event_year,
        quake_count,
        avg_magnitude,
        peak_magnitude,
        LAG(quake_count) OVER (ORDER BY event_year)   AS prev_year_count,
        quake_count - LAG(quake_count) OVER (ORDER BY event_year) AS yoy_change
    FROM yearly)
SELECT
    event_year,
    quake_count,
    avg_magnitude,
    peak_magnitude,
    prev_year_count,
    yoy_change,
    ROUND(100.0 * yoy_change / NULLIF(prev_year_count, 0), 2) AS yoy_pct_change,
    CASE
        WHEN prev_year_count IS NULL THEN 'First year in range'
        WHEN event_year = 2026 THEN 'PARTIAL YEAR - do not compare'
        WHEN yoy_change > 0 THEN 'Increase'
        WHEN yoy_change < 0 THEN 'Decrease'
        ELSE 'Flat' END AS trend_label
FROM with_change
ORDER BY event_year;


-- Magnitude class distribution
WITH classified AS (
    SELECT
        CASE
            WHEN mag IS NULL THEN 'Unknown'
            WHEN mag <  4.0  THEN 'Minor (<4.0)'
            WHEN mag <  5.0  THEN 'Light (4.0-4.9)'
            WHEN mag <  6.0  THEN 'Moderate (5.0-5.9)'
            ELSE                  'Strong (6.0+)' END AS magnitude_class
    FROM earthquakes)
SELECT
    magnitude_class,
    COUNT(*) AS event_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total
FROM classified
GROUP BY magnitude_class
ORDER BY event_count DESC;

-- The ten strongest African earthquakes in the window
SELECT
    event_time,
    place,
    country_display AS country,
    mag,
    depth_km,
    magnitude_class
FROM earthquakes
WHERE event_time >= DATE '2010-01-01'
ORDER BY mag DESC
LIMIT 10;


-- Records with flagged error potential, you shouldn't fully trust
WITH evaluated AS (
    SELECT
        id,
        event_time,
        place,
        country_display AS country,
        mag,
        horizontalError,
        depthError,
        gap,
        flag_horizontal_error,
        flag_depth_error,
        flag_gap_over_180,
        any_measurement_flag,
        record_completeness_pct,
        COALESCE(horizontalError, 0) > 10.0 AS breach_horizontal,
        COALESCE(depthError, 0)      > 10.0 AS breach_depth,
        COALESCE(gap, 0)             > 180.0 AS breach_gap,
        CONCAT_WS(', ',
            CASE WHEN horizontalError IS NULL THEN 'horizontalError' END,
            CASE WHEN depthError IS NULL THEN 'depthError' END,
            CASE WHEN gap IS NULL THEN 'gap' END) AS checks_not_evaluable
    FROM earthquakes
)
SELECT
    id,
    event_time,
    place,
    country,
    mag,
    horizontalError,
    depthError,
    gap,
    flag_horizontal_error,
    flag_depth_error,
    flag_gap_over_180,
    any_measurement_flag,
    record_completeness_pct,
    NULLIF(checks_not_evaluable, '')AS checks_not_evaluable
FROM evaluated
WHERE breach_horizontal OR breach_depth OR breach_gap
ORDER BY COALESCE(horizontalError, 0) DESC, mag DESC;


-- Rolling 3-month average magnitude
WITH month_grid AS (
    SELECT DISTINCT event_year, event_month
    FROM earthquakes
),
monthly AS (
    SELECT
        g.event_year AS yr,
        g.event_month AS mo,
        COUNT(e.id) AS events_in_month,
        ROUND(AVG(e.mag), 3) AS avg_monthly_mag
    FROM month_grid g
    LEFT JOIN earthquakes e
           ON e.event_year = g.event_year
          AND e.event_month = g.event_month
    GROUP BY g.event_year, g.event_month)
SELECT
    yr,
    mo,
    events_in_month,
    avg_monthly_mag,
    ROUND(AVG(avg_monthly_mag) OVER (ORDER BY yr, mo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 3) AS rolling_3_month_avg,
    SUM(events_in_month) OVER (ORDER BY yr, mo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS events_in_3_month_window
FROM monthly
ORDER BY yr, mo;


-- Data quality summary
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN country_clean IS NULL THEN 1 ELSE 0 END) AS missing_country,
    ROUND(100.0 * SUM(CASE WHEN country_clean IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_missing_country,
    SUM(CASE WHEN location_type = 'Offshore' THEN 1 ELSE 0 END) AS offshore_events,
    SUM(CASE WHEN depth_km = 10.0 THEN 1 ELSE 0 END) AS default_depth_10km,
    ROUND(100.0 * SUM(CASE WHEN depth_km = 10.0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_default_depth,
    SUM(CASE WHEN any_measurement_flag = 'Yes' THEN 1 ELSE 0 END) AS low_quality_records,
    SUM(CASE WHEN any_measurement_flag = 'Incomplete data' THEN 1 ELSE 0 END) AS incomplete_records,
    ROUND(AVG(record_completeness_pct), 2) AS avg_completeness_pct
FROM earthquakes;


-- The genuinely severe events (magnitude >= 6.0), by year
SELECT
    event_year,
    COUNT(*) AS strong_events,
    MAX(mag) AS peak_magnitude,
    ROUND(AVG(depth_km), 1) AS avg_depth_km,
    STRING_AGG(DISTINCT country_display, ', ') AS countries
FROM earthquakes
WHERE mag >= 6.0
GROUP BY event_year
ORDER BY event_year;
