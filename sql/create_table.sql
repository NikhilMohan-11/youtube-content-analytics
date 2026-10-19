CREATE TABLE videos_fact(
	video_id VARCHAR(20) PRIMARY KEY,
	trending_date DATE NOT NULL,
	title TEXT NOT NULL,
	channel_title VARCHAR(255) NOT NULL,
	views BIGINT NOT NULL CHECK (views >= 0),
	likes BIGINT NOT NULL CHECK (likes >= 0),
	dislikes BIGINT NOT NULL CHECK (dislikes >= 0),
	publish_time TIMESTAMP NOT NULL,
	category_id INTEGER NOT NULL,
	tags TEXT,
	comments BIGINT NOT NULL CHECK(comments >= 0),
	channel_id VARCHAR(100) NOT NULL,
	description TEXT,
	has_description BOOLEAN NOT NULL,
	description_length INTEGER NOT NULL CHECK (description_length >= 0),
	publish_date DATE NOT NULL,
	publish_hour SMALLINT NOT NULL CHECK (publish_hour BETWEEN 0 AND 23),
	publish_month SMALLINT NOT NULL CHECK (publish_month BETWEEN 1 AND 12),
	publish_day VARCHAR(15) NOT NULL,
	weekend_flag BOOLEAN NOT NULL,
	weekend_vs_weekday VARCHAR(10) NOT NULL,
	time_to_trend INTEGER NOT NULL CHECK (time_to_trend >= 0),
	engagement_rate NUMERIC(10,6) NOT NULL,
	like_ratio NUMERIC(10,6) NOT NULL,
	dislike_ratio NUMERIC(10,6) NOT NULL,
	category_name VARCHAR(100) NOT NULL
);

CREATE TABLE teams(
	team_id VARCHAR(20) PRIMARY KEY,
	channel_title VARCHAR(255) NOT NULL,
	department VARCHAR(50) NOT NULL,
	team_name VARCHAR(100) NOT NULL,
	team_size INTEGER NOT NULL CHECK (team_size > 0),
	average_experience NUMERIC(4,1) NOT NULL CHECK (average_experience >= 0)
);

CREATE TABLE content_team_mapping(
	mapping_id VARCHAR(20) PRIMARY KEY,
	video_id VARCHAR(20) NOT NULL,
	production_team_id VARCHAR(20) NOT NULL,
	editing_team_id VARCHAR(20) NOT NULL,
	marketing_team_id VARCHAR(20) NOT NULL,
	assignment_date DATE NOT NULL,
	completion_date DATE NOT NULL,
	production_days INTEGER NOT NULL CHECK (production_days >= 0),
	workload_level VARCHAR(20) NOT NULL,
	completion_status VARCHAR(30) NOT NULL,
	
	CONSTRAINT fk_video
		FOREIGN KEY (video_id)
        REFERENCES videos_fact(video_id),

    CONSTRAINT fk_production_team
        FOREIGN KEY (production_team_id)
        REFERENCES teams(team_id),

    CONSTRAINT fk_editing_team
        FOREIGN KEY (editing_team_id)
        REFERENCES teams(team_id),

    CONSTRAINT fk_marketing_team
        FOREIGN KEY (marketing_team_id)
        REFERENCES teams(team_id)
);

CREATE TABLE team_productivity(
	productivity_id VARCHAR(20) PRIMARY KEY,
	team_id VARCHAR(20) NOT NULL,
	month VARCHAR(7) NOT NULL CHECK (month ~ '^\d{4}-\d{2}$'),
	videos_assigned INTEGER NOT NULL CHECK (videos_assigned >= 0),
	videos_completed INTEGER NOT NULL CHECK (videos_completed >= 0),
	completion_rate NUMERIC(5,2) NOT NULL CHECK (completion_rate BETWEEN 0 AND 100),
	average_production_days NUMERIC(5,2) NOT NULL CHECK (average_production_days >= 0),
	editing_hours INTEGER NOT NULL CHECK (editing_hours >= 0),
	quality_score NUMERIC(5,2) NOT NULL CHECK (quality_score BETWEEN 0 AND 100),
	productivity_score NUMERIC(5,2) NOT NULL CHECK (productivity_score BETWEEN 0 AND 100),

	CONSTRAINT fk_team
		FOREIGN KEY (team_id)
        REFERENCES teams(team_id)
);

CREATE TABLE audience_feedback(
	feedback_id VARCHAR(20) PRIMARY KEY,
	video_id VARCHAR(20) NOT NULL,
	feedback_date DATE NOT NULL,
	sentiment_score NUMERIC(5,3) NOT NULL CHECK (sentiment_score BETWEEN -1 AND 1),
	audience_score NUMERIC(5,2) NOT NULL CHECK (audience_score BETWEEN 0 AND 100),
	positive_feedback_pct NUMERIC(5,2) NOT NULL CHECK (positive_feedback_pct BETWEEN 0 AND 100),
	negative_feedback_pct NUMERIC(5,2) NOT NULL CHECK (negative_feedback_pct BETWEEN 0 AND 100),
	engagement_band VARCHAR(20) NOT NULL,
	predicted_success VARCHAR(20) NOT NULL,
	CONSTRAINT fk_video
		FOREIGN KEY (video_id)
        REFERENCES videos_fact(video_id)
);









