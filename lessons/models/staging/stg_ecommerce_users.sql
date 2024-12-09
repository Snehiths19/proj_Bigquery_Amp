WITH source AS (
	SELECT *

	FROM {{ source('thelook_ecommerce', 'users') }}
)

SELECT
	-- IDs
	id AS user_id,

	-- Other columns
	age,
	gender,
	city,
	state,
	country,
	traffic_source,
	created_at

FROM source