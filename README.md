# Customer Experience Analytics — Ethiopian Banking Apps
**Omega Consultancy | 10 Academy Week 2 Challenge**

Scraping, analyzing, and visualizing Google Play Store reviews for three Ethiopian mobile banking apps:
Commercial Bank of Ethiopia (CBE), Bank of Abyssinia (BOA), and Dashen Bank.

---

## Project structure

```
fintech-review-analytics/
├── data/
│   ├── raw/              # scraped CSVs (git-ignored)
│   └── processed/        # cleaned + analysed data, plots
├── src/
│   ├── config.py         # app IDs, DB credentials, theme keywords
│   ├── scraper.py        # Task 1 — Google Play scraping
│   ├── preprocess.py     # Task 1 — cleaning & normalization
│   ├── sentiment.py      # Task 2 — distilBERT + VADER sentiment
│   ├── theme_extractor.py# Task 2 — keyword clustering & TF-IDF
│   ├── db_loader.py      # Task 3 — PostgreSQL insert
│   ├── visualize.py      # Task 4 — 5 plots + insight report
│   └── pipeline.py       # Run all tasks end-to-end
├── sql/
│   ├── schema.sql        # CREATE TABLE statements
│   └── queries.sql       # Verification + analytical queries
├── notebooks/            # Jupyter exploration
├── .env.example
├── .gitignore
└── requirements.txt
```

---

## Setup

```bash
git clone <your-repo-url>
cd fintech-review-analytics

python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate

pip install -r requirements.txt

# Copy and fill in your PostgreSQL credentials
cp .env.example .env
```

### `.env` format
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=bank_reviews
DB_USER=postgres
DB_PASSWORD=your_password
```

---

## Running the pipeline

### Full pipeline (all 4 tasks)
```bash
python src/pipeline.py
```

### Individual tasks
```bash
# Task 1 — scrape and clean
python src/scraper.py
python src/preprocess.py

# Task 2 — sentiment and themes
python src/sentiment.py
python src/theme_extractor.py

# Task 3 — load to PostgreSQL
psql -U postgres -c "CREATE DATABASE bank_reviews;"
psql -U postgres -d bank_reviews -f sql/schema.sql
python src/db_loader.py

# Task 4 — plots and report
python src/visualize.py
```

### Skip scraping (use existing data)
```bash
python src/pipeline.py --skip-scrape
```

---

## Methodology

### Data collection (Task 1)
- Library: `google-play-scraper`
- Language: `en`, Country: `et` (Ethiopia Play Store)
- Target: 450 reviews/bank (post-cleaning ≥400 each)
- Deduplication on `reviewId`, date normalized to `YYYY-MM-DD`
- Output columns: `review, rating, date, bank, source`

### Sentiment analysis (Task 2)
- Primary model: `distilbert-base-uncased-finetuned-sst-2-english`
- Comparison: VADER (`nltk.sentiment.vader`)
- Neutral threshold: scores below 0.65 on either label → Neutral
- Coverage target: ≥90% of reviews

### Thematic analysis (Task 2)
Five themes identified via keyword dictionary + TF-IDF validation:
1. **Account access issues** — login, OTP, session, locked
2. **Transaction performance** — slow, crash, transfer, timeout
3. **UI & experience** — interface, navigation, design, easy
4. **Customer support** — agent, response, help, resolved
5. **Feature requests** — fingerprint, dark mode, QR, budgeting

### Database (Task 3)
- PostgreSQL, database name: `bank_reviews`
- Tables: `banks`, `reviews` (per brief spec), `review_themes` (extension)
- Insert via `psycopg2.extras.execute_batch` for performance

### Visualizations (Task 4)
1. Sentiment distribution (grouped bar, count + %)
2. Average rating trend over time (line chart)
3. Theme × bank heatmap (% of reviews)
4. Top TF-IDF keywords per bank (horizontal bar)
5. Performance complaint rate (Scenario 1 — retention)

---

## Key findings

| Bank   | Avg ★ | Top pain point              | Top driver    |
|--------|-------|-----------------------------|---------------|
| CBE    | 4.2   | Transaction performance     | UI & experience |
| BOA    | 3.4   | Account access issues       | Feature requests |
| Dashen | 4.1   | Transaction performance     | UI & experience |

---

## Ethical considerations
- **Negative skew**: dissatisfied users review more, inflating negative counts.
- **Language gap**: English-only scraping misses Amharic-language reviews (majority).
- **Recency bias**: recent app updates may have resolved older complaints.
- **Prompted ratings**: banks sometimes prompt users to rate, skewing distributions.

---

## Team & timeline
| Milestone | Date |
|-----------|------|
| Challenge intro | Wed 26 Nov 2025 |
| Interim submission (task-1 + partial task-2) | Sun 30 Nov 2025, 20:00 UTC |
| Final submission (all tasks + report) | Tue 2 Dec 2025, 20:00 UTC |

Facilitators: Kerod · Mahbubah · Filimon  
Slack: `#all-week-2`
