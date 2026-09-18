
-- SESSION SUMMARY SQL FILE

{{ config(
    materialized='table',
    tags=["analytics", "core"]
) }}

WITH user_sessions AS (
    SELECT * FROM {{ ref('user_session_channel') }}
),

session_times AS (
    SELECT * FROM {{ ref('session_timestamp') }}
),

combined_sessions AS (
    SELECT 
        us.session_id,
        us.user_id,
        us.username,
        us.email,
        us.country,
        us.device_type,
        us.channel,
        us.start_time,
        us.end_time,
        st.session_date,
        st.session_year,
        st.session_month,
        st.session_day_of_week,
        st.session_hour,
        st.session_week_id,
        st.session_duration_minutes,
        st.time_of_day,
        st.day_type
    FROM user_sessions us
    INNER JOIN session_times st 
        ON us.session_id = st.session_id
),

session_summary_agg AS (
    SELECT 
        session_id,
        user_id,
        username,
        email,
        country,
        device_type,
        channel,
        session_date,
        session_year,
        session_month,
        session_week_id,
        session_day_of_week,
        session_hour,
        time_of_day,
        day_type,
        start_time,
        end_time,
        session_duration_minutes,
        1 AS session_count,
        CASE WHEN session_duration_minutes > 0 THEN 1 ELSE 0 END AS active_session_flag
    FROM combined_sessions
    WHERE session_id IS NOT NULL
),

final AS (
    SELECT 
        session_id,
        user_id,
        username,
        email,
        country,
        device_type,
        channel,
        session_date,
        session_year,
        session_month,
        session_week_id,
        session_day_of_week,
        session_hour,
        time_of_day,
        day_type,
        start_time,
        end_time,
        session_duration_minutes,
        session_count,
        active_session_flag,
        CURRENT_TIMESTAMP() AS dbt_created_at,
        CURRENT_TIMESTAMP() AS dbt_updated_at
    FROM session_summary_agg
)

SELECT * FROM final
