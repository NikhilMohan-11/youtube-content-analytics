import pandas as pd
import numpy as np

np.random.seed(42)

# --------------------------------------------------
# LOAD ORIGINAL DATA
# --------------------------------------------------

videos = pd.read_csv(
    r"D:\ai_powered_data_analyst\media_analytics\data\videos_fact.csv"
)

videos["publish_time"] = pd.to_datetime(videos["publish_time"])
videos["publish_date"] = videos["publish_time"].dt.normalize()

# --------------------------------------------------
# FEATURE CALCULATIONS
# --------------------------------------------------

videos["engagement_rate"] = np.where(
    videos["views"] == 0,
    0,
    (videos["likes"] + videos["comments"]) / videos["views"]
)

videos["dislike_ratio"] = np.where(
    (videos["likes"] + videos["dislikes"]) == 0,
    0,
    videos["dislikes"] /
    (videos["likes"] + videos["dislikes"])
)

mask = (
    (videos["views"] == 0) &
    (videos["likes"] == 0) &
    (videos["dislikes"] == 0) &
    (videos["comments"] == 0)
)

audience_feedback.loc[mask, "sentiment_score"] = 0
audience_feedback.loc[mask, "audience_score"] = 0
audience_feedback.loc[mask, "positive_feedback_pct"] = 0
audience_feedback.loc[mask, "negative_feedback_pct"] = 0
audience_feedback.loc[mask, "engagement_band"] = "Low"
audience_feedback.loc[mask, "predicted_success"] = "Low"

# --------------------------------------------------
# NORMALIZATION
# --------------------------------------------------

views_norm = (
    videos["views"] -
    videos["views"].min()
) / (
    videos["views"].max() -
    videos["views"].min()
)

likes_norm = (
    videos["likes"] -
    videos["likes"].min()
) / (
    videos["likes"].max() -
    videos["likes"].min()
)

comments_norm = (
    videos["comments"] -
    videos["comments"].min()
) / (
    videos["comments"].max() -
    videos["comments"].min()
)

# --------------------------------------------------
# SENTIMENT SCORE
# --------------------------------------------------

sentiment = (
    videos["engagement_rate"]*0.7
    -
    videos["dislike_ratio"]*0.3
)

sentiment = np.clip(sentiment,-1,1)

# --------------------------------------------------
# AUDIENCE SCORE
# --------------------------------------------------

audience_score = (
      0.40*views_norm
    + 0.30*likes_norm
    + 0.20*comments_norm
    + 0.10*((sentiment+1)/2)
)

audience_score = (
    audience_score*100
).round(2)

# --------------------------------------------------
# POSITIVE / NEGATIVE FEEDBACK
# --------------------------------------------------

positive_feedback = (
    50 +
    ((sentiment+1)/2)*50
).round(2)

negative_feedback = (
    100 -
    positive_feedback
).round(2)

# --------------------------------------------------
# ENGAGEMENT BAND
# --------------------------------------------------

q1 = videos["engagement_rate"].quantile(0.25)
q3 = videos["engagement_rate"].quantile(0.75)

def band(x):

    if x <= q1:
        return "Low"

    elif x >= q3:
        return "High"

    return "Medium"

engagement_band = videos["engagement_rate"].apply(band)

# --------------------------------------------------
# PREDICTED SUCCESS
# --------------------------------------------------

success = []

for score, senti in zip(audience_score,sentiment):

    if score >= 75 and senti >= 0.50:

        success.append("High")

    elif score >= 50:

        success.append("Moderate")

    else:

        success.append("Low")

# --------------------------------------------------
# FEEDBACK DATE
# --------------------------------------------------

feedback_date = (
    videos["publish_date"] +
    pd.to_timedelta(
        np.random.randint(1,8,len(videos)),
        unit="D"
    )
)

# --------------------------------------------------
# CREATE DATAFRAME
# --------------------------------------------------

audience_feedback = pd.DataFrame({

    "feedback_id":[
        f"FDB{i:06d}"
        for i in range(1,len(videos)+1)
    ],

    "video_id":videos["video_id"],

    "feedback_date":feedback_date,

    "sentiment_score":sentiment.round(3),

    "audience_score":audience_score,

    "positive_feedback_pct":positive_feedback,

    "negative_feedback_pct":negative_feedback,

    "engagement_band":engagement_band,

    "predicted_success":success

})

audience_feedback.to_csv(
    r"D:\ai_powered_data_analyst\media_analytics\data\synthetic\audience_feedback.csv",
    index=False
)

print("="*60)
print("AUDIENCE FEEDBACK VALIDATION")
print("="*60)

print(audience_feedback.head())
print()
print(audience_feedback.info())
print()
print(audience_feedback.describe(include="all"))
print()
print(audience_feedback.isnull().sum())
print()
print("Duplicate Rows:", audience_feedback.duplicated().sum())
print()
print("Unique Videos:", audience_feedback["video_id"].nunique())
print("Total Rows:", len(audience_feedback))

print("\nSentiment Distribution")
print(audience_feedback["sentiment_score"].describe())

print("\nAudience Score Distribution")
print(audience_feedback["audience_score"].describe())

print("\nPredicted Success")
print(audience_feedback["predicted_success"].value_counts())
