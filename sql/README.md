# sql — database schema & verification queries

This folder contains SQL artifacts used to create and validate the project database.

- `schema.sql` — CREATE TABLE statements for `banks`, `reviews`, and related tables.
- `queries.sql` — verification and analytical queries used to spot-check ingested data.

Quick start

1. Create the database (Postgres):

```bash
psql -U postgres -c "CREATE DATABASE bank_reviews;"
psql -U postgres -d bank_reviews -f sql/schema.sql
```

2. After loading data, run `queries.sql` to validate counts and some analytics:

```bash
psql -U postgres -d bank_reviews -f sql/queries.sql
```
