WITH rfm_base AS (
    SELECT *,
        DATE_DIFF(CURRENT_DATE(), DATE(COALESCE(recency, TIMESTAMP '1970-01-01')), DAY) AS recency_days,
        COALESCE(frequency, 0) AS frequency_cleaned,
        COALESCE(monetary, 0) AS monetary_cleaned
    FROM {{ ref('dim_RFM_base') }}
),
rfm_scores AS (
    SELECT *,
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
    SELECT *,
        CAST(COALESCE(recency_score, 0) AS STRING) ||
        CAST(COALESCE(frequency_score, 0) AS STRING) ||
        CAST(COALESCE(monetary_score, 0) AS STRING) AS rfm_score
    FROM rfm_scores
),
rfm_segmented AS (
    SELECT *,
        CASE
            WHEN REGEXP_CONTAINS(rfm_score, r'^[1-2][1-2]') THEN 'hibernating'
            WHEN REGEXP_CONTAINS(rfm_score, r'^[1-2][3-4]') THEN 'at_Risk'
            WHEN REGEXP_CONTAINS(rfm_score, r'^[1-2]5') THEN 'cant_lose'
            WHEN REGEXP_CONTAINS(rfm_score, r'^3[1-2]') THEN 'about_to_sleep'
            WHEN rfm_score = '33' THEN 'need_attention'
            WHEN REGEXP_CONTAINS(rfm_score, r'^33[1-5]') THEN 'need_attention_plus'
            WHEN REGEXP_CONTAINS(rfm_score, r'^[3-4][4-5]') THEN 'loyal_customers'
            WHEN rfm_score = '41' THEN 'promising'
            WHEN REGEXP_CONTAINS(rfm_score, r'^41[1-5]') THEN 'promising_plus'
            WHEN rfm_score = '51' THEN 'new_customers'
            WHEN REGEXP_CONTAINS(rfm_score, r'^51[1-5]') THEN 'new_customers_plus'
            WHEN REGEXP_CONTAINS(rfm_score, r'^[4-5][2-3]') THEN 'potential_loyalists'
            WHEN REGEXP_CONTAINS(rfm_score, r'^5[4-5]') THEN 'champions'
            ELSE 'unclassified'
        END AS segment
    FROM rfm_combined
)
SELECT *,
    CASE
        WHEN segment = 'champions' THEN 1
        WHEN segment = 'loyal_customers' THEN 2
        WHEN segment = 'cant_lose' THEN 3
        WHEN segment = 'new_customers' THEN 4
        WHEN segment = 'new_customers_plus' THEN 5
        WHEN segment = 'potential_loyalists' THEN 6
        WHEN segment = 'promising' THEN 7
        WHEN segment = 'promising_plus' THEN 8
        WHEN segment = 'need_attention' THEN 9
        WHEN segment = 'need_attention_plus' THEN 10
        WHEN segment = 'about_to_sleep' THEN 11
        WHEN segment = 'at_Risk' THEN 12
        WHEN segment = 'hibernating' THEN 13
        ELSE 99 -- Catch-all for unclassified
    END AS priority
FROM rfm_segmented
