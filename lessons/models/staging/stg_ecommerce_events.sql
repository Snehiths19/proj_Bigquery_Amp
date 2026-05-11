{{
	config(
		materialized='incremental',
		unique_key='event_id',
		on_schema_change='sync_all_changes',
		partition_by={
			"field": "created_at",
			"data_type": "timestamp",
			"granularity": "day"
		}
	)
}}

WITH source AS (
    SELECT *

    FROM {{ source('thelook_ecommerce', 'events') }}
)

SELECT
    id AS event_id,
    user_id,
    sequence_number,
    session_id,
    created_at,
    ip_address,
    city,
    state,
    postal_code,
    browser,
    traffic_source,
    uri AS web_link,
    event_type

FROM source

{% if is_incremental() %}

-- Overlap window: rescan the last N days of source data on every incremental run.
-- The model's unique_key='event_id' makes the merge dedupe duplicates, so the
-- only effect is to pick up same-timestamp and late-arriving events that a
-- strict-greater-than boundary would silently drop. N is tunable via the
-- `incremental_lookback_days` var (default 3, set in dbt_project.yml).
WHERE
    source.created_at >= TIMESTAMP_SUB(
        (SELECT MAX(created_at) FROM {{ this }}), -- noqa: RF02
        INTERVAL {{ var('incremental_lookback_days', 3) }} DAY
    )

{% endif %}
