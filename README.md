# **YouTube Content Analytics \& AI-Powered High-Potential Content Prediction**



##### **Project Overview**



An end-to-end data analytics and machine learning project exploring YouTube video performance, audience engagement, content categories, and the potential to identify promising content using historical video metadata.



The project combines Python-based data preparation, SQL business analysis, a Logistic Regression classification model, and an interactive Power BI dashboard.



###### **Objective:** Turn video-performance data into actionable insights that can help a media team evaluate content performance and prioritize videos for further review.



###### **Business Questions**



1\. Which content categories generate the most views and engagement?

2\. How do audience interaction and engagement differ across categories?

3\. Which video characteristics are associated with lower engagement?

4\. Can historical video metadata help identify high-potential content before its performance is known?

5\. How can model scores support content prioritization?



###### **Technology Stack**



\- Python

\- Pandas and NumPy

\- Scikit-learn

\- PostgreSQL / SQL

\- Power BI

\- DAX

\- Git and GitHub



###### **Project Workflow**



1\. **Data preparation:** Clean video metadata and engineer engagement and publishing-time features.

2\. **Business analysis:** Use SQL to investigate content performance, audience interaction, engagement patterns, and high-potential videos.

3\. **Machine learning:** Train a Logistic Regression model to estimate the probability that a video belongs to the high-potential class.

4\. **Decision support:** Convert predicted probabilities into content-priority bands and a screening flag.

5\. **Visualization:** Present findings in a four-page Power BI dashboard.

6\. **Documentation:** Explain the business questions, findings, model evaluation, recommendations, and limitations.



###### **Key Findings**



\- The analyzed population contains 15,893 videos meeting the project's minimum-view eligibility rule.

\- The eligible videos recorded approximately 28.58 billion total views.

\- Average engagement rate was approximately 3.79%.

\- High-potential content was defined using the top quartile of engagement within the eligible population, resulting in 3,974 high-potential videos.

\- Content categories differed in both publishing volume and audience-interaction efficiency. High volume did not necessarily mean high engagement efficiency.

\- Publishing characteristics and engagement were associated in the historical data, but these relationships do not establish causation.



###### **Machine Learning Results**



The model uses category and publishing metadata, description presence, and description length to estimate high-potential probability.



Reported evaluation results at the selected 0.35 decision threshold:



| Metric | Result |

\---------------------

| ROC-AUC | 0.7026 |

| Precision | 48.70% |

| Recall | 40.00% |

| F1 score | 43.92% |



The 0.35 threshold is a practical screening choice for this project, not a universally optimal threshold. These metrics are based on the held-out test set and should not be confused with the number of videos flagged when the model scores the complete dataset.



The model provides a prioritization signal, not a guarantee that a video will succeed. Its performance and usefulness should be validated on new data before operational use.



###### **Power BI Dashboard**



The report contains four pages:



1\. **Executive Overview** — headline performance metrics and category-level comparisons.

2\. **Content Performance Deep Dive** — engagement patterns by description length, time to trend, category, and publishing day.

3\. **AI, Audience \& Team Performance** — model priorities, audience indicators, and simulated team-productivity metrics.

4\. **AI Model Performance** — model evaluation, probability bands, and feature effects.



Dashboard screenshots and supporting analysis should be available in the `docs/` directory.



###### **Important Data and Methodology Notes**



\- High-potential labels are based on historical engagement, so the model estimates similarity to that defined label rather than guaranteed future success.

\- `time\_to\_trend` was excluded from model predictors to avoid using information that would not necessarily be available at prediction time.

\- The audience sentiment and success indicators are constructed from video metrics and rules; they are not sentiment extracted from actual audience comments.

\- Team assignments, productivity measures, and related operational data are synthetic and must not be interpreted as real company employee performance.

\- Observational relationships should not be interpreted as causal effects.

\- Results depend on the source dataset, eligibility criteria, feature definitions, and modeling choices.



###### **Repository Structure**



\- `data/` — approved datasets and synthetic tables.

\- `notebooks/` — Python analysis and data-generation scripts.

\- `sql/` — SQL business-problem analyses.

\- `models/` — trained preprocessing and classification artifacts.

\- `dashboards/` — Power BI report.

\- `docs/` — business analysis, model documentation, and dashboard screenshots.



###### **Running the Project**



1\. Install a compatible Python version.

2\. Install dependencies using `pip install -r requirements.txt`.

3\. Obtain the source dataset from its authorized distribution location.

4\. Follow the documented execution order for data preparation and synthetic table generation.

5\. Run the SQL scripts using a configured PostgreSQL database.

6\. Open the Power BI report and configure its data sources if needed.



Exact paths, dataset instructions, and database setup steps will be finalized after repository validation.



###### **Limitations**



\- Historical patterns may not generalize to future videos or other platforms.

\- Model performance is moderate and includes both missed high-potential videos and false positives.

\- Synthetic audience and team data demonstrate analytical workflows rather than real-world operational outcomes.

\- Further validation on genuinely future-dated observations would be needed before using the model to make production decisions.



###### **Author**



Developed as a portfolio project demonstrating data preparation, SQL analysis, machine learning, and business intelligence reporting.

