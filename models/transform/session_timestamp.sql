
-- SESSION TIMESTAMP SQL fILE 

{{ config(materialized='table') }}

WITH sessions AS (
    SELECT 
        session_id,
        user_id,
        start_time,
        end_time
    FROM {{ source('raw', 'sessions') }}
    WHERE start_time IS NOT NULL
),

timestamps_transformed AS (
    SELECT 
        session_id,
        user_id,
        start_time,
        end_time,
        DATE(start_time) AS session_date,
        YEAR(start_time) AS session_year,
        MONTH(start_time) AS session_month,
        DAYOFWEEK(start_time) AS session_day_of_week,
        HOUR(start_time) AS session_hour,
        DATEDIFF(MINUTE, start_time, end_time) AS session_duration_minutes,
        CONCAT(YEAR(start_time), '-W', LPAD(WEEK(start_time), 2, '0')) AS session_week_id
    FROM sessions
),

sessions_with_labels AS (
    SELECT 
        *,
        CASE 
            WHEN session_hour BETWEEN 6 AND 11 THEN 'morning'
            WHEN session_hour BETWEEN 12 AND 17 THEN 'afternoon'
            WHEN session_hour BETWEEN 18 AND 23 THEN 'evening'
            ELSE 'night'
        END AS time_of_day,
        CASE 
            WHEN session_day_of_week IN (1, 7) THEN 'weekend'
            ELSE 'weekday'
        END AS day_type
    FROM timestamps_transformed
),

final AS (
    SELECT 
        session_id,
        user_id,
        start_time,
        end_time,
        session_date,
        session_year,
        session_month,
        session_day_of_week,
        session_hour,
        session_week_id,
        session_duration_minutes,
        time_of_day,
        day_type
    FROM sessions_with_labels
)

SELECT * FROM final
