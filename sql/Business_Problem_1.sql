/* ============================================================
   BUSINESS QUESTION 1
   What factors drive content engagement and popularity?
   
   Objective:
   Identify the content, category, channel, timing and
   description characteristics associated with stronger
   audience engagement and content reach.
   ============================================================ */


/* ============================================================
   SECTION 1 — DATA QUALITY & BASELINE VALIDATION
   ============================================================ */

-- Q1.0.1 — Overall content performance baseline

SELECT
    COUNT(*) AS total_videos,
    SUM(views) AS total_views,
    ROUND(AVG(views), 2) AS avg_views,
    SUM(likes) AS total_likes,
    SUM(comments) AS total_comments,
    SUM(dislikes) AS total_dislikes,
    ROUND(AVG(engagement_rate), 4) AS avg_engagement_rate,
    ROUND(AVG(like_ratio), 4) AS avg_like_ratio,
    ROUND(AVG(dislike_ratio), 4) AS avg_dislike_ratio
FROM videos_fact;


-- Q1.0.2 — Validate dislike distribution

SELECT
    MIN(dislikes) AS min_dislikes,
    MAX(dislikes) AS max_dislikes,
    SUM(dislikes) AS total_dislikes,
    COUNT(*) FILTER (
        WHERE dislikes > 0
    ) AS videos_with_dislikes
FROM videos_fact;


-- Q1.0.3 — Validate metric ranges

SELECT
    MIN(views) AS min_views,
    MAX(views) AS max_views,
    MIN(likes) AS min_likes,
    MAX(likes) AS max_likes,
    MIN(comments) AS min_comments,
    MAX(comments) AS max_comments
FROM videos_fact;


-- Q1.0.4 — Check missing/invalid analytical metrics

SELECT
    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE views = 0
    ) AS zero_view_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate IS NULL
    ) AS null_engagement,

    COUNT(*) FILTER (
        WHERE like_ratio IS NULL
    ) AS null_like_ratio

FROM videos_fact;


/* ============================================================
   SECTION 2 — CATEGORY PERFORMANCE
   ============================================================ */

-- Q1.1 — Which categories demonstrate consistently strong
-- engagement and reach while accounting for content volume?

SELECT
    category_name,
    COUNT(*) AS total_videos,
    SUM(views) AS total_views,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views_per_video,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY views)::numeric,
        2
    ) AS median_views,

    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,

    ROUND(
        AVG(like_ratio)::numeric,
        4
    ) AS avg_like_ratio,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend

FROM videos_fact

WHERE views > 0

GROUP BY category_name

ORDER BY total_videos DESC;


/* ============================================================
   SECTION 3 — CHANNEL PERFORMANCE
   ============================================================ */

-- Q1.2 — Which channels consistently generate strong
-- audience reach and engagement?

SELECT
    channel_title,
    COUNT(*) AS total_videos,
    SUM(views) AS total_views,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views_per_video,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY views)::numeric,
        2
    ) AS median_views,

    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,

    ROUND(
        AVG(like_ratio)::numeric,
        4
    ) AS avg_like_ratio,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend

FROM videos_fact

WHERE views > 0

GROUP BY channel_title

HAVING COUNT(*) >= 5

ORDER BY avg_engagement_rate DESC;


-- Q1.2.1 — Investigate extreme channel-level result
-- Used as an analytical validation query.

SELECT
    video_id,
    views,
    likes,
    comments,
    engagement_rate,
    like_ratio

FROM videos_fact

WHERE channel_title = 'Gorillaz'

ORDER BY engagement_rate DESC

LIMIT 10;


-- Q1.2.2 — Validate engagement-rate outliers

SELECT
    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate > 1
    ) AS engagement_over_100_pct,

    COUNT(*) FILTER (
        WHERE engagement_rate > 0.5
    ) AS engagement_over_50_pct,

    COUNT(*) FILTER (
        WHERE engagement_rate > 0.2
    ) AS engagement_over_20_pct,

    ROUND(
        MAX(engagement_rate)::numeric,
        4
    ) AS maximum_engagement_rate

FROM videos_fact

WHERE views > 0;


-- Q1.2.3 — Robust channel-level engagement analysis
-- Uses median engagement and minimum view threshold.

SELECT
    channel_title,
    COUNT(*) AS total_videos,

    SUM(views) AS total_views,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views_per_video,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY views)::numeric,
        2
    ) AS median_views,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY engagement_rate)::numeric,
        4
    ) AS median_engagement_rate,

    ROUND(
        AVG(engagement_rate)
        FILTER (WHERE views >= 1000)::numeric,
        4
    ) AS avg_engagement_1000_views,

    ROUND(
        AVG(like_ratio)
        FILTER (WHERE views >= 1000)::numeric,
        4
    ) AS avg_like_ratio_1000_views,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend

FROM videos_fact

WHERE views > 0

GROUP BY channel_title

HAVING COUNT(*) >= 5

ORDER BY median_engagement_rate DESC;


/* ============================================================
   SECTION 4 — HIGH-ENGAGEMENT CONTENT
   ============================================================ */

-- Q1.3 — Define high engagement threshold
-- 75th percentile among videos with at least 1,000 views.

SELECT
    ROUND(
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        )::numeric,
        4
    ) AS high_engagement_threshold

FROM videos_fact

WHERE views >= 1000;


/* ============================================================
   SECTION 5 — CATEGORY VS HIGH ENGAGEMENT
   ============================================================ */

-- Q1.3.1 — Which categories have a higher proportion
-- of high-engagement content?

WITH threshold AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS p75

    FROM videos_fact

    WHERE views >= 1000
)

SELECT
    category_name,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate >= threshold.p75
    ) AS high_engagement_videos,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE engagement_rate >= threshold.p75
            )::numeric
            / COUNT(*)
        ) * 100,
        2
    ) AS high_engagement_percentage,

    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views

FROM videos_fact

CROSS JOIN threshold

WHERE views >= 1000

GROUP BY category_name

ORDER BY high_engagement_percentage DESC;


/* ============================================================
   SECTION 6 — PUBLISHING TIMING
   ============================================================ */

-- Q1.4 — Does upload timing influence high engagement?

WITH threshold AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS p75

    FROM videos_fact

    WHERE views >= 1000
)

SELECT
    publish_hour,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate >= threshold.p75
    ) AS high_engagement_videos,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE engagement_rate >= threshold.p75
            )::numeric
            / COUNT(*)
        ) * 100,
        2
    ) AS high_engagement_percentage,

    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend

FROM videos_fact

CROSS JOIN threshold

WHERE views >= 1000

GROUP BY publish_hour

ORDER BY high_engagement_percentage DESC;


-- Q1.4.1 — Weekday vs Weekend performance

WITH threshold AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS p75

    FROM videos_fact

    WHERE views >= 1000
)

SELECT
    CASE
        WHEN weekend_flag = TRUE
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS upload_period,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate >= threshold.p75
    ) AS high_engagement_videos,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE engagement_rate >= threshold.p75
            )::numeric
            / COUNT(*)
        ) * 100,
        2
    ) AS high_engagement_percentage,

    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend

FROM videos_fact

CROSS JOIN threshold

WHERE views >= 1000

GROUP BY weekend_flag

ORDER BY avg_engagement_rate DESC;


/* ============================================================
   SECTION 7 — DESCRIPTION ANALYSIS
   ============================================================ */

-- Q1.5 — Does description presence relate to engagement?

WITH threshold AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS p75

    FROM videos_fact

    WHERE views >= 1000
)

SELECT
    CASE
        WHEN has_description = TRUE
            THEN 'Has Description'
        ELSE 'No Description'
    END AS description_status,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate >= threshold.p75
    ) AS high_engagement_videos,

    ROUND(
        COUNT(*) FILTER (
            WHERE engagement_rate >= threshold.p75
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS high_engagement_percentage,

    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend

FROM videos_fact

CROSS JOIN threshold

WHERE views >= 1000

GROUP BY has_description

ORDER BY avg_engagement_rate DESC;


-- Q1.5.1 — Description length vs engagement

WITH threshold AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS p75

    FROM videos_fact

    WHERE views >= 1000
),

description_groups AS (

    SELECT
        *,
        CASE
            WHEN description_length <= 50
                THEN 'Short (0-50)'

            WHEN description_length <= 150
                THEN 'Medium (51-150)'

            WHEN description_length <= 300
                THEN 'Long (151-300)'

            ELSE 'Very Long (300+)'

        END AS description_group

    FROM videos_fact

    WHERE views >= 1000
      AND has_description = TRUE
)

SELECT
    description_group,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate >= threshold.p75
    ) AS high_engagement_videos,

    ROUND(
        COUNT(*) FILTER (
            WHERE engagement_rate >= threshold.p75
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS high_engagement_percentage,

    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend

FROM description_groups

CROSS JOIN threshold

GROUP BY description_group

ORDER BY
    CASE description_group
        WHEN 'Short (0-50)' THEN 1
        WHEN 'Medium (51-150)' THEN 2
        WHEN 'Long (151-300)' THEN 3
        WHEN 'Very Long (300+)' THEN 4
    END;


/* ============================================================
   SECTION 8 — ENGAGEMENT VS TRENDING SPEED
   ============================================================ */

-- Q1.6 — Does high engagement correspond with faster trending?

WITH threshold AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS p75

    FROM videos_fact

    WHERE views >= 1000
)

SELECT
    CASE
        WHEN engagement_rate >= threshold.p75
            THEN 'High Engagement'
        ELSE 'Other Videos'
    END AS engagement_group,

    COUNT(*) AS total_videos,

    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY time_to_trend
        )::numeric,
        2
    ) AS median_time_to_trend,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend

FROM videos_fact

CROSS JOIN threshold

WHERE views >= 1000

GROUP BY
    CASE
        WHEN engagement_rate >= threshold.p75
            THEN 'High Engagement'
        ELSE 'Other Videos'
    END

ORDER BY avg_engagement_rate DESC;


/* ============================================================
   SECTION 9 — FINAL BUSINESS FINDINGS
   ============================================================

   Q1 FINDINGS

   1. Category performance varies substantially.
      Comedy, Travel & Events, Howto & Style, News & Politics,
      and Science & Technology showed relatively strong
      engagement characteristics in the analyzed dataset.
      Small categories should be interpreted cautiously.

   2. Channel-level engagement rankings can be distorted by
      extreme observations. The Gorillaz investigation showed
      why median engagement and minimum-view thresholds provide
      a more robust comparison than relying solely on averages.

   3. Publishing timing showed measurable differences in
      engagement performance. Weekday uploads produced a higher
      high-engagement rate and higher average engagement/reach
      than weekend uploads in this dataset.

   4. Description presence alone did not indicate better
      engagement. However, description length showed a
      non-linear relationship with performance.

   5. Short descriptions (0–50 characters) showed the strongest
      engagement performance among videos with descriptions.

   6. High-engagement videos had an average time-to-trend of
      approximately 346 hours compared with 442 hours for other
      videos, indicating an association between stronger
      engagement and faster trending.

   7. Reach and engagement are not identical measures of
      content success. Some groups generated substantially
      higher views without necessarily having the highest
      engagement rate.

   IMPORTANT:
   These findings represent associations in the analyzed dataset.
   They should not be interpreted as causal relationships.
   ============================================================ */