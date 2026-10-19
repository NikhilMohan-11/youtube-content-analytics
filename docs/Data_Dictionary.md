# Data Dictionary

This document describes the columns in the three main datasets used in the YouTube Content Analytics and High-Potential Content Prediction project.

## 1. `videos_fact.CSV`

**Purpose:** Main video-level analytical table containing source video information, engagement measures, publication features, category information, and engineered fields.

| Column | Description |
|---|---|
| `video_id` | Identifier for a video. |
| `trending_date` | Date associated with the video's trending record. |
| `title` | Video title. |
| `channel_title` | Display name of the channel that published the video. |
| `views` | Number of views recorded for the video. |
| `likes` | Number of likes recorded for the video. |
| `dislikes` | Number of dislikes recorded for the video. |
| `publish_time` | Timestamp when the video was published. |
| `category_id` | Numeric identifier for the video's category. |
| `tags` | Tags associated with the video. |
| `comments` | Number of comments recorded for the video. |
| `channel_id` | Identifier for the channel that published the video. |
| `description` | Video description text. |
| `has_description` | Indicator of whether a description is present. |
| `description_length` | Length of the video description, according to the project's feature-engineering logic. |
| `publish_date` | Publication date derived from `publish_time`. |
| `publish_hour` | Hour of the day when the video was published. |
| `publish_month` | Month of publication. |
| `publish_day` | Day-of-week value derived from the publication timestamp; the exact encoding depends on the preprocessing script. |
| `weekend_flag` | Indicator of whether publication occurred on a weekend. |
| `weekend_vs_weekday` | Weekend-versus-weekday grouping or comparison field created during feature engineering. Confirm its exact values in the preprocessing script or data. |
| `time_to_trend` | Time interval between publication and the trending record, as calculated by the project. Confirm the unit from the feature-engineering code. This is outcome-related and excluded from the model inputs to avoid target leakage. |
| `engagement_rate` | Engagement measure engineered from video interaction counts and views. Confirm the exact formula in the project code before quoting it in reports. |
| `like_ratio` | Engineered ratio involving likes; verify the exact formula and denominator in the project code before interpreting it. |
| `dislike_ratio` | Engineered ratio involving dislikes; verify the exact formula and denominator in the project code before interpreting it. |
| `category_name` | Readable category label corresponding to `category_id`. |

## 2. `mi_high_potential.csv`

**Purpose:** Model-development dataset containing selected input features and the `high_potential` target label.

| Column | Description |
|---|---|
| `video_id` | Identifier for the video; used to identify the record, not as a predictive feature. |
| `category_id` | Numeric video category identifier. |
| `publish_hour` | Hour of publication. |
| `publish_day` | Day-of-week feature derived from publication time. |
| `weekend_flag` | Indicator of weekend publication. |
| `has_description` | Indicator of whether a video description is present. |
| `description_length` | Length of the video description. |
| `high_potential` | Binary target label indicating whether the video meets the project's high-potential definition. The project defines high potential using the top quartile of engagement, with a reported threshold of 4.7433%. |

### Model input and target

The reported model inputs are `category_id`, `publish_hour`, `publish_day`, `weekend_flag`, `has_description`, and `description_length`.

`high_potential` is the target to predict. `video_id` is an identifier and should not be included as a predictive feature. `time_to_trend` is not present in this model dataset and should not be used as an input because it is related to the observed outcome.

## 3. `final_ai_scored_videos.csv`

**Purpose:** Video-level scoring output combining model input fields with the observed target label and model-generated scoring/triage fields.

| Column | Description |
|---|---|
| `video_id` | Identifier for the video. |
| `category_id` | Numeric video category identifier. |
| `publish_hour` | Hour of publication. |
| `publish_day` | Day-of-week feature derived from publication time. |
| `weekend_flag` | Indicator of weekend publication. |
| `has_description` | Indicator of whether a video description is present. |
| `description_length` | Length of the video description. |
| `high_potential` | Observed project label indicating whether the video meets the high-potential definition. This is not itself a model prediction. |
| `predicted_probability` | Model-estimated probability that the video belongs to the high-potential class. This is a score, not a guarantee of success. |
| `priority` | Priority band assigned by the project's scoring/triage logic. The exact band cutoffs are defined in the model script. |
| `model_flag` | Flag generated by the project's model-scoring logic. Its exact meaning and threshold should be taken from the model script. |

## Important interpretation notes

- **High potential is a project-defined label, not an objective guarantee of future performance.** It is based on the project's engagement threshold.
- **Predictions indicate association, not causation.** The model does not prove that changing a feature will cause a video to perform better.
- **The model's reported evaluation metrics come from a held-out test set.** Do not treat those metrics as a guarantee of performance on future videos.
- **Avoid target leakage.** `time_to_trend` is outcome-related and is not included among the stated model inputs.
- **Confirm formulas and encodings in code.** Column names alone do not establish the exact formulas for `engagement_rate`, `like_ratio`, and `dislike_ratio`; the unit of `time_to_trend`; the encoding of `publish_day`; or the thresholds used for `priority` and `model_flag`.
- **Distinguish source data from synthetic data.** Any audience-feedback or team-productivity tables generated by the project should be labelled synthetic/constructed, not real audience comments or employee measurements.
