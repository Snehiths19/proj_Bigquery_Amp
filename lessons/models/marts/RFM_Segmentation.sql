WITH rfm_base AS (
    SELECT
        *,
        DATE_DIFF(CURRENT_DATE(), DATE(COALESCE(recency, TIMESTAMP '1970-01-01')), DAY) AS recency_days,
        COALESCE(frequency, 0) AS frequency_cleaned,
        COALESCE(monetary, 0) AS monetary_cleaned
    FROM {{ ref('dim_RFM_base') }}
),
rfm_scores AS (
    SELECT
        *,
        CASE
            WHEN recency_days <= 30 THEN 5
            WHEN recency_days <= 90 THEN 4
            WHEN recency_days <= 180 THEN 3
            WHEN recency_days <= 365 THEN 2
            ELSE 1
        END AS recency_score,
        NTILE(5) OVER (ORDER BY frequency_cleaned DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_cleaned DESC) AS monetary_score
    FROM rfm_base
),
rfm_combined AS (
    SELECT
        *,
        CAST(COALESCE(recency_score, 0) AS STRING)
        || CAST(COALESCE(frequency_score, 0) AS STRING)
        || CAST(COALESCE(monetary_score, 0) AS STRING) AS rfm_score
    FROM rfm_scores
)

-- Segment + priority come from the rfm_segments seed (single source of truth).
-- The seed's unique_combination_of_columns test guarantees this LEFT JOIN
-- yields exactly one match per row (no fan-out, no nulls if coverage is full).
SELECT
    c.*,
    COALESCE(s.segment, 'unclassified') AS segment,
    COALESCE(s.priority, 99) AS priority
FROM rfm_combined AS c
LEFT JOIN {{ ref('rfm_segments') }} AS s
    ON
        c.recency_score BETWEEN s.r_min AND s.r_max
        AND c.frequency_score BETWEEN s.f_min AND s.f_max
        AND c.monetary_score BETWEEN s.m_min AND s.m_max
