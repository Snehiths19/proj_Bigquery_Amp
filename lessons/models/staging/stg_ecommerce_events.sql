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
	age,
	gender,
	sequence_number,
	session_id,
	created_at,
	ip_address,
	city,
	state,
	country,
	postal_code,
	browser,
	traffic_source,
	uri AS web_link,
	event_type

FROM source

{% if is_incremental() %}

WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})

{% endif %}