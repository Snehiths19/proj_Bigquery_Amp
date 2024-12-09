WITH

-- Aggregate measures
order_item_measures AS (
	SELECT
		order_id,
		SUM(item_sale_price) AS total_sale_price,
		SUM(product_cost) AS total_product_cost,
		SUM(item_profit) AS total_profit,
		SUM(item_discount) AS total_discount

	FROM {{ ref('int_ecommerce_order_items_products') }}
	GROUP BY 1
)

SELECT
	od.order_id,
	od.created_at AS order_created_at,
	od.shipped_at AS order_shipped_at,
	od.delivered_at AS order_delivered_at,
	od.returned_at AS order_returned_at,
	od.status AS order_status,
	om.total_discount,
	om.total_sale_price,
	om.total_product_cost,

	user_data.first_order_created_at,

	user_data.last_order_created_at as recency,
	od.num_items_ordered as frequency,
	om.total_profit as monetary,
	user_data.user_id,



	TIMESTAMP_DIFF(od.created_at, user_data.first_order_created_at, DAY) AS days_since_first_order

FROM {{ ref('stg_ecommerce_orders') }} AS od
LEFT JOIN order_item_measures AS om
	ON od.order_id = om.order_id
LEFT JOIN {{ ref('int_ecommerce_first_last_order_created') }} AS user_data
	ON od.user_id = user_data.user_id