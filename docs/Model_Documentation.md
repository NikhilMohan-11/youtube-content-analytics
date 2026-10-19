# Model Documentation: High-Potential YouTube Content Prediction

## 1. Project Overview

This project uses machine learning to estimate the likelihood that a YouTube video belongs to a high-engagement content group. The model is part of a broader YouTube Content Analytics project combining Python-based data preparation, SQL analysis, machine learning, and Power BI visualization.

The objective is to support content-planning decisions by identifying videos that may deserve additional attention based on characteristics available in the model-development dataset.

- **Model type:** Logistic Regression
- **Problem type:** Binary classification
- **Target variable:** `high_potential`

The model is a decision-support tool, not a guarantee of video performance.

## 2. Business Objective

The model addresses the following question:

> Can a video's category, publication timing, and description characteristics help identify content with high engagement potential?

Potential applications include:

- Prioritizing videos for content review.
- Supporting content-planning and publishing decisions.
- Identifying videos for closer performance monitoring.
- Comparing predicted potential with observed engagement.

## 3. Dataset and Target Definition

The model-development dataset is `mi_high_potential.csv`.

| Column | Role |
|---|---|
| `video_id` | Video identifier; excluded from predictive features |
| `category_id` | Input feature |
| `publish_hour` | Input feature |
| `publish_day` | Input feature |
| `weekend_flag` | Input feature |
| `has_description` | Input feature |
| `description_length` | Input feature |
| `high_potential` | Binary target |

The corrected model run used **15,893 records**. The target distribution was:

| Target class | Records | Share |
|---|---:|---:|
| Normal potential (`0`) | 11,919 | 75% |
| High potential (`1`) | 3,974 | 25% |
| **Total** | **15,893** | **100%** |

The project defines high-potential content using the top quartile of engagement. The previously documented engagement threshold is **4.7433%**. The exact threshold and eligibility-filter logic should be verified against the upstream dataset-generation script before making claims about how the target was constructed.

- `high_potential = 1`: the video meets the project's high-potential criterion.
- `high_potential = 0`: the video does not meet that criterion.

This is a project-defined label. It does not mean a video is guaranteed to become popular or perform well in the future.

## 4. Feature Engineering and Selection

The model uses six input features:

| Feature | Purpose |
|---|---|
| `category_id` | Represents the video's content category. |
| `publish_hour` | Captures the hour of publication. |
| `publish_day` | Represents the day-of-week publication feature. |
| `weekend_flag` | Indicates whether the video was published on a weekend. |
| `has_description` | Indicates whether a description is present. |
| `description_length` | Represents the length of the video description. |

`video_id` is excluded because it is an identifier rather than a meaningful predictive feature.

`time_to_trend` is excluded because it is calculated using information related to the video's subsequent trending outcome. Including it could introduce target leakage and make evaluation unrealistically optimistic.

Views, likes, dislikes, comments, and engagement measures are not among the six stated model inputs.

## 5. Data Preprocessing

The implementation uses scikit-learn's `ColumnTransformer` and `OneHotEncoder`.

- **Categorical features:** `category_id` and `publish_day`.
- **Numerical/pass-through features:** `publish_hour`, `weekend_flag`, `has_description`, and `description_length`.
- `OneHotEncoder(handle_unknown="ignore")` encodes the categorical features and allows unseen categories to be transformed without raising an error.
- The preprocessor is fitted on the training set only, then applied to the test set.
- The CSV's Boolean-like values are converted explicitly: `t`/`true`/`1` to `1`, and `f`/`false`/`0` to `0`. This avoids treating a non-empty string such as `"f"` as `True`.

## 6. Model Training

The selected algorithm is **Logistic Regression**, implemented with scikit-learn.

| Setting | Value |
|---|---|
| `max_iter` | `1000` |
| `random_state` | `42` |
| Train/test split | 80% / 20% |
| Stratification | Yes |

The corrected run used:

| Dataset portion | Records |
|---|---:|
| Training set | 12,714 |
| Test set | 3,179 |
| **Total** | **15,893** |

Stratification preserves approximately the same target-class proportions in the training and test sets.

## 7. Model Evaluation

The model was evaluated on the held-out test set. The following results are from the **corrected run after fixing Boolean-like feature conversion**.

### 7.1 Results at the default probability threshold of 0.50

| Metric | Result |
|---|---:|
| Accuracy | 0.7587 |
| Precision | 0.6707 |
| Recall | 0.0692 |
| F1-score | 0.1254 |
| ROC-AUC | 0.7040 |

ROC-AUC measures the model's ability to rank positive examples above negative examples across thresholds. A ROC-AUC of **0.7040** indicates moderate discrimination, but uncertainty remains.

At the default threshold of 0.50, recall is low: the model identifies only a small proportion of videos that actually belong to the high-potential class. Accuracy should not be interpreted alone because approximately 75% of the dataset belongs to the normal-potential class.

### 7.2 Threshold analysis

The following table reports classification results at different probability thresholds on the same test set.

| Threshold | Videos flagged as high-potential | Precision | Recall | F1-score |
|---:|---:|---:|---:|---:|
| 0.20 | 2,049 | 0.3245 | 0.8365 | 0.4677 |
| 0.25 | 1,485 | 0.3455 | 0.6453 | 0.4500 |
| 0.30 | 1,012 | 0.3943 | 0.5019 | 0.4416 |
| **0.35** | **662** | **0.4955** | **0.4126** | **0.4502** |
| 0.40 | 420 | 0.5571 | 0.2943 | 0.3852 |
| 0.45 | 190 | 0.5895 | 0.1409 | 0.2274 |
| 0.50 | 82 | 0.6707 | 0.0692 | 0.1254 |

A threshold of **0.35** is used by the project's business-screening flag. Compared with the default threshold of 0.50, it captures more high-potential videos while accepting more false positives.

The threshold is a business trade-off, not a universal optimum. In this table, threshold 0.20 has the highest recall and F1-score among the tested thresholds, while 0.35 flags fewer candidates and has higher precision. The preferred threshold depends on the cost of missing promising content versus the resources available to review flagged videos.

**Evaluation caveat:** the threshold comparison was calculated on the test set. For a more rigorous model evaluation, select the operating threshold using a separate validation set and report final metrics on an untouched test set.

### 7.3 Confusion matrix at threshold 0.35

| Outcome | Videos |
|---|---:|
| True positives | 328 |
| False positives | 334 |
| True negatives | 2,050 |
| False negatives | 467 |
| **Total test videos** | **3,179** |

At this threshold:

- **662 videos** were flagged (328 true positives + 334 false positives).
- **Precision:** 49.55% of flagged videos were actually high-potential under the project's label.
- **Recall/capture rate:** 41.26% of actual high-potential test videos were captured (328 of 795).
- **False negatives:** 467 high-potential videos were missed.

The flagged list should therefore be treated as a review queue, not as a definitive list of future winners.

## 8. Scoring and Priority Classification

The project produces `final_ai_scored_videos.csv`, which contains the model input features and scoring outputs.

Relevant fields include:

- `video_id`: video identifier.
- `high_potential`: observed project-defined target label, retained for analysis/validation.
- `predicted_probability`: model-estimated probability of the high-potential class.
- `priority`: priority band assigned from the predicted probability.
- `model_flag`: business-screening flag based on a probability threshold of `0.35`.

Priority bands are assigned as follows:

| Probability band | Priority |
|---|---|
| 0.00–0.20 | Low Priority |
| Above 0.20–0.40 | Medium Priority |
| Above 0.40–0.60 | High Priority |
| Above 0.60–1.00 | Very High Priority |

The scoring script uses `pd.cut` with right-inclusive bins and `include_lowest=True`; boundary values are assigned to the lower band at exact cut points. The `model_flag` is `1` when `predicted_probability >= 0.35`, otherwise `0`.

### Corrected full-dataset scoring output

The corrected run exported **15,893 records** to `data/final_ai_scored_videos.csv`.

| Priority band | Videos |
|---|---:|
| Low Priority | 5,558 |
| Medium Priority | 8,203 |
| High Priority | 1,948 |
| Very High Priority | 184 |
| **Total** | **15,893** |

| Model flag | Videos |
|---|---:|
| Not flagged (`0`) | 12,575 |
| Flagged (`1`) | 3,318 |
| **Total** | **15,893** |

The full-dataset flag count is different from the test-set count because the full output scores all 15,893 records, while the threshold evaluation above covers only the 3,179 held-out test records. Full-dataset probabilities include records used for training and should not be presented as independent evaluation results.

## 9. Interpretation and Business Use

The model estimates probabilities from patterns learned in the training data. Scores can help organize content for review, but should be considered alongside audience needs, creative quality, production constraints, and business goals.

A higher predicted probability does not establish that a video will receive more views or engagement. A low score does not mean a video should never be published.

The model identifies statistical associations; it does not establish that changing a feature—such as publication hour or description length—will cause engagement to increase.

## 10. Limitations

1. **Engagement is not the same as reach.** A video with a high engagement rate may not have the highest view count.
2. **The target depends on a project-defined threshold.** Defining the top quartile as high-potential is a project decision; other definitions could produce different labels and metrics.
3. **The model does not guarantee future performance.** Results depend on patterns in the available dataset and may not generalize to other periods, channels, or audiences.
4. **Threshold choice changes the trade-off.** Lower thresholds generally flag more videos and increase recall, while also increasing false positives.
5. **The feature set is limited.** It does not directly represent video quality, thumbnail design, audience demographics, competition, or changing platform behavior.
6. **Associations are not causal effects.** The model cannot establish that a feature causes better performance.
7. **Data quality and representativeness matter.** Missing values, duplicate records, category differences, and platform changes can affect reliability.
8. **The evaluation has limitations.** Threshold selection on the test set can make reported threshold-specific results optimistic; validation-set threshold selection and an untouched final test set would be stronger.
9. **Full-dataset scores are not independent predictions.** Scores for training records are generated by a model that has already seen their labels during training, so they should not be used to claim out-of-sample performance.

## 11. Tools and Libraries

The model implementation uses:

- Python
- pandas
- NumPy
- scikit-learn
- joblib

The broader project also uses PostgreSQL for business analysis and Power BI for dashboard reporting.

## 12. Model Artifacts and Outputs

The model artifacts are:

- `high_potential_logistic_model.pkl`
- `high_potential_preprocessor.pkl`

The scoring output is:

- `final_ai_scored_videos.csv`

The saved preprocessor must match the trained model. Before publication, confirm the canonical artifact locations and ensure that the committed files are from the corrected run. Avoid committing duplicate model artifacts without a clear reason.

## 13. Reproducibility

The intended workflow is:

1. Prepare and validate the input dataset.
2. Generate the model-development dataset and target label.
3. Convert Boolean-like fields explicitly to `0`/`1`.
4. Split the data into training and test sets using stratification.
5. Fit the preprocessing pipeline on training data.
6. Train the Logistic Regression model.
7. Evaluate performance on the held-out test set and compare thresholds.
8. Apply the fitted preprocessing pipeline and model to records selected for scoring.
9. Export predicted probabilities, priority bands, and the model-screening flag.

The training script currently uses local Windows paths. Update paths to project-relative paths or document the required local setup before claiming that the project is reproducible on another machine. Dependency versions should also be pinned for stronger reproducibility.

## 14. Conclusion

The corrected Logistic Regression baseline uses six publication and description features to estimate whether a video meets the project's high-engagement label.

On the held-out test set, it achieved **ROC-AUC 0.7040**. At the default threshold of 0.50, recall was **6.92%**. At the project's operational threshold of 0.35, it flagged **662 test videos**, with **49.55% precision**, **41.26% recall**, and an **F1-score of 0.4502**.

The model is best treated as an initial content-prioritization aid. Its outputs should be validated on new data and interpreted alongside broader content-performance analysis, not used as definitive predictions of success.
