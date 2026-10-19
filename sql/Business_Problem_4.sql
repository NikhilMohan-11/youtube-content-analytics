/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.1 — DEFINE HIGH-POTENTIAL CONTENT
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
),

classified AS (

    SELECT
        v.engagement_rate,
        b.high_potential_threshold,

        CASE
            WHEN v.engagement_rate >= b.high_potential_threshold
                THEN 'High Potential'
            ELSE 'Normal Potential'
        END AS potential_group

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE v.views >= 1000
)

SELECT
    potential_group,

    COUNT(*) AS total_videos,

    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS percentage_of_videos,

    ROUND(
        MIN(engagement_rate)::numeric * 100,
        4
    ) AS min_engagement_percentage,

    ROUND(
        AVG(engagement_rate)::numeric * 100,
        4
    ) AS avg_engagement_percentage,

    ROUND(
        MAX(engagement_rate)::numeric * 100,
        4
    ) AS max_engagement_percentage

FROM classified

GROUP BY potential_group

ORDER BY
    CASE potential_group
        WHEN 'High Potential' THEN 1
        ELSE 2
    END;

/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.2 — HIGH-POTENTIAL CONTENT PROFILE
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
),

classified AS (

    SELECT
        v.category_id,
        v.publish_hour,
        v.weekend_flag,
        v.has_description,
        v.description_length,
        v.engagement_rate,

        CASE
            WHEN v.engagement_rate >= b.high_potential_threshold
                THEN 'High Potential'
            ELSE 'Normal Potential'
        END AS potential_group

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE v.views >= 1000
)

SELECT
    potential_group,

    COUNT(*) AS total_videos,

    ROUND(
        AVG(engagement_rate)::numeric * 100,
        4
    ) AS avg_engagement_percentage,

    ROUND(
        AVG(publish_hour)::numeric,
        2
    ) AS avg_publish_hour,

    ROUND(
        AVG(description_length)::numeric,
        2
    ) AS avg_description_length,

    ROUND(
        COUNT(*) FILTER (
            WHERE weekend_flag = TRUE
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS weekend_publish_percentage,

    ROUND(
        COUNT(*) FILTER (
            WHERE has_description = TRUE
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS description_present_percentage

FROM classified

GROUP BY potential_group

ORDER BY
    CASE potential_group
        WHEN 'High Potential' THEN 1
        ELSE 2
    END;

/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.3 — HIGH-POTENTIAL RATE BY CATEGORY
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
),

category_analysis AS (

    SELECT
        category_id,

        COUNT(*) AS total_videos,

        COUNT(*) FILTER (
            WHERE engagement_rate >= b.high_potential_threshold
        ) AS high_potential_videos

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE views >= 1000

    GROUP BY category_id
)

SELECT
    category_id,

    total_videos,

    high_potential_videos,

    ROUND(
        high_potential_videos::numeric
        / total_videos * 100,
        2
    ) AS high_potential_rate_percentage

FROM category_analysis

ORDER BY
    high_potential_rate_percentage DESC;

/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.4 — HIGH-POTENTIAL RATE BY PUBLISHING HOUR
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
),

hour_analysis AS (

    SELECT
        publish_hour,

        COUNT(*) AS total_videos,

        COUNT(*) FILTER (
            WHERE engagement_rate >= b.high_potential_threshold
        ) AS high_potential_videos

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE views >= 1000

    GROUP BY publish_hour
)

SELECT
    publish_hour,

    total_videos,

    high_potential_videos,

    ROUND(
        high_potential_videos::numeric
        / total_videos * 100,
        2
    ) AS high_potential_rate_percentage

FROM hour_analysis

ORDER BY
    publish_hour;

/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.5 — HIGH-POTENTIAL RATE BY DESCRIPTION LENGTH
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
),

classified AS (

    SELECT

        CASE
            WHEN description_length <= 50
                THEN '1-50 Characters'

            WHEN description_length <= 150
                THEN '51-150 Characters'

            WHEN description_length <= 300
                THEN '151-300 Characters'

            ELSE '301+ Characters'
        END AS description_group,

        engagement_rate,
        b.high_potential_threshold

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE views >= 1000
)

SELECT

    description_group,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate >= high_potential_threshold
    ) AS high_potential_videos,

    ROUND(
        COUNT(*) FILTER (
            WHERE engagement_rate >= high_potential_threshold
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS high_potential_rate_percentage,

    ROUND(
        AVG(engagement_rate)::numeric * 100,
        4
    ) AS avg_engagement_percentage

FROM classified

GROUP BY description_group

ORDER BY
    CASE description_group
        WHEN '1-50 Characters' THEN 1
        WHEN '51-150 Characters' THEN 2
        WHEN '151-300 Characters' THEN 3
        WHEN '301+ Characters' THEN 4
    END;

/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.6 — HIGH-POTENTIAL RATE BY TIME-TO-TREND
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
),

classified AS (

    SELECT

        CASE
            WHEN time_to_trend < 24
                THEN '<24 Hours'

            WHEN time_to_trend < 72
                THEN '24-72 Hours'

            WHEN time_to_trend < 168
                THEN '3-7 Days'

            ELSE '>7 Days'
        END AS trend_speed_group,

        engagement_rate,
        b.high_potential_threshold

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE views >= 1000
      AND time_to_trend IS NOT NULL
)

SELECT

    trend_speed_group,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate >= high_potential_threshold
    ) AS high_potential_videos,

    ROUND(
        COUNT(*) FILTER (
            WHERE engagement_rate >= high_potential_threshold
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS high_potential_rate_percentage,

    ROUND(
        AVG(engagement_rate)::numeric * 100,
        4
    ) AS avg_engagement_percentage

FROM classified

GROUP BY trend_speed_group

ORDER BY
    CASE trend_speed_group
        WHEN '<24 Hours' THEN 1
        WHEN '24-72 Hours' THEN 2
        WHEN '3-7 Days' THEN 3
        WHEN '>7 Days' THEN 4
    END;

/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.7 — CREATE ML-READY DATASET
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
)

SELECT

    video_id,

    category_id,

    publish_hour,

    publish_day,

    weekend_flag,

    has_description,

    description_length,

    CASE
        WHEN engagement_rate >= b.high_potential_threshold
            THEN 1
        ELSE 0
    END AS high_potential

FROM videos_fact v

CROSS JOIN benchmark b

WHERE views >= 1000

ORDER BY video_id;

/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.8 — ML DATASET VALIDATION
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
),

ml_dataset AS (

    SELECT
        video_id,
        category_id,
        publish_hour,
        publish_day,
        weekend_flag,
        has_description,
        description_length,

        CASE
            WHEN engagement_rate >= b.high_potential_threshold
                THEN 1
            ELSE 0
        END AS high_potential

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE views >= 1000
)

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT video_id) AS unique_videos,

    COUNT(*) - COUNT(DISTINCT video_id) AS duplicate_rows,

    COUNT(*) FILTER (
        WHERE category_id IS NULL
    ) AS null_category,

    COUNT(*) FILTER (
        WHERE publish_hour IS NULL
    ) AS null_publish_hour,

    COUNT(*) FILTER (
        WHERE publish_day IS NULL
    ) AS null_publish_day,

    COUNT(*) FILTER (
        WHERE weekend_flag IS NULL
    ) AS null_weekend_flag,

    COUNT(*) FILTER (
        WHERE has_description IS NULL
    ) AS null_has_description,

    COUNT(*) FILTER (
        WHERE description_length IS NULL
    ) AS null_description_length,

    COUNT(*) FILTER (
        WHERE high_potential = 1
    ) AS high_potential_count,

    COUNT(*) FILTER (
        WHERE high_potential = 0
    ) AS normal_potential_count,

    ROUND(
        COUNT(*) FILTER (
            WHERE high_potential = 1
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS high_potential_percentage

FROM ml_dataset;

/* ============================================================
   BUSINESS PROBLEM 4 — HIGH-POTENTIAL CONTENT
   Q4.9 — CREATE FINAL ML DATASET TABLE
   ============================================================ */

DROP TABLE IF EXISTS ml_high_potential;

CREATE TABLE ml_high_potential AS

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS high_potential_threshold

    FROM videos_fact

    WHERE views >= 1000
)

SELECT

    video_id,

    category_id,

    publish_hour,

    publish_day,

    weekend_flag,

    has_description,

    description_length,

    CASE
        WHEN engagement_rate >= b.high_potential_threshold
            THEN 1
        ELSE 0
    END AS high_potential

FROM videos_fact v

CROSS JOIN benchmark b

WHERE views >= 1000;

SELECT *
FROM ml_high_potential
LIMIT 10;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT video_id) AS unique_videos,
    COUNT(*) FILTER (WHERE high_potential = 1) AS high_potential,
    COUNT(*) FILTER (WHERE high_potential = 0) AS normal_potential
FROM ml_high_potential;