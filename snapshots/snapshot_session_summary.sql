
-- SNAPSHOT SESSION SUMMARY SQL FILE 

{% snapshot snapshot_session_summary %}

    {% set build_incremental_logic = execute %}

    {{ config(
        target_schema='snapshots',
        unique_key='session_id',
        strategy='timestamp',
        updated_at='dbt_updated_at',
        tags=['snapshots', 'session_summary']
    ) }}

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
        dbt_created_at,
        dbt_updated_at
    FROM {{ ref('session_summary') }}

{% endsnapshot %}
