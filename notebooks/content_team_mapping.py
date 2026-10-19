import pandas as pd
import numpy as np

np.random.seed(42)

# ----------------------------------------------------------
# LOAD DATA
# ----------------------------------------------------------

videos = pd.read_csv(
    r"D:\ai_powered_data_analyst\media_analytics\data\videos_fact.csv"
)

teams = pd.read_csv(
    r"D:\ai_powered_data_analyst\media_analytics\data\synthetic\teams.csv"
)

# ----------------------------------------------------------
# PREPROCESS
# ----------------------------------------------------------

videos["publish_time"] = pd.to_datetime(videos["publish_time"])
videos["publish_date"] = pd.to_datetime(videos["publish_date"])

# ----------------------------------------------------------
# CHANNEL WORKLOAD
# ----------------------------------------------------------

channel_workload = (
    videos.groupby("channel_title")
    .size()
    .to_dict()
)

max_workload = max(channel_workload.values())

# ----------------------------------------------------------
# TEAM LOOKUP
# ----------------------------------------------------------

team_lookup = {}

for department in teams["department"].unique():

    dept = teams[teams["department"] == department]

    team_lookup[department] = (
        dept.groupby("channel_title")["team_id"]
        .apply(list)
        .to_dict()
    )

# ----------------------------------------------------------
# TEAM LOAD TRACKER
# ----------------------------------------------------------

team_load = {}

for team in teams["team_id"]:
    team_load[team] = 0


print("Videos:", videos["channel_title"].nunique())
print("Teams :", teams["channel_title"].nunique())

missing = (
    set(videos["channel_title"])
    - set(teams["channel_title"])
)

print("Missing Channels:", len(missing))

# ----------------------------------------------------------
# CREATE CONTENT MAPPING
# ----------------------------------------------------------

records = []

for i, row in videos.iterrows():

    channel = row["channel_title"]

    if channel not in team_lookup["Production"]:
        continue

    workload_ratio = channel_workload[channel] / max_workload

    # -------------------------
    # Balanced Team Assignment
    # -------------------------

    def assign_team(team_list):

        loads = [team_load[t] for t in team_list]

        minimum = min(loads)

        candidates = [
            t
            for t in team_list
            if team_load[t] == minimum
        ]

        chosen = np.random.choice(candidates)

        team_load[chosen] += 1

        return chosen

    production_team = assign_team(
        team_lookup["Production"][channel]
    )

    editing_team = assign_team(
        team_lookup["Editing"][channel]
    )

    marketing_team = assign_team(
        team_lookup["Marketing"][channel]
    )

    # -------------------------
    # Workload Category
    # -------------------------

    if workload_ratio < 0.30:

        workload_level = "Low"

        lead_days = np.random.randint(5,10)

        production_days = np.random.randint(2,6)

    elif workload_ratio < 0.70:

        workload_level = "Medium"

        lead_days = np.random.randint(10,20)

        production_days = np.random.randint(5,12)

    else:

        workload_level = "High"

        lead_days = np.random.randint(20,45)

        production_days = np.random.randint(10,25)

    assignment_date = (
        row["publish_date"]
        - pd.Timedelta(days=lead_days)
    )

    completion_date = (
        assignment_date
        + pd.Timedelta(days=production_days)
    )

    # -------------------------
    # Completion Status
    # -------------------------

    completed = max(
        0.60,
        0.90 - workload_ratio*0.25
    )

    delayed = min(
        0.30,
        0.05 + workload_ratio*0.20
    )

    in_progress = 1 - completed - delayed

    status = np.random.choice(
        ["Completed",
         "Delayed",
         "In Progress"],
        p=[
            completed,
            delayed,
            in_progress
        ]
    )

    records.append({

        "mapping_id":
        f"MAP{i+1:06d}",

        "video_id":
        row["video_id"],

        "production_team_id":
        production_team,

        "editing_team_id":
        editing_team,

        "marketing_team_id":
        marketing_team,

        "assignment_date":
        assignment_date,

        "completion_date":
        completion_date,

        "production_days":
        production_days,

        "workload_level":
        workload_level,

        "completion_status":
        status

    })

content_team_mapping = pd.DataFrame(records)

content_team_mapping.to_csv(
    r"D:\ai_powered_data_analyst\media_analytics\data\synthetic\content_team_mapping.csv",
    index=False
)

#validation

print("="*60)
print("CONTENT TEAM MAPPING VALIDATION")
print("="*60)

print(f"Rows                  : {len(content_team_mapping)}")
print(f"Unique Videos         : {content_team_mapping['video_id'].nunique()}")
print(f"Missing Values        :\n{content_team_mapping.isnull().sum()}")
print(f"Duplicate Rows        : {content_team_mapping.duplicated().sum()}")

print("\nCompletion Status")
print(content_team_mapping["completion_status"].value_counts())

print("\nWorkload Levels")
print(content_team_mapping["workload_level"].value_counts())

print("\nProduction Days")
print(content_team_mapping["production_days"].describe())

print("\nForeign Key Checks")
print("Production Team :", content_team_mapping["production_team_id"].isin(teams["team_id"]).all())
print("Editing Team    :", content_team_mapping["editing_team_id"].isin(teams["team_id"]).all())
print("Marketing Team  :", content_team_mapping["marketing_team_id"].isin(teams["team_id"]).all())