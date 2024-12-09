WITH filtered_events AS (
    SELECT
        user_id,
        session_id,
        event_type,
        traffic_source,
        created_at
    FROM {{ ref('stg_ecommerce_events') }}
    WHERE event_type IN ('home', 'cart', 'department', 'product', 'purchase')
	AND user_id IS NOT NULL
),
rfm_segmentation AS (
    SELECT
        user_id,
        priority,
        order_created_at
    FROM {{ ref('RFM_Segmentation') }}
),
joined_data AS (
    SELECT
        fe.user_id,
        fe.session_id,
        fe.event_type,
        fe.traffic_source,
        fe.created_at,
        rs.priority,
        rs.order_created_at,
        ROW_NUMBER() OVER (
            PARTITION BY fe.user_id, fe.event_type, rs.order_created_at
            ORDER BY ABS(TIMESTAMP_DIFF(fe.created_at, rs.order_created_at, SECOND)) ASC
        ) AS join_rank -- Closest match by time difference
    FROM filtered_events fe
    LEFT JOIN rfm_segmentation rs
        ON fe.user_id = rs.user_id
        --AND fe.created_at <= rs.order_created_at
),
ranked_data AS (
    SELECT *
    FROM joined_data
    WHERE join_rank = 1 -- Keep only the closest match
)

SELECT
    rd.user_id,
    rd.session_id,
    rd.event_type,
    rd.traffic_source,
    rd.created_at,
    CASE
        WHEN rd.event_type = 'purchase' THEN 1
        ELSE 0
    END AS is_conversion,
    CASE
        WHEN rd.event_type = 'purchase' THEN rd.priority
        ELSE NULL
    END AS conversion_value
FROM ranked_data rd
ORDER BY rd.user_id, rd.created_at

