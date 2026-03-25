-- sql/queries.sql
-- Task 3 & 4: Verification and analytical SQL queries.
-- Run against bank_reviews database after db_loader.py completes.

-- ── 1. Basic integrity checks ──────────────────────────────────────────────

-- Count reviews per bank
SELECT b.bank_name, COUNT(*) AS review_count
FROM reviews r
JOIN banks b USING (bank_id)
GROUP BY b.bank_name
ORDER BY review_count DESC;

-- Average rating per bank
SELECT b.bank_name,
       ROUND(AVG(r.rating)::numeric, 2) AS avg_rating,
       MIN(r.rating) AS min_rating,
       MAX(r.rating) AS max_rating
FROM reviews r
JOIN banks b USING (bank_id)
GROUP BY b.bank_name;

-- Date range coverage
SELECT b.bank_name,
       MIN(r.review_date) AS earliest,
       MAX(r.review_date) AS latest,
       COUNT(DISTINCT r.review_date) AS distinct_days
FROM reviews r
JOIN banks b USING (bank_id)
GROUP BY b.bank_name;


-- ── 2. Sentiment analysis queries ─────────────────────────────────────────

-- Sentiment distribution per bank (counts)
SELECT b.bank_name,
       r.sentiment_label,
       COUNT(*) AS count,
       ROUND(100.0 * COUNT(*) /
           SUM(COUNT(*)) OVER (PARTITION BY b.bank_name), 1) AS pct
FROM reviews r
JOIN banks b USING (bank_id)
GROUP BY b.bank_name, r.sentiment_label
ORDER BY b.bank_name, count DESC;

-- Mean sentiment score per bank × rating (scenario 1 — retention)
SELECT b.bank_name,
       r.rating,
       ROUND(AVG(r.sentiment_score)::numeric, 3) AS mean_sentiment_score,
       COUNT(*) AS n
FROM reviews r
JOIN banks b USING (bank_id)
GROUP BY b.bank_name, r.rating
ORDER BY b.bank_name, r.rating;

-- Most negative reviews (top 10) — for pain point extraction
SELECT b.bank_name, r.review_text, r.rating, r.sentiment_score
FROM reviews r
JOIN banks b USING (bank_id)
WHERE r.sentiment_label = 'Negative'
ORDER BY r.sentiment_score ASC
LIMIT 10;


-- ── 3. Thematic analysis queries ──────────────────────────────────────────

-- Theme distribution per bank
SELECT b.bank_name, t.primary_theme, COUNT(*) AS count
FROM review_themes t
JOIN reviews r USING (review_id)
JOIN banks b USING (bank_id)
GROUP BY b.bank_name, t.primary_theme
ORDER BY b.bank_name, count DESC;

-- Top pain-point themes for negative reviews (scenario 3 — complaints)
SELECT t.primary_theme,
       b.bank_name,
       COUNT(*) AS complaints,
       ROUND(100.0 * COUNT(*) /
           SUM(COUNT(*)) OVER (PARTITION BY b.bank_name), 1) AS pct_of_bank
FROM review_themes t
JOIN reviews r USING (review_id)
JOIN banks b USING (bank_id)
WHERE r.sentiment_label = 'Negative'
GROUP BY t.primary_theme, b.bank_name
ORDER BY b.bank_name, complaints DESC;

-- Theme vs rating: which themes correlate with low ratings?
SELECT t.primary_theme,
       ROUND(AVG(r.rating)::numeric, 2) AS avg_rating,
       COUNT(*) AS total_reviews
FROM review_themes t
JOIN reviews r USING (review_id)
GROUP BY t.primary_theme
ORDER BY avg_rating ASC;


-- ── 4. Scenario-specific queries ──────────────────────────────────────────

-- Scenario 1: Performance complaints as % of each bank's reviews
SELECT b.bank_name,
       COUNT(*) FILTER (WHERE t.primary_theme = 'Transaction performance'
                          AND r.sentiment_label = 'Negative')    AS perf_complaints,
       COUNT(*)                                                    AS total,
       ROUND(100.0 *
         COUNT(*) FILTER (WHERE t.primary_theme = 'Transaction performance'
                            AND r.sentiment_label = 'Negative') /
         COUNT(*), 1)                                             AS perf_complaint_pct
FROM reviews r
JOIN banks b USING (bank_id)
LEFT JOIN review_themes t USING (review_id)
GROUP BY b.bank_name
ORDER BY perf_complaint_pct DESC;

-- Scenario 2: Feature request volume per bank
SELECT b.bank_name,
       COUNT(*) AS feature_request_count
FROM review_themes t
JOIN reviews r USING (review_id)
JOIN banks b USING (bank_id)
WHERE t.primary_theme = 'Feature requests'
GROUP BY b.bank_name
ORDER BY feature_request_count DESC;

-- Scenario 3: Login/access complaint volume for chatbot prioritisation
SELECT b.bank_name,
       COUNT(*) AS access_complaints
FROM review_themes t
JOIN reviews r USING (review_id)
JOIN banks b USING (bank_id)
WHERE t.primary_theme = 'Account access issues'
  AND r.sentiment_label = 'Negative'
GROUP BY b.bank_name
ORDER BY access_complaints DESC;


-- ── 5. Cross-bank comparison summary (for report table) ───────────────────

SELECT b.bank_name,
       COUNT(r.review_id)                                          AS total_reviews,
       ROUND(AVG(r.rating)::numeric, 2)                           AS avg_star_rating,
       ROUND(100.0 * COUNT(*) FILTER (WHERE r.sentiment_label = 'Positive') /
             COUNT(*), 1)                                          AS positive_pct,
       ROUND(100.0 * COUNT(*) FILTER (WHERE r.sentiment_label = 'Negative') /
             COUNT(*), 1)                                          AS negative_pct,
       MODE() WITHIN GROUP (ORDER BY t.primary_theme)             AS top_theme
FROM reviews r
JOIN banks b USING (bank_id)
LEFT JOIN review_themes t USING (review_id)
GROUP BY b.bank_name
ORDER BY avg_star_rating DESC;
