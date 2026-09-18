
-- USER SESSION SQL fILE 


{{ config(materialized='table') }}

WITH sessions AS (
    SELECT 
        session_id,
        user_id,
        start_time,
        end_time,
        device_type,
        referrer
    FROM {{ source('raw', 'sessions') }}
    WHERE start_time IS NOT NULL
),

users AS (
    SELECT 
        user_id,
        username,
        email,
        signup_date,
        country
    FROM {{ source('raw', 'users') }}
),

session_with_channel AS (
    SELECT 
        s.session_id,
        s.user_id,
        u.username,
        u.email,
        u.country,
        s.device_type,
        CASE 
            WHEN LOWER(s.referrer) LIKE '%google%' THEN 'organic_search'
            WHEN LOWER(s.referrer) LIKE '%facebook%' THEN 'social'
            WHEN LOWER(s.referrer) LIKE '%direct%' THEN 'direct'
            ELSE 'other'
        END AS channel,
        s.start_time,
        s.end_time
    FROM sessions s
    LEFT JOIN users u ON s.user_id = u.user_id
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
        start_time,
        end_time,
        CURRENT_TIMESTAMP() AS dbt_created_at
    FROM session_with_channel
    WHERE session_id IS NOT NULL
)

SELECT * FROM final


