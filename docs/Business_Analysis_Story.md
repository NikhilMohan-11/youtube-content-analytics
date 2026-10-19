# Business Analysis Story
## AI-Powered YouTube Content Analytics & High-Potential Content Prediction

**Author:** Nikhil Mohan  
**Tools:** Python, Pandas, NumPy, Scikit-learn, PostgreSQL, SQL, Power BI, DAX

## 1. Executive Summary

This project analyzes YouTube trending-video data to understand audience engagement, compare content categories, identify lower-engagement patterns, and prioritize potentially high-potential content using an interpretable machine-learning model.

The main analysis covers **15,893 videos with at least 1,000 views**.

Headline results:
- 28.58 billion total views across the eligible population.
- 3.79% average engagement.
- 3,974 videos classified as high-potential.
- 3,311 videos flagged by the final AI scoring framework.
- Logistic Regression achieved 70.3% ROC-AUC.

The practical objective is not to guarantee viral success. It is to help content teams identify patterns and prioritize human review.

## 2. Business Context

Content teams need to decide which categories deserve attention, what characteristics are associated with stronger engagement, where engagement is weaker, and which videos should receive additional review.

The project therefore combines data preparation, SQL analysis, machine learning and Power BI storytelling.

## 3. Business Questions

### BP1 — Engagement Drivers
What factors are associated with content engagement and popularity?

### BP2 — Category Performance
Which content categories generate the highest audience interaction?

### BP3 — Lower Engagement
What factors are associated with lower engagement?

### BP4 — AI Content Prioritization
Can we identify content with a higher probability of being high-potential?

## 4. Data & Methodology

The primary population is videos with **views >= 1,000**.

Engineered features include:
- engagement rate
- like ratio
- description presence
- description length
- publishing date/hour/day
- weekend flag
- trending date
- time-to-trend
- category name

Workflow:

```text
Raw YouTube Data
       ↓
Cleaning & Feature Engineering
       ↓
Python EDA
       ↓
PostgreSQL / SQL
       ↓
Business Problem Analysis
       ↓
Logistic Regression
       ↓
AI Probability Scoring
       ↓
Power BI Dashboard
```

## 5. BP1 — Engagement Drivers

Engagement varied substantially across categories and publishing patterns. Description characteristics also showed non-linear relationships with engagement.

Shorter descriptions among videos with descriptions showed stronger engagement in this dataset, but description length should not be interpreted as a causal driver.

Time-to-trend was associated with engagement, but it was deliberately excluded from the ML predictors because it is outcome-related.

**Key takeaway:** reach and engagement should be evaluated separately; content performance is multi-dimensional.

## 6. BP2 — Category Performance

The largest categories by volume were:
- Gaming — 29.47%
- Music — 27.81%
- Entertainment — 19.95%
- People & Blogs — 11.05%

Together they represented about 88.28% of eligible content.

However, volume was not the same as engagement efficiency. Travel & Events, Comedy and Howto & Style showed particularly strong high-potential rates, while smaller categories require cautious interpretation because of sample size.

A composite Audience Interaction Index ranked Travel & Events, Comedy, Howto & Style, News & Politics and Science & Technology among the strongest categories.

**Key takeaway:** distinguish scale categories from high-efficiency categories.

## 7. BP3 — Lower Engagement

The median engagement benchmark was **2.8703%**.

Among 15,893 eligible videos:
- 7,946 were below the median.
- 7,947 were at or above the median.

Higher below-median rates appeared in:
- Entertainment — 62.33%
- Music — 55.01%
- People & Blogs — 47.84%
- Gaming — 46.52%

Below-median videos had higher average views, illustrating that extreme reach can coexist with weak engagement.

**Key takeaway:** views alone are not a sufficient measure of content quality or audience interaction.

## 8. BP4 — AI High-Potential Prediction

High-potential content was defined as the top 25% of eligible videos by engagement rate.

Threshold: **4.7433% engagement**

This produced:
- 3,974 high-potential videos.
- 11,919 normal videos.

### Model inputs
- category
- publishing hour
- publishing day
- weekend flag
- description presence
- description length

`time_to_trend` was excluded to avoid post-outcome leakage.

### Model
**Logistic Regression**

Train/test:
- Training: 12,714
- Test: 3,179
- Stratified split

## 9. Model Performance

| Metric | Result |
|---|---:|
| ROC-AUC | 70.26% |
| Precision | 48.70% |
| Recall | 40.00% |
| F1 | 43.92% |

The default 0.50 threshold was too conservative for screening. A 0.35 operating threshold was evaluated as a practical compromise.

At 0.35:
- 653 test videos were flagged.
- 318 actual high-potential videos were captured.
- Recall was 40.0%.
- Precision was 48.7%.

This is a prioritization model, not an automatic success classifier.

## 10. Probability-Band Evidence

Observed high-potential rate by predicted probability:

| Probability band | Actual high-potential rate |
|---|---:|
| 0.00–0.20 | 11.75% |
| 0.20–0.40 | 26.41% |
| 0.40–0.60 | 54.65% |
| 0.60–0.80 | 72.92% |

The increasing observed rate supports using model probability for ranking and screening.

## 11. Category-Level AI Signals

Examples of high-potential rates:
- Travel & Events — 78.95%
- Comedy — 61.64%
- Howto & Style — 55.88%
- News & Politics — 55.50%
- Science & Technology — 54.76%
- Education — 50.00%
- Gaming — 24.03%
- Entertainment — 15.90%

Rates and absolute volumes should be interpreted separately.

## 12. AI Prioritization

The final scoring dataset assigns each eligible video:
- predicted probability
- priority
- model flag
- high-potential status

Priority distribution:
- Low Priority — 5,608
- Medium Priority — 8,262
- High Priority — 1,845
- Very High Priority — 178

This turns the model from a technical output into a practical screening workflow.

## 13. Power BI Dashboard

### Page 1 — Executive Overview
**Question:** What is happening?

Shows portfolio KPIs, category engagement, high-potential rates, category volume and publishing patterns.

![Executive Overview](assets/dashboard_page1.png)

### Page 2 — Content Performance Deep Dive
**Question:** Why does engagement vary?

Shows description length, time-to-trend, lower-engagement categories and publishing-day patterns.

![Content Performance](assets/dashboard_page2.png)

### Page 3 — AI, Audience & Team Performance
**Question:** What should the business prioritize?

Shows AI priority, high-potential content by category, audience sentiment and production-team productivity.

![AI Audience Team](assets/dashboard_page3.png)

### Page 4 — AI Model Performance
**Question:** How useful is the AI signal?

Shows ROC-AUC, precision, recall, F1, prediction probabilities, priority distribution and model-associated categories.

![AI Model Performance](assets/dashboard_page4.png)

## 14. Final Business Recommendations

### 1. Separate scale from engagement efficiency
Gaming and Music dominate volume, but smaller categories can show stronger engagement efficiency.

### 2. Use AI scoring for human prioritization
Use probability and priority levels to decide which content deserves additional editorial or promotional review.

### 3. Investigate high-potential categories
Travel & Events, Comedy, Howto & Style, News & Politics and Science & Technology showed strong high-potential rates, subject to sample-size caution.

### 4. Do not optimize for views alone
Monitor reach and engagement as separate KPIs.

### 5. Treat timing and description patterns as experiments
Use observed patterns to design controlled tests rather than fixed rules.

## 15. Limitations

- The data is observational, so relationships are not causal.
- The dataset represents a specific US trending-video context and may not generalize to all channels or markets.
- Some categories have small samples.
- Logistic Regression was chosen for interpretability; more complex models may capture non-linear patterns.
- High-potential means top-quartile engagement, not guaranteed virality.
- The 0.35 threshold is an operating choice, not a universal optimum.
- Time-to-trend was excluded from prediction because it is outcome-related.

## 16. What This Project Demonstrates

This project demonstrates an end-to-end analyst workflow:

**Data → Analysis → Modeling → Scoring → Visualization → Business Recommendations**

It combines:
- Python data analysis
- SQL/PostgreSQL
- machine learning
- Power BI
- DAX
- business storytelling

## 17. Final Conclusion

Content performance is multi-dimensional. Volume, reach, engagement, audience sentiment and high-potential status do not always identify the same content.

The strongest practical approach is to combine portfolio KPIs, content analysis, audience signals and AI prioritization.

The model should support human decision-making rather than replace it.

## 18. Portfolio Positioning

> An end-to-end AI-powered analytics solution combining Python, SQL, machine learning and Power BI to identify engagement drivers, evaluate content categories and prioritize high-potential YouTube content.

## 19. Interview-Ready Summary

> I built an end-to-end YouTube content analytics solution using Python, PostgreSQL, SQL, Scikit-learn and Power BI. I analyzed 15,893 videos with at least 1,000 views to identify engagement drivers and category-level performance patterns. I then defined high-potential content as the top 25% by engagement and trained an interpretable Logistic Regression model that achieved 70.3% ROC-AUC. Finally, I converted model probabilities into a content-prioritization framework and built a four-page Power BI dashboard covering executive KPIs, engagement analysis, audience signals and AI model performance.
