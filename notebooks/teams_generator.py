import pandas as pd
import numpy as np

file_path = "d:\\ai_powered_data_analyst\\media_analytics\\data\\videos_fact.csv"
df = pd.read_csv(file_path)

df['engagement_rate'] = (df['likes'] + df['dislikes'] + df['comments']) / df['views']
# STEP 1: Calculate Channel Statistics
channel_stats = (
    df.groupby("channel_title")
      .agg(
          total_videos=("video_id", "count"),
          total_views=("views", "sum"),
          avg_views=("views", "mean"),
          avg_engagement=("engagement_rate", "mean")
      )
      .reset_index()
)

# STEP 2: Create Channel Size Score

channel_stats["video_score"] = (
    channel_stats["total_videos"]
    / channel_stats["total_videos"].max()
)

channel_stats["view_score"] = (
    channel_stats["total_views"]
    / channel_stats["total_views"].max()
)

channel_stats["engagement_score"] = (
    channel_stats["avg_engagement"]
    / channel_stats["avg_engagement"].max()
)

channel_stats["channel_size_score"] = (
      0.4 * channel_stats["video_score"]
    + 0.4 * channel_stats["view_score"]
    + 0.2 * channel_stats["engagement_score"]
)

# STEP 3: Assign Team Size

def assign_team_size(score):

    if score < 0.20:
        return 3

    elif score < 0.40:
        return 5

    elif score < 0.60:
        return 8

    elif score < 0.80:
        return 12

    else:
        return 18
    

# STEP 4: Assign Average Experience

def assign_experience(score):

    if score < 0.20:
        return np.random.randint(2, 5)

    elif score < 0.40:
        return np.random.randint(3, 6)

    elif score < 0.60:
        return np.random.randint(4, 8)

    elif score < 0.80:
        return np.random.randint(6, 10)

    else:
        return np.random.randint(8, 15)
    
# --------------------------------------------------
# STEP 5 : Create Teams Table
# --------------------------------------------------

def get_team_structure(score):

    if score < 0.20:

        return {
            "Production":1,
            "Editing":1,
            "Marketing":1,
            "Content Strategy":1
        }

    elif score < 0.60:

        return {
            "Production":2,
            "Editing":2,
            "Marketing":1,
            "Content Strategy":1
        }

    else:

        return {
            "Production":4,
            "Editing":3,
            "Marketing":2,
            "Content Strategy":2
        }


team_records = []

team_counter = 1

for _, row in channel_stats.iterrows():

    channel = row["channel_title"]

    score = row["channel_size_score"]

    structure = get_team_structure(score)

    avg_experience = assign_experience(score)

    base_size = assign_team_size(score)

    for department, number_of_teams in structure.items():

        for team_no in range(1, number_of_teams + 1):

            team_records.append({

                "team_id":
                f"TEAM{team_counter:05d}",

                "channel_title":
                channel,

                "department":
                department,

                "team_name":
                f"{department} Team {team_no}",

                "team_size":
                base_size,

                "average_experience":
                avg_experience

            })

            team_counter += 1

# STEP 6: Create DataFrame

teams_df = pd.DataFrame(team_records)

# STEP 7: Save CSV

teams_df.to_csv(
    "D:\\ai_powered_data_analyst\\media_analytics\\data\\synthetic\\teams.csv",
    index=False
)

print("Teams table created successfully!")
print(teams_df.head())

print(teams_df.info())
print(teams_df.describe())

print("=" * 50)
print("TEAMS TABLE VALIDATION")
print("=" * 50)

print(f"Original Channels : {df['channel_title'].nunique()}")
print(f"Synthetic Channels: {teams_df['channel_title'].nunique()}")

original_channels = set(df['channel_title'].unique())
synthetic_channels = set(teams_df['channel_title'].unique())

print(f"Missing Channels  : {len(original_channels - synthetic_channels)}")
print(f"Extra Channels    : {len(synthetic_channels - original_channels)}")

print("\nTeams per Channel")
teams_per_channel = teams_df.groupby('channel_title').size().reset_index(name='team_count')
print(teams_per_channel["team_count"].value_counts())

print("\nDepartments per Channel")
department_check = teams_df.groupby('channel_title')['department'].nunique()
print(department_check.value_counts())

print(teams_df.isnull().sum())
print(teams_df.duplicated().sum())
print("Departments:", teams_df['department'].unique())