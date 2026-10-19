import pandas as pd

file_path = "D:\\ai_powered_data_analyst\\media_analytics\\data\\US_Trending.csv"
df = pd.read_csv(file_path)
print(df.head())

print(df.info())
print(df.describe())
print(df.shape)

#Check for missing values
print(df.isnull().sum())

#Check for duplicates
print(df.duplicated().sum())

#handle missing values
# Drop rows with missing values
df.dropna(subset=['channel_title'], inplace=True)

#feature engineering
# Create a new feature 'has_description' to indicate whether a video has a description or not
df['has_description'] = df['description'].notnull().astype(int)
print(df['has_description'].value_counts())
df['description'].fillna('No description', inplace=True)

#length of description
df['description_length'] = df['description'].apply(lambda x: len(str(x)))
print(df['description_length'].value_counts())

#Convert publish_time to datetime
df['publish_time'] = pd.to_datetime(df['publish_time'], errors='coerce')
print(df['publish_time'].head())

# Convert the extracted date back to datetime format
df['publish_date'] = pd.to_datetime(df['publish_time'].dt.date)

# Print to verify the data type (it will show datetime64)
print(df['publish_date'].head())
print(df['publish_date'].dtype)


df['publish_hour'] = df['publish_time'].dt.hour
print(df['publish_hour'].value_counts())

df['publish_month'] = df['publish_date'].dt.month
print('Video published months names:', df['publish_month'].value_counts())

df['publish_day'] = df['publish_time'].dt.day_name()
print(df['publish_day'].value_counts())

df['weekend_flag'] = df['publish_day'].isin(['Saturday','Sunday'])
print(df['weekend_flag'].value_counts())

df['weekend_vs_weekday'] = df['weekend_flag'].map({True: 'Weekend', False: 'Weekday'})
print(df['weekend_vs_weekday'].value_counts())

#Convert trending_date to datetime
df['trending_date'] = pd.to_datetime(df['trending_date'], format='%y.%d.%m')

#Time taken to trend
df['time_to_trend'] = (df['trending_date'] - df['publish_date']).dt.days
print(df['time_to_trend'].head(10))

import numpy as np

df["engagement_rate"] = np.where(
    df["views"] > 0,
    (df["likes"] + df["comments"] + df["dislikes"]) / df["views"],
    0
)

df['like_ratio'] = np.where(
    df["views"] > 0,
    df["likes"] / df["views"],
    0
)

df['dislike_ratio'] = np.where(
    df["views"] > 0,
    df["dislikes"] / df["views"],
    0
)


#Category mapping
category_map = {
    1: 'Film & Animation',
    2: 'Autos & Vehicles',
    10: 'Music',
    15: 'Pets & Animals',
    17: 'Sports',
    19: 'Travel & Events',
    20: 'Gaming',
    22: 'People & Blogs',
    23: 'Comedy',
    24: 'Entertainment',
    25: 'News & Politics',
    26: 'Howto & Style',
    27: 'Education',
    28: 'Science & Technology',
    29: 'Nonprofits & Activism'
}

df['category_name'] = df['category_id'].map(category_map)
df[['category_id', 'category_name']].head(10)
print(df['category_name'].value_counts())

# Save the processed feature-engineered dataset

output_path = r"D:\ai_powered_data_analyst\media_analytics\data\videos_fact.csv"

df.to_csv(output_path, index=False)

print(f"Processed dataset saved successfully to:\n{output_path}")

#unique values of video id
print('Unique video ids:', df['video_id'].nunique())

