/* ============================================================
   BUSINESS QUESTION 2
   Which content categories generate the highest audience
   interaction?

   Objective:
   Identify categories that generate strong audience interaction
   using likes, comments, dislikes and normalized engagement
   metrics while accounting for content volume and reach.
   ============================================================ */


/* ============================================================
   SECTION 2 — DATA QUALITY & BASELINE VALIDATION
   ============================================================ */

-- Q2.0.1 — Overall audience interaction baseline

SELECT
    COUNT(*) AS total_videos,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes,
    SUM(comments) AS total_comments,
    SUM(dislikes) AS total_dislikes,
    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views_per_video,
    ROUND(
        AVG(likes)::numeric,
        2
    ) AS avg_likes_per_video,
    ROUND(
        AVG(comments)::numeric,
        2
    ) AS avg_comments_per_video,
    ROUND(
        AVG(dislikes)::numeric,
        2
    ) AS avg_dislikes_per_video,
    ROUND(
        AVG(engagement_rate)::numeric,
        4
    ) AS avg_engagement_rate,
    ROUND(
        AVG(like_ratio)::numeric,
        4
    ) AS avg_like_ratio
FROM videos_fact
WHERE views > 0;

-- Q2.0.2 — Validate audience interaction metrics

SELECT
    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE views <= 0
    ) AS non_positive_views,

    COUNT(*) FILTER (
        WHERE likes < 0
    ) AS negative_likes,

    COUNT(*) FILTER (
        WHERE comments < 0
    ) AS negative_comments,

    COUNT(*) FILTER (
        WHERE dislikes < 0
    ) AS negative_dislikes,

    COUNT(*) FILTER (
        WHERE engagement_rate IS NULL
    ) AS null_engagement_rate,

    COUNT(*) FILTER (
        WHERE like_ratio IS NULL
    ) AS null_like_ratio,

    COUNT(*) FILTER (
        WHERE comments > views
    ) AS comments_exceeding_views,

    COUNT(*) FILTER (
        WHERE likes > views
    ) AS likes_exceeding_views

FROM videos_fact;


-- Q2.0.3 — Category distribution

SELECT
    category_name,

    COUNT(*) AS total_videos,

    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS percentage_of_content

FROM videos_fact

GROUP BY category_name

ORDER BY total_videos DESC;

/* ============================================================
   SECTION 2.1 — CATEGORY AUDIENCE INTERACTION
   ============================================================ */

-- Q2.1 — Which categories generate the highest
-- total audience interaction?

SELECT
    category_name,

    COUNT(*) AS total_videos,

    SUM(views) AS total_views,

    SUM(likes) AS total_likes,

    SUM(comments) AS total_comments,

    SUM(likes + comments) AS total_interactions,

    ROUND(
        SUM(likes + comments)::numeric
        / NULLIF(SUM(views), 0) * 100,
        4
    ) AS overall_interaction_rate

FROM videos_fact

WHERE views >= 1000

GROUP BY category_name

ORDER BY total_interactions DESC;


-- Q2.1.1 — Which categories generate the highest
-- average audience interaction per video?

SELECT
    category_name,

    COUNT(*) AS total_videos,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views_per_video,

    ROUND(
        AVG(likes)::numeric,
        2
    ) AS avg_likes_per_video,

    ROUND(
        AVG(comments)::numeric,
        2
    ) AS avg_comments_per_video,

    ROUND(
        AVG(likes + comments)::numeric,
        2
    ) AS avg_interactions_per_video,

    ROUND(
        AVG(
            (likes + comments)::numeric
            / NULLIF(views, 0) * 100
        ),
        4
    ) AS avg_interaction_rate

FROM videos_fact

WHERE views >= 1000

GROUP BY category_name

ORDER BY avg_interactions_per_video DESC;


-- Q2.1.1 — Which categories generate the highest
-- average audience interaction per video?

SELECT
    category_name,

    COUNT(*) AS total_videos,

    ROUND(
        AVG(views)::numeric,
        2
    ) AS avg_views_per_video,

    ROUND(
        AVG(likes)::numeric,
        2
    ) AS avg_likes_per_video,

    ROUND(
        AVG(comments)::numeric,
        2
    ) AS avg_comments_per_video,

    ROUND(
        AVG(likes + comments)::numeric,
        2
    ) AS avg_interactions_per_video,

    ROUND(
        AVG(
            (likes + comments)::numeric
            / NULLIF(views, 0) * 100
        ),
        4
    ) AS avg_interaction_rate

FROM videos_fact

WHERE views >= 1000

GROUP BY category_name

ORDER BY avg_interactions_per_video DESC;

-- Q2.1.2 — Which categories generate the strongest
-- like-based and comment-based audience interaction?

SELECT
    category_name,

    COUNT(*) AS total_videos,

    ROUND(
        AVG(like_ratio)::numeric * 100,
        4
    ) AS avg_like_percentage,

    ROUND(
        AVG(
            comments::numeric
            / NULLIF(views, 0)
        ) * 100,
        4
    ) AS avg_comment_percentage,

    ROUND(
        AVG(likes)::numeric,
        2
    ) AS avg_likes_per_video,

    ROUND(
        AVG(comments)::numeric,
        2
    ) AS avg_comments_per_video,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY engagement_rate
        )::numeric * 100,
        4
    ) AS median_engagement_percentage

FROM videos_fact

WHERE views >= 1000

GROUP BY category_name

ORDER BY avg_comment_percentage DESC;


/* ============================================================
   SECTION 2.2 — NORMALIZED CATEGORY PERFORMANCE
   ============================================================ */

-- Q2.2 — Which categories outperform the overall
-- engagement benchmark?

WITH benchmark AS (

    SELECT
        AVG(engagement_rate) AS overall_avg_engagement

    FROM videos_fact

    WHERE views >= 1000
)

SELECT
    v.category_name,

    COUNT(*) AS total_videos,

    ROUND(
        AVG(v.engagement_rate)::numeric * 100,
        4
    ) AS category_avg_engagement_pct,

    ROUND(
        b.overall_avg_engagement::numeric * 100,
        4
    ) AS overall_avg_engagement_pct,

    ROUND(
        (
            AVG(v.engagement_rate)
            - b.overall_avg_engagement
        )::numeric * 100,
        4
    ) AS difference_from_benchmark_pct_points,

    ROUND(
        (
            AVG(v.engagement_rate)
            / NULLIF(b.overall_avg_engagement, 0)
        )::numeric,
        2
    ) AS benchmark_multiple

FROM videos_fact v

CROSS JOIN benchmark b

WHERE v.views >= 1000

GROUP BY
    v.category_name,
    b.overall_avg_engagement

ORDER BY benchmark_multiple DESC;


-- Q2.2.1 — Which categories have the highest proportion
-- of consistently high-engagement content?

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
    v.category_name,

    COUNT(*) AS total_videos,

    COUNT(*) FILTER (
        WHERE v.engagement_rate >= threshold.p75
    ) AS high_engagement_videos,

    ROUND(
        COUNT(*) FILTER (
            WHERE v.engagement_rate >= threshold.p75
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS high_engagement_percentage,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY v.engagement_rate
        )::numeric * 100,
        4
    ) AS median_engagement_percentage,

    ROUND(
        AVG(v.engagement_rate)::numeric * 100,
        4
    ) AS avg_engagement_percentage

FROM videos_fact v

CROSS JOIN threshold

WHERE v.views >= 1000

GROUP BY
    v.category_name

ORDER BY high_engagement_percentage DESC;


/* ============================================================
   SECTION 2.3 — REACH VS AUDIENCE INTERACTION
   ============================================================ */

-- Q2.3 — Which categories combine strong reach
-- with strong audience engagement?

WITH benchmarks AS (

    SELECT
        AVG(views) AS avg_views_benchmark,
        AVG(engagement_rate) AS avg_engagement_benchmark

    FROM videos_fact

    WHERE views >= 1000
),

category_performance AS (

    SELECT
        category_name,

        COUNT(*) AS total_videos,

        AVG(views) AS avg_views_per_video,

        AVG(engagement_rate) AS avg_engagement_rate

    FROM videos_fact

    WHERE views >= 1000

    GROUP BY category_name
)

SELECT
    c.category_name,

    c.total_videos,

    ROUND(
        c.avg_views_per_video::numeric,
        2
    ) AS avg_views_per_video,

    ROUND(
        c.avg_engagement_rate::numeric * 100,
        4
    ) AS avg_engagement_percentage,

    CASE
        WHEN c.avg_views_per_video >= b.avg_views_benchmark
         AND c.avg_engagement_rate >= b.avg_engagement_benchmark
            THEN 'High Reach + High Engagement'

        WHEN c.avg_views_per_video >= b.avg_views_benchmark
         AND c.avg_engagement_rate < b.avg_engagement_benchmark
            THEN 'High Reach + Low Engagement'

        WHEN c.avg_views_per_video < b.avg_views_benchmark
         AND c.avg_engagement_rate >= b.avg_engagement_benchmark
            THEN 'Low Reach + High Engagement'

        ELSE 'Low Reach + Low Engagement'

    END AS performance_segment

FROM category_performance c

CROSS JOIN benchmarks b

ORDER BY
    c.avg_engagement_rate DESC;



/* ============================================================
   Q2.3.1 — ROBUST REACH VS ENGAGEMENT SEGMENTATION
   Uses median views to reduce the influence of extreme
   high-view observations.
   ============================================================ */

WITH benchmarks AS (

    SELECT
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY views
        ) AS median_views_benchmark,

        AVG(engagement_rate) AS avg_engagement_benchmark

    FROM videos_fact

    WHERE views >= 1000
),

category_performance AS (

    SELECT
        category_name,

        COUNT(*) AS total_videos,

        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY views
        ) AS median_views_per_video,

        AVG(views) AS avg_views_per_video,

        AVG(engagement_rate) AS avg_engagement_rate

    FROM videos_fact

    WHERE views >= 1000

    GROUP BY category_name
)

SELECT
    c.category_name,

    c.total_videos,

    ROUND(
        c.median_views_per_video::numeric,
        2
    ) AS median_views_per_video,

    ROUND(
        c.avg_views_per_video::numeric,
        2
    ) AS avg_views_per_video,

    ROUND(
        c.avg_engagement_rate::numeric * 100,
        4
    ) AS avg_engagement_percentage,

    ROUND(
        b.median_views_benchmark::numeric,
        2
    ) AS overall_median_views,

    CASE
        WHEN c.median_views_per_video >= b.median_views_benchmark
         AND c.avg_engagement_rate >= b.avg_engagement_benchmark
            THEN 'High Reach + High Engagement'

        WHEN c.median_views_per_video >= b.median_views_benchmark
         AND c.avg_engagement_rate < b.avg_engagement_benchmark
            THEN 'High Reach + Low Engagement'

        WHEN c.median_views_per_video < b.median_views_benchmark
         AND c.avg_engagement_rate >= b.avg_engagement_benchmark
            THEN 'Low Reach + High Engagement'

        ELSE 'Low Reach + Low Engagement'
    END AS performance_segment

FROM category_performance c

CROSS JOIN benchmarks b

ORDER BY
    c.avg_engagement_rate DESC;

/* ============================================================ 
   Q2.4 — CATEGORY AUDIENCE INTERACTION INDEX 
============================================================ */ 
WITH category_metrics AS (
    SELECT 
        category_name, 
        COUNT(*) AS total_videos,
        /* Typical engagement efficiency */
        PERCENTILE_CONT(0.50) WITHIN GROUP ( ORDER BY engagement_rate ) AS median_engagement_rate,
        /* Positive audience interaction */
        AVG(like_ratio) AS avg_like_ratio,
        /* Deeper audience interaction */
        AVG( comments::numeric / NULLIF(views, 0) ) AS avg_comment_rate,
        /* Consistency of strong-performing content */
        COUNT(*) FILTER ( 
            WHERE engagement_rate >= ( 
                SELECT PERCENTILE_CONT(0.75) WITHIN GROUP ( ORDER BY engagement_rate ) 
                FROM videos_fact 
                WHERE views >= 1000 
            ) 
        )::numeric / COUNT(*) AS high_engagement_rate
    FROM videos_fact 
    WHERE views >= 1000 
    GROUP BY category_name
),
ranked_metrics AS (
    SELECT 
        *, 
        PERCENT_RANK() OVER ( ORDER BY median_engagement_rate ) AS engagement_score,
        PERCENT_RANK() OVER ( ORDER BY avg_like_ratio ) AS like_score,
        PERCENT_RANK() OVER ( ORDER BY avg_comment_rate ) AS comment_score,
        PERCENT_RANK() OVER ( ORDER BY high_engagement_rate ) AS consistency_score
    FROM category_metrics
)
SELECT 
    category_name, 
    total_videos, 
    ROUND( median_engagement_rate::numeric * 100, 4 ) AS median_engagement_pct, 
    ROUND( avg_like_ratio::numeric * 100, 4 ) AS avg_like_pct, 
    ROUND( avg_comment_rate::numeric * 100, 4 ) AS avg_comment_pct, 
    ROUND( high_engagement_rate::numeric * 100, 2 ) AS high_engagement_content_pct, 
    /* Cast the result of percent_rank math to numeric before rounding */
    ROUND( 
        (( engagement_score + like_score + comment_score + consistency_score ) / 4 * 100)::numeric, 
        2 
    ) AS audience_interaction_index
FROM ranked_metrics
ORDER BY audience_interaction_index DESC;


/* ============================================================
   Q2.5 — CONTENT VOLUME VS AUDIENCE INTERACTION
   ============================================================ */

SELECT
    category_name,

    COUNT(*) AS total_videos,

    SUM(likes + comments) AS total_interactions,

    ROUND(
        AVG(likes + comments)::numeric,
        2
    ) AS avg_interactions_per_video,

    ROUND(
        (
            SUM(likes + comments)::numeric
            / NULLIF(SUM(views), 0)
        ) * 100,
        4
    ) AS weighted_interaction_rate,

    ROUND(
        AVG(
            (likes + comments)::numeric
            / NULLIF(views, 0)
        ) * 100,
        4
    ) AS avg_video_interaction_rate

FROM videos_fact

WHERE views >= 1000

GROUP BY category_name

ORDER BY total_interactions DESC;


/* ============================================================
   Q2.6 — AUDIENCE INTERACTION CONSISTENCY BY CATEGORY
   ============================================================ */

SELECT
    category_name,

    COUNT(*) AS total_videos,

    ROUND(
        AVG(
            (likes + comments)::numeric
            / NULLIF(views, 0)
        ) * 100,
        4
    ) AS avg_interaction_rate,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY
                (likes + comments)::numeric
                / NULLIF(views, 0)
        )::numeric * 100,
        4
    ) AS median_interaction_rate,

    ROUND(
        (
            AVG(
                (likes + comments)::numeric
                / NULLIF(views, 0)
            )
            -
            PERCENTILE_CONT(0.50)
            WITHIN GROUP (
                ORDER BY
                    (likes + comments)::numeric
                    / NULLIF(views, 0)
            )
        )::numeric * 100,
        4
    ) AS avg_median_gap

FROM videos_fact

WHERE views >= 1000

GROUP BY category_name

ORDER BY median_interaction_rate DESC;

/* ============================================================
   SECTION 9 — FINAL BUSINESS FINDINGS
   ============================================================

   Q2 FINDINGS

	1. Travel & Events — highest interaction efficiency
		7.10% average engagement, 6.39% median, and 91.07 Audience Interaction Index.
		But only 19 videos, so confidence is limited.

	2. Comedy — strong and more credible performer
		6.16% average engagement, 5.52% median, 87.50 index, with 73 videos.

	3. Howto & Style — strong interaction
		5.69% average engagement, 5.27% median, 85.71 index.
		Small sample of 34 videos.

	4. News & Politics — strongest consistency
		5.09% average vs 5.11% median, demonstrating unusually consistent audience interaction across 200 videos.

	5. Science & Technology — strong interaction
		5.33% average engagement, 4.95% median, and 75.00 index.
	
	6. Education — promising high-engagement category
		5.33% average, 4.77% median, 71.43 index, with 50% of videos classified as high engagement.
		Again, only 42 videos.
		
   IMPORTANT:
   These findings represent associations in the analyzed dataset.
   They should not be interpreted as causal relationships.
   ============================================================ */