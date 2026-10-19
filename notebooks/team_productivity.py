import pandas as pd
import numpy as np

np.random.seed(42)

# --------------------------------------------------
# LOAD DATA
# --------------------------------------------------

teams = pd.read_csv(
    r"D:\ai_powered_data_analyst\media_analytics\data\synthetic\teams.csv"
)

mapping = pd.read_csv(
    r"D:\ai_powered_data_analyst\media_analytics\data\synthetic\content_team_mapping.csv"
)

mapping["assignment_date"] = pd.to_datetime(mapping["assignment_date"])

mapping["month"] = (
    mapping["assignment_date"]
    .dt.to_period("M")
    .astype(str)
)

# --------------------------------------------------
# USE ONLY PRODUCTION TEAM
# --------------------------------------------------

production = mapping.copy()

production = production.rename(
    columns={
        "production_team_id":"team_id"
    }
)

# --------------------------------------------------
# GROUP BY TEAM + MONTH
# --------------------------------------------------

records = []

for (team, month), group in production.groupby(
    ["team_id","month"]
):

    assigned = len(group)

    completed = (
        group["completion_status"]
        == "Completed"
    ).sum()

    completion_rate = completed / assigned

    avg_days = (
        group["production_days"]
        .mean()
    )

    editing_hours = (
        completed *
        np.random.randint(4,13)
    )

    quality_score = (
        80
        + completion_rate*20
        - (avg_days-5)
    )

    quality_score = np.clip(
        quality_score,
        60,
        100
    )

    speed_score = max(
        0,
        100
        -
        avg_days*3
    )

    productivity_score = (
        0.40*(completion_rate*100)
        +
        0.30*quality_score
        +
        0.30*speed_score
    )

    records.append({

        "productivity_id":
        f"PROD{len(records)+1:06d}",

        "team_id":
        team,

        "month":
        month,

        "videos_assigned":
        assigned,

        "videos_completed":
        completed,

        "completion_rate":
        round(completion_rate*100,2),

        "average_production_days":
        round(avg_days,2),

        "editing_hours":
        editing_hours,

        "quality_score":
        round(quality_score,2),

        "productivity_score":
        round(productivity_score,2)

    })

team_productivity = pd.DataFrame(records)
team_productivity.to_csv(
    r"D:\ai_powered_data_analyst\media_analytics\data\synthetic\team_productivity.csv",
    index=False
)

print("="*60)
print("TEAM PRODUCTIVITY VALIDATION")
print("="*60)

print(team_productivity.head())

print()

print(team_productivity.info())

print()

print(team_productivity.isnull().sum())

print()

print("Duplicate Rows:",
      team_productivity.duplicated().sum())

print()

print(team_productivity.describe())

print()

print("Unique Teams:",
      team_productivity["team_id"].nunique())

print()

print(team_productivity["month"].value_counts().sort_index())