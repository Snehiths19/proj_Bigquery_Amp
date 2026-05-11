WITH base_events AS (
    SELECT
        user_id,
        session_id,
        event_type,
        traffic_source,
        created_at,
        is_conversion,
        conversion_value
    FROM {{ ref('Attribution_base') }}
)

SELECT
    event_type,
    JSON_OBJECT(
        "traffic_source", traffic_source,
        "is_conversion", is_conversion,
        "conversion_value", conversion_value,
        "session_id", session_id
    ) AS event_properties, -- Create event_properties as JSON
    -- Amplitude's ingestion API requires this exact column name ('time').
    UNIX_MILLIS(created_at) AS time, -- noqa: RF04
    created_at, -- Use as cursor timestamp
    user_id
FROM base_events
