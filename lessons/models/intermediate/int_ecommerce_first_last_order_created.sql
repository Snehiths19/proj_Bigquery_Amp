{{
	config(materialized='ephemeral')
}}


SELECT
	user_id,
	MIN(created_at) AS first_order_created_at,
	MAX(created_at) AS last_order_created_at

FROM {{ ref('stg_ecommerce_orders') }}
WHERE order_id IS NOT NULL
GROUP BY 1