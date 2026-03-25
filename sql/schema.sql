-- sql/schema.sql
-- Task 3: PostgreSQL schema for the bank_reviews database.
-- Run: psql -U postgres -d bank_reviews -f sql/schema.sql

-- Banks table (per brief spec)
CREATE TABLE IF NOT EXISTS banks (
    bank_id   SERIAL PRIMARY KEY,
    bank_name VARCHAR(100) NOT NULL UNIQUE,
    app_name  VARCHAR(200)
);

-- Reviews table (per brief spec — exact column names required)
CREATE TABLE IF NOT EXISTS reviews (
    review_id       VARCHAR(100) PRIMARY KEY,
    bank_id         INT NOT NULL REFERENCES banks(bank_id) ON DELETE CASCADE,
    review_text     TEXT,
    rating          SMALLINT CHECK (rating BETWEEN 1 AND 5),
    review_date     DATE,
    sentiment_label VARCHAR(20) CHECK (sentiment_label IN ('Positive', 'Negative', 'Neutral')),
    sentiment_score FLOAT CHECK (sentiment_score BETWEEN 0 AND 1),
    source          VARCHAR(50) DEFAULT 'Google Play'
);

-- Optional: theme analysis table (extends the brief schema)
CREATE TABLE IF NOT EXISTS review_themes (
    id              SERIAL PRIMARY KEY,
    review_id       VARCHAR(100) REFERENCES reviews(review_id) ON DELETE CASCADE,
    primary_theme   VARCHAR(80),
    all_themes      TEXT,   -- pipe-separated list
    created_at      TIMESTAMP DEFAULT NOW()
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_reviews_bank_id         ON reviews(bank_id);
CREATE INDEX IF NOT EXISTS idx_reviews_sentiment_label ON reviews(sentiment_label);
CREATE INDEX IF NOT EXISTS idx_reviews_rating          ON reviews(rating);
CREATE INDEX IF NOT EXISTS idx_reviews_review_date     ON reviews(review_date);
