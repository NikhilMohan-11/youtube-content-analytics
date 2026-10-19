import pandas as pd

# Load ML dataset
df = pd.read_csv(
    "d:\\ai_powered_data_analyst\\media_analytics\\data\\synthetic\\mi_high_potential.csv"
)

# Basic inspection
print("Shape:", df.shape)

print("\nColumns:")
print(df.columns.tolist())

print("\nData types:")
print(df.dtypes)

print("\nFirst 5 rows:")
print(df.head())

# Check missing values
print("Missing values:")
print(df.isnull().sum())

# Check target distribution
print("\nTarget distribution:")
print(df["high_potential"].value_counts())

print("\nTarget percentage:")
print(
    df["high_potential"]
    .value_counts(normalize=True)
    .mul(100)
    .round(2)
)

# ============================================================
# Q4.11 — PREPARE FEATURES AND TARGET
# ============================================================

# Remove video_id because it is only an identifier
X = df.drop(columns=["video_id", "high_potential"])

# Target variable
y = df["high_potential"]

# Convert CSV Boolean-like values ('t'/'f') to 1/0
boolean_mapping = {
    "t": 1,
    "f": 0,
    "true": 1,
    "false": 0,
    "1": 1,
    "0": 0,
}

for col in ["weekend_flag", "has_description"]:
    values = df[col].astype(str).str.strip().str.lower()
    converted = values.map(boolean_mapping)

    if converted.isna().any():
        raise ValueError(
            f"Unexpected values in {col}: "
            f"{values[converted.isna()].unique()}"
        )

    X[col] = converted.astype(int)

print("\nBoolean feature verification:")
print(X[["weekend_flag", "has_description"]].value_counts())
print(X[["weekend_flag", "has_description"]].dtypes)

print("Features:")
print(X.head())

print("\nFeature data types:")
print(X.dtypes)

print("\nTarget:")
print(y.head())

print("\nFeature shape:", X.shape)
print("Target shape:", y.shape)


# ============================================================
# Q4.12 — TRAIN/TEST SPLIT + FEATURE ENCODING
# ============================================================

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder

# Categorical and numerical features
categorical_features = [
    "category_id",
    "publish_day"
]

numerical_features = [
    "publish_hour",
    "weekend_flag",
    "has_description",
    "description_length"
]

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)

# Encode categorical variables
preprocessor = ColumnTransformer(
    transformers=[
        (
            "categorical",
            OneHotEncoder(handle_unknown="ignore"),
            categorical_features
        )
    ],
    remainder="passthrough"
)

# Fit encoder ONLY on training data
X_train_encoded = preprocessor.fit_transform(X_train)

# Transform test data using the already-fitted encoder
X_test_encoded = preprocessor.transform(X_test)

print("Training samples:", X_train.shape[0])
print("Testing samples:", X_test.shape[0])

print("\nEncoded training shape:", X_train_encoded.shape)
print("Encoded testing shape:", X_test_encoded.shape)

print("\nTraining target distribution:")
print(y_train.value_counts())

print("\nTesting target distribution:")
print(y_test.value_counts())

# ============================================================
# Q4.13 — LOGISTIC REGRESSION BASELINE MODEL
# ============================================================

from sklearn.linear_model import LogisticRegression

# Create the model
logistic_model = LogisticRegression(
    max_iter=1000,
    random_state=42
)

# Train the model
logistic_model.fit(
    X_train_encoded,
    y_train
)

print("Logistic Regression model trained successfully.")

# ============================================================
# Q4.14 — MODEL EVALUATION
# ============================================================

from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score,
    confusion_matrix,
    classification_report
)

# Predictions
y_pred = logistic_model.predict(X_test_encoded)

# Probability of High Potential
y_probability = logistic_model.predict_proba(X_test_encoded)[:, 1]

# Evaluation metrics
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)
roc_auc = roc_auc_score(y_test, y_probability)

print("MODEL PERFORMANCE")
print("=" * 40)

print(f"Accuracy : {accuracy:.4f}")
print(f"Precision: {precision:.4f}")
print(f"Recall   : {recall:.4f}")
print(f"F1 Score : {f1:.4f}")
print(f"ROC-AUC  : {roc_auc:.4f}")

print("\nCONFUSION MATRIX")
print("=" * 40)

cm = confusion_matrix(y_test, y_pred)
print(cm)

print("\nCLASSIFICATION REPORT")
print("=" * 40)

print(classification_report(
    y_test,
    y_pred,
    target_names=["Normal Potential", "High Potential"]
))

# ============================================================
# Q4.15 — INSPECT PREDICTED PROBABILITIES
# ============================================================

import numpy as np

# Basic probability statistics
print("PREDICTED HIGH-POTENTIAL PROBABILITY")
print("=" * 50)

print(f"Minimum : {y_probability.min():.4f}")
print(f"Maximum : {y_probability.max():.4f}")
print(f"Mean    : {y_probability.mean():.4f}")
print(f"Median  : {np.median(y_probability):.4f}")

print("\nProbability percentiles:")

for percentile in [50, 60, 70, 75, 80, 90, 95, 99]:
    print(
        f"{percentile}th percentile: "
        f"{np.percentile(y_probability, percentile):.4f}"
    )

print("\nActual high-potential videos by probability range:")

probability_df = pd.DataFrame({
    "probability": y_probability,
    "actual": y_test.values
})

probability_df["probability_group"] = pd.cut(
    probability_df["probability"],
    bins=[0, 0.2, 0.4, 0.6, 0.8, 1.0],
    include_lowest=True
)

print(
    probability_df
    .groupby("probability_group", observed=False)["actual"]
    .agg(["count", "sum", "mean"])
)

# ============================================================
# Q4.16 — THRESHOLD ANALYSIS
# ============================================================

from sklearn.metrics import precision_score, recall_score, f1_score

thresholds = [0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50]

print(
    f"{'Threshold':<12}"
    f"{'Predicted High':<18}"
    f"{'Precision':<12}"
    f"{'Recall':<12}"
    f"{'F1 Score':<12}"
)

print("-" * 64)

for threshold in thresholds:

    predictions = (
        y_probability >= threshold
    ).astype(int)

    precision = precision_score(
        y_test,
        predictions,
        zero_division=0
    )

    recall = recall_score(
        y_test,
        predictions,
        zero_division=0
    )

    f1 = f1_score(
        y_test,
        predictions,
        zero_division=0
    )

    predicted_high = predictions.sum()

    print(
        f"{threshold:<12.2f}"
        f"{predicted_high:<18}"
        f"{precision:<12.4f}"
        f"{recall:<12.4f}"
        f"{f1:<12.4f}"
    )

# ============================================================
# Q4.17 — BUSINESS IMPACT OF 0.35 THRESHOLD
# ============================================================

threshold = 0.35

predictions = (y_probability >= threshold).astype(int)

results = pd.DataFrame({
    "actual": y_test.values,
    "predicted": predictions,
    "probability": y_probability
})

tp = ((results["actual"] == 1) & (results["predicted"] == 1)).sum()
fp = ((results["actual"] == 0) & (results["predicted"] == 1)).sum()
tn = ((results["actual"] == 0) & (results["predicted"] == 0)).sum()
fn = ((results["actual"] == 1) & (results["predicted"] == 0)).sum()

print("Threshold:", threshold)
print("True Positives:", tp)
print("False Positives:", fp)
print("True Negatives:", tn)
print("False Negatives:", fn)

print("\nTotal test videos:", len(results))
print("Videos flagged as high-potential:", predictions.sum())
print("Percentage flagged:", round(predictions.mean() * 100, 2))

print("\nActual high-potential videos captured:", tp)
print("Actual high-potential videos missed:", fn)

print(
    "Capture rate:",
    round(tp / (tp + fn) * 100, 2),
    "%"
)

# ============================================================
# Q4.18 — MODEL FEATURE EFFECTS
# ============================================================

feature_names = preprocessor.get_feature_names_out()

coefficients = logistic_model.coef_[0]

feature_effects = pd.DataFrame({
    "feature": feature_names,
    "coefficient": coefficients
})

feature_effects["abs_coefficient"] = (
    feature_effects["coefficient"].abs()
)

feature_effects = feature_effects.sort_values(
    "abs_coefficient",
    ascending=False
)

print(feature_effects.head(20).to_string(index=False))

# ============================================================
# Q4.19 — CREATE MODEL DECISION-SUPPORT OUTPUT
# ============================================================

decision_df = X_test.copy()

decision_df["actual_high_potential"] = y_test.values
decision_df["predicted_probability"] = y_probability

decision_df["priority"] = pd.cut(
    decision_df["predicted_probability"],
    bins=[0, 0.20, 0.40, 0.60, 1.00],
    labels=[
        "Low Priority",
        "Medium Priority",
        "High Priority",
        "Very High Priority"
    ],
    include_lowest=True
)

decision_df["model_flag"] = (
    decision_df["predicted_probability"] >= 0.35
).astype(int)

print(decision_df.head(10).to_string(index=False))

print("\nPriority distribution:")
print(
    decision_df["priority"]
    .value_counts()
    .sort_index()
)

print("\nModel-flagged videos:")
print(
    decision_df["model_flag"].value_counts()
)

# ============================================================
# Q4.20 — SAVE MODEL ARTIFACTS
# ============================================================

import joblib
import os

model_dir = "D:\\ai_powered_data_analyst\\media_analytics\\notebooks\\models"

os.makedirs(model_dir, exist_ok=True)

joblib.dump(
    preprocessor,
    os.path.join(model_dir, "high_potential_preprocessor.pkl")
)

joblib.dump(
    logistic_model,
    os.path.join(model_dir, "high_potential_logistic_model.pkl")
)

print("Model artifacts saved successfully:")
print("- high_potential_preprocessor.pkl")
print("- high_potential_logistic_model.pkl")

# ============================================================
# Q4.21 — REUSABLE CONTENT SCORING FUNCTION
# ============================================================

def score_content(
    category_id,
    publish_hour,
    publish_day,
    weekend_flag,
    has_description,
    description_length
):
    
    new_content = pd.DataFrame({
        "category_id": [category_id],
        "publish_hour": [publish_hour],
        "publish_day": [publish_day],
        "weekend_flag": [weekend_flag],
        "has_description": [has_description],
        "description_length": [description_length]
    })

    # Convert boolean values to integers
    for col in ["weekend_flag", "has_description"]:
        new_content[col] = (
            new_content[col]
            .astype(str)
            .str.strip()
            .str.lower()
            .map(boolean_mapping)
            )
        if new_content[col].isna().any():
            raise ValueError(f"Invalid Boolean value for {col}")
        
        new_content[col] = new_content[col].astype(int)

    # Apply the same preprocessing used during training
    encoded_content = preprocessor.transform(new_content)

    # Predict probability
    probability = logistic_model.predict_proba(
        encoded_content
    )[0, 1]

    # Assign priority
    if probability <= 0.20:
        priority = "Low Priority"
    elif probability <= 0.40:
        priority = "Medium Priority"
    elif probability <= 0.60:
        priority = "High Priority"
    else:
        priority = "Very High Priority"

    # Business screening flag
    model_flag = int(probability >= 0.35)

    return {
        "predicted_probability": round(probability, 4),
        "priority": priority,
        "model_flag": model_flag
    }


# ============================================================
# TEST THE FUNCTION
# ============================================================

test_result = score_content(
    category_id=28,          # Science & Technology
    publish_hour=18,
    publish_day="Wednesday",
    weekend_flag=False,
    has_description=True,
    description_length=80
)

print(test_result)

# ============================================================
# Q4.22 — SCORE THE COMPLETE DATASET
# ============================================================

# Copy the complete ML feature dataset
final_scored_df = X.copy()

# Generate probabilities for every video
final_scored_df["predicted_probability"] = (
    logistic_model.predict_proba(
        preprocessor.transform(X)
    )[:, 1]
)

# Assign content priority
final_scored_df["priority"] = pd.cut(
    final_scored_df["predicted_probability"],
    bins=[0, 0.20, 0.40, 0.60, 1.00],
    labels=[
        "Low Priority",
        "Medium Priority",
        "High Priority",
        "Very High Priority"
    ],
    include_lowest=True
)

# Model screening flag
final_scored_df["model_flag"] = (
    final_scored_df["predicted_probability"] >= 0.35
).astype(int)

print("Shape:", final_scored_df.shape)

print("\nColumns:")
print(final_scored_df.columns.tolist())

print("\nPriority distribution:")
print(
    final_scored_df["priority"]
    .value_counts()
    .sort_index()
)

print("\nModel flag distribution:")
print(
    final_scored_df["model_flag"]
    .value_counts()
)


# ============================================================
# Q4.23 — FINAL AI SCORING DATASET
# ============================================================

final_scored_df = X.copy()

# Restore video_id from the original ML dataset
final_scored_df.insert(
    0,
    "video_id",
    df.loc[X.index, "video_id"].values
)

# Keep the historical target for analysis/validation
final_scored_df["high_potential"] = y.values

# Generate model probability
final_scored_df["predicted_probability"] = (
    logistic_model.predict_proba(
        preprocessor.transform(X)
    )[:, 1]
)

# Convert probability into business priority
final_scored_df["priority"] = pd.cut(
    final_scored_df["predicted_probability"],
    bins=[0, 0.20, 0.40, 0.60, 1.00],
    labels=[
        "Low Priority",
        "Medium Priority",
        "High Priority",
        "Very High Priority"
    ],
    include_lowest=True
)

# Business screening flag
final_scored_df["model_flag"] = (
    final_scored_df["predicted_probability"] >= 0.35
).astype(int)

print("Shape:", final_scored_df.shape)

print("\nColumns:")
print(final_scored_df.columns.tolist())

print("\nFirst 5 rows:")
print(final_scored_df.head().to_string(index=False))

print("\nPriority distribution:")
print(
    final_scored_df["priority"]
    .value_counts()
    .sort_index()
)

# ============================================================
# Q4.24 — EXPORT FINAL AI SCORING DATASET
# ============================================================

output_path = "D:\\ai_powered_data_analyst\\media_analytics\\data\\final_ai_scored_videos.csv"

final_scored_df.to_csv(
    output_path,
    index=False
)

print("Final AI scoring dataset saved successfully:")
print(output_path)

print("\nRows:", len(final_scored_df))
print("Columns:", len(final_scored_df.columns))