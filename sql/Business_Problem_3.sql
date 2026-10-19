/* ============================================================
   BP3 — DECLINING ENGAGEMENT
   Q3.0 — ENGAGEMENT DECLINE BASELINE
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS median_engagement_rate

    FROM videos_fact

    WHERE views >= 1000
)

SELECT

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate < b.median_engagement_rate
    ) AS below_median_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate >= b.median_engagement_rate
    ) AS above_median_videos,

    ROUND(
        b.median_engagement_rate::numeric * 100,
        4
    ) AS median_engagement_percentage,

    ROUND(
        AVG(v.engagement_rate)::numeric * 100,
        4
    ) AS overall_avg_engagement_percentage,

    ROUND(
        AVG(v.views)::numeric,
        2
    ) AS avg_views_per_video

FROM videos_fact v

CROSS JOIN benchmark b

WHERE v.views >= 1000

GROUP BY b.median_engagement_rate;


/* ============================================================
   BP3 — Q3.1
   CATEGORY ASSOCIATION WITH DECLINING ENGAGEMENT
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS median_engagement_rate

    FROM videos_fact

    WHERE views >= 1000
),

category_analysis AS (

    SELECT
        v.category_name,

        COUNT(*) AS total_videos,

        COUNT(*) FILTER (
            WHERE v.engagement_rate < b.median_engagement_rate
        ) AS low_engagement_videos,

        ROUND(
            COUNT(*) FILTER (
                WHERE v.engagement_rate < b.median_engagement_rate
            )::numeric
            / COUNT(*) * 100,
            2
        ) AS low_engagement_percentage,

        ROUND(
            AVG(v.engagement_rate)::numeric * 100,
            4
        ) AS avg_engagement_percentage,

        ROUND(
            PERCENTILE_CONT(0.50)
            WITHIN GROUP (
                ORDER BY v.engagement_rate
            )::numeric * 100,
            4
        ) AS median_engagement_percentage

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE v.views >= 1000

    GROUP BY v.category_name
)

SELECT
    category_name,
    total_videos,
    low_engagement_videos,
    low_engagement_percentage,
    avg_engagement_percentage,
    median_engagement_percentage,

    ROUND(
        (
            low_engagement_percentage
            -
            50.00
        )::numeric,
        2
    ) AS difference_from_expected_pct_points

FROM category_analysis

ORDER BY low_engagement_percentage DESC;


/* ============================================================
   BP3 — Q3.2
   REACH / VIEWS VS DECLINING ENGAGEMENT
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS median_engagement_rate

    FROM videos_fact

    WHERE views >= 1000
),

classified AS (

    SELECT
        v.views,
        v.likes,
        v.comments,
        v.engagement_rate,

        CASE
            WHEN v.engagement_rate < b.median_engagement_rate
                THEN 'Below Median Engagement'
            ELSE 'Above/At Median Engagement'
        END AS engagement_group

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE v.views >= 1000
)

SELECT

    engagement_group,

    COUNT(*) AS total_videos,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY views
        )::numeric,
        2
    ) AS median_views,

    ROUND(
        AVG(likes)::numeric,
        2
    ) AS avg_likes,

    ROUND(
        AVG(comments)::numeric,
        2
    ) AS avg_comments,

    ROUND(
        AVG(engagement_rate)::numeric * 100,
        4
    ) AS avg_engagement_percentage

FROM classified

GROUP BY engagement_group

ORDER BY engagement_group;


/* ============================================================
   BP3 — Q3.3
   PUBLISHING TIME VS DECLINING ENGAGEMENT
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS median_engagement_rate

    FROM videos_fact

    WHERE views >= 1000
),

hourly_analysis AS (

    SELECT
        publish_hour,

        COUNT(*) AS total_videos,

        COUNT(*) FILTER (
            WHERE engagement_rate < b.median_engagement_rate
        ) AS low_engagement_videos,

        ROUND(
            COUNT(*) FILTER (
                WHERE engagement_rate < b.median_engagement_rate
            )::numeric
            / COUNT(*) * 100,
            2
        ) AS low_engagement_percentage,

        ROUND(
            AVG(engagement_rate)::numeric * 100,
            4
        ) AS avg_engagement_percentage,

        ROUND(
            PERCENTILE_CONT(0.50)
            WITHIN GROUP (
                ORDER BY engagement_rate
            )::numeric * 100,
            4
        ) AS median_engagement_percentage

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE views >= 1000

    GROUP BY publish_hour
)

SELECT
    publish_hour,
    total_videos,
    low_engagement_videos,
    low_engagement_percentage,
    avg_engagement_percentage,
    median_engagement_percentage,

    ROUND(
        (
            low_engagement_percentage - 50.00
        )::numeric,
        2
    ) AS difference_from_expected_pct_points

FROM hourly_analysis

ORDER BY low_engagement_percentage DESC;


/* ============================================================
   BP3 — Q3.4
   DESCRIPTION CHARACTERISTICS VS DECLINING ENGAGEMENT
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS median_engagement_rate

    FROM videos_fact

    WHERE views >= 1000
),

classified AS (

    SELECT
        v.description_length,

        CASE
            WHEN v.description_length = 0
                THEN 'No Description'

            WHEN v.description_length BETWEEN 1 AND 50
                THEN '1-50 Characters'

            WHEN v.description_length BETWEEN 51 AND 150
                THEN '51-150 Characters'

            WHEN v.description_length BETWEEN 151 AND 300
                THEN '151-300 Characters'

            ELSE '301+ Characters'
        END AS description_group,

        v.engagement_rate,
        b.median_engagement_rate

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE v.views >= 1000
)

SELECT
    description_group,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate < median_engagement_rate
    ) AS low_engagement_videos,

    ROUND(
        COUNT(*) FILTER (
            WHERE engagement_rate < median_engagement_rate
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS low_engagement_percentage,

    ROUND(
        AVG(engagement_rate)::numeric * 100,
        4
    ) AS avg_engagement_percentage,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY engagement_rate
        )::numeric * 100,
        4
    ) AS median_engagement_percentage

FROM classified

GROUP BY description_group

ORDER BY low_engagement_percentage DESC;


/* ============================================================
   BP3 — Q3.5
   TIME-TO-TREND VS DECLINING ENGAGEMENT
   ============================================================ */

WITH benchmark AS (

    SELECT
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY engagement_rate
        ) AS median_engagement_rate

    FROM videos_fact

    WHERE views >= 1000
),

classified AS (

    SELECT
        v.time_to_trend,
        v.engagement_rate,
        b.median_engagement_rate,

        CASE
            WHEN v.time_to_trend < 24
                THEN '<24 Hours'

            WHEN v.time_to_trend < 72
                THEN '24-72 Hours'

            WHEN v.time_to_trend < 168
                THEN '3-7 Days'

            ELSE '>7 Days'
        END AS trend_speed_group

    FROM videos_fact v

    CROSS JOIN benchmark b

    WHERE v.views >= 1000
      AND v.time_to_trend IS NOT NULL
      AND v.time_to_trend >= 0
)

SELECT
    trend_speed_group,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE engagement_rate < median_engagement_rate
    ) AS low_engagement_videos,

    ROUND(
        COUNT(*) FILTER (
            WHERE engagement_rate < median_engagement_rate
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS low_engagement_percentage,

    ROUND(
        AVG(time_to_trend)::numeric,
        2
    ) AS avg_time_to_trend_hours,

    ROUND(
        AVG(engagement_rate)::numeric * 100,
        4
    ) AS avg_engagement_percentage,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY engagement_rate
        )::numeric * 100,
        4
    ) AS median_engagement_percentage

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
   SECTION 9 — FINAL BUSINESS FINDINGS
   ============================================================

   Q3 FINDINGS

   1. Certain content categories were more strongly associated
      with declining engagement.

      Entertainment had the highest proportion of below-median
      engagement among the major categories, with 62.33% of
      analyzed videos falling below the 2.8703% median benchmark.

      Music also showed elevated below-median engagement at
      55.01%. In contrast, Gaming had 46.52%, indicating that
      its relatively lower engagement efficiency did not translate
      into a disproportionately high share of low-engagement
      videos.

   2. High reach does not necessarily indicate strong audience
      engagement.

      Videos below the median engagement benchmark generated an
      average of approximately 2.43 million views compared with
      1.17 million views for videos at or above the benchmark.

      However, their median views were relatively similar
      (255K vs. 242K), indicating that extreme high-view videos
      contributed substantially to the difference in average reach.

      This suggests that viral reach and audience interaction
      should be evaluated as separate performance dimensions.

   3. Publishing time showed measurable differences in the
      likelihood of declining engagement.

      Videos published at 08:00 had the highest proportion of
      below-median engagement at 73.10%, followed by 04:00
      (69.01%) and 05:00 (66.49%).

      Several high-volume hours also showed elevated risk.
      For example, 20:00 had 1,372 analyzed videos, with 57.00%
      falling below the median engagement benchmark.

      Publishing time therefore appears to be an important
      factor associated with engagement performance in this
      dataset.

   4. Description length showed a clear association with
      declining engagement.

      Long descriptions were more frequently associated with
      below-median engagement.

      Videos with descriptions longer than 300 characters had
      54.22% below-median engagement, while the 151–300 character
      group had the highest rate at 56.82%.

      In comparison, only 36.10% of videos with short
      1–50 character descriptions were below the median.

   5. Faster trending was associated with stronger engagement.

      Videos that reached trending status within 24 hours had
      only 35.74% below-median engagement and a median engagement
      rate of 3.7049%.

      In contrast, videos taking 3–7 days to trend had the highest
      below-median rate at 63.48%, with a median engagement rate
      of only 2.1797%.

      This indicates that faster content traction is associated
      with stronger audience interaction.

   6. The relationship between time-to-trend and engagement was
      not strictly linear.

      Although the 3–7 day group showed the weakest engagement
      performance, videos taking more than 7 days to trend had
      48.96% below-median engagement, close to the 50% benchmark.

      Therefore, time-to-trend should be treated as an associated
      performance indicator rather than assuming that every
      additional hour before trending automatically reduces
      engagement.

   7. Declining engagement is associated with multiple factors
      rather than a single cause.

      Category, publishing time, description length, reach, and
      time-to-trend all showed measurable relationships with
      engagement performance.

      The strongest practical signals were the high
      below-median engagement observed for certain categories,
      specific publishing hours, longer descriptions, and the
      3–7 day time-to-trend group.

   IMPORTANT:
   These findings represent associations observed in the analyzed
   dataset. They should not be interpreted as causal relationships.

   Sample size should also be considered when evaluating smaller
   categories or less frequently observed publishing periods.

   ============================================================ */