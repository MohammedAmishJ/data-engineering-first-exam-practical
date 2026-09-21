# UCI Bank Marketing Data Engineering Pipeline

## Overview

This project implements a complete data engineering pipeline using the **UCI Bank Marketing dataset**.

link: https://archive.ics.uci.edu/dataset/222/bank+marketing

The pipeline covers:

- Data extraction and ingestion using Python + dlt
- Raw data storage in PostgreSQL
- Data transformation using dbt
- Bronze, Silver, and Gold data layers
- Data quality testing and validation
- SQL analysis
- Query execution plan analysis
- Structured schema and record validation
- Rerun/idempotency validation

**Dataset:** UCI Bank Marketing  
**Dataset ID:** 222  
**Expected records:** 45,211

---

## Architecture

```text
UCI Machine Learning Repository
            │
            ▼
     Python + Requests
            │
            ▼
           dlt
            │
            ▼
   PostgreSQL - Raw Layer
            │
            ▼
      dbt - Bronze Layer
            │
            ▼
      dbt - Silver Layer
            │
            ▼
       dbt - Gold Layer
            │
            ▼
       SQL Analysis
            +
   Structured Validation
```

---

## Project Structure

```text
data-engineering-first-exam-practical/
│
├── ingestion/
│   └── bank_marketing.py
│
├── analysis/
│   ├── record_count.sql
│   ├── missing_values.sql
│   ├── duplicate_check.sql
│   ├── quality_indicator.sql
│   ├── execution_plan.sql
│   └── bank_marketing_validation.py
│
├── transformation/
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── bronze/
│   │   │   ├── stg_bank_marketing.sql
│   │   │   └── sources.yml
│   │   │
│   │   ├── silver/
│   │   │   ├── int_bank_marketing.sql
│   │   │   └── ...
│   │   │
│   │   └── gold/
│   │       ├── mart_bank_campaign_performance.sql
│   │       ├── mart_bank_customer_profile.sql
│   │       └── gold.yml
│   │
│   └── ...
│
├── .gitignore
├── requirements.txt
└── README.md
```

---

# Setup

## Requirements

- Python 3.13+
- PostgreSQL
- dbt Core
- Git

## Install dependencies

Create and activate a virtual environment:

```powershell
python -m venv .venv
.venv\Scripts\activate
```

Install Python dependencies:

```powershell
pip install -r requirements.txt
```

---

## Environment Variables

Create a `.env` file in the project root:

```text
DB_HOST=localhost
DB_PORT=5432
DB_NAME=first_practical_exam
DB_USER=postgres
DB_PASSWORD=your_password
```

Database credentials are not committed to Git.

dlt credentials are stored separately in the local dlt secrets configuration.

---

# Running the Pipeline

## 1. Ingest the data

Run:

```powershell
python ingestion/bank_marketing.py
```

The script:

1. Retrieves dataset metadata from the UCI API.
2. Validates the expected record count.
3. Validates the received record count.
4. Loads the data into PostgreSQL using dlt.

Expected result:

```text
Expected rows: 45211
Received rows: 45211
Row count validation passed.
```

The data is loaded into:

```text
raw.bank_marketing
```

The raw layer preserves the source data. dlt metadata columns are excluded from downstream models.

### Rerun validation

The ingestion uses:

```python
write_disposition="replace"
```

The ingestion was executed twice.

After the second run:

```text
Database records: 45,211
```

This confirms that rerunning the pipeline does not create duplicate records.

---

# 2. Run dbt

Navigate to the dbt project:

```powershell
cd transformation
```

Check the project:

```powershell
dbt debug
```

Build all models and tests:

```powershell
dbt build
```

The project contains three transformation layers:

```text
Raw → Bronze → Silver → Gold
```

---

# Data Layers

## Raw

Table:

```text
raw.bank_marketing
```

The raw layer contains the source dataset loaded directly from UCI.

Expected records:

```text
45,211
```

No business transformations are applied during ingestion.

---

## Bronze

Model:

```text
bronze.stg_bank_marketing
```

The Bronze layer:

- Selects the source columns
- Removes dlt metadata columns
- Renames `default` to `has_default`
- Otherwise preserves the source values

Bronze record count:

```text
45,211
```

Bronze tests include:

- Required fields are not null
- Target values are `yes` or `no`

---

## Silver

Model:

```text
silver.int_bank_marketing
```

The Silver layer performs data cleaning and normalization.

### Cleaning decisions

- Explicit numeric type casting
- Lowercase and trim categorical text
- Empty categorical values are represented as `unknown`
- `duration_minutes` is calculated from `duration`
- `y` is normalized into `subscription_status`
- `y` is also represented as a boolean `subscribed`
- `pdays = -1` is preserved and interpreted as `previously_contacted = false`

The original `pdays` value is not deleted.

The dataset does not contain a complete date field, so no artificial date was created.

The dataset is English, so Arabic text normalization is not applicable.

### Silver validation

The Silver layer contains tests covering:

- Null values
- Valid ranges
- Numeric consistency
- Duration conversion
- Subscription consistency
- Previous-contact consistency
- Text normalization
- Row count
- Duplicate detection

Latest Silver build:

```text
33/33 tests and models passed
0 warnings
0 errors
```

---

## Gold

Two analytical marts were created.

### Campaign Performance

```text
gold.mart_bank_campaign_performance
```

Provides aggregated information by:

- Job
- Month
- Contact method

Metrics include:

- Total clients
- Subscribed clients
- Subscription rate
- Average balance
- Average call duration
- Average campaign contacts

### Customer Profile

```text
gold.mart_bank_customer_profile
```

Provides aggregated information by:

- Job
- Marital status

Metrics include:

- Total clients
- Subscribed clients
- Subscription rate
- Average age
- Average balance

Gold validation:

```text
18/18 tests and models passed
0 warnings
0 errors
```

---

# Data Quality and Validation

## Record Count

Raw record count:

```text
45,211
```

Bronze record count:

```text
45,211
```

Silver record count:

```text
45,211
```

The transformation layers preserve the expected number of source records.

---

## Missing Values

Initial raw-data analysis found:

| Column | Missing Records |
|---|---:|
| age | 0 |
| job | 288 |
| marital | 0 |
| education | 1,857 |
| balance | 0 |
| y | 0 |

Missing categorical values are handled in the Silver layer using `unknown`.

---

## Duplicate Detection

Duplicate detection uses a SQL window function:

```sql
ROW_NUMBER() OVER (
    PARTITION BY
        age,
        job,
        marital,
        education,
        "default",
        balance,
        housing,
        loan,
        day_of_week,
        month,
        duration,
        campaign,
        pdays,
        previous,
        contact,
        poutcome,
        y
    ORDER BY _dlt_id
)
```

Duplicate records found:

```text
0
```

---

## Quality Indicator

The selected quality indicator is the subscription rate.

Results:

```text
Total records:       45,211
Subscribed records:   5,289
Subscription rate:   11.70%
```

---

# Query Execution Plan

The following query was analyzed using `EXPLAIN ANALYZE`:

```sql
SELECT
    job,
    COUNT(*) AS total_clients,
    AVG(balance) AS average_balance
FROM raw.bank_marketing
GROUP BY job;
```

Execution plan:

```text
Seq Scan → HashAggregate
```

Results:

```text
Rows scanned:      45,211
Planning time:      0.378 ms
Execution time:    21.537 ms
```

The query was already fast enough for the dataset size, so no optimization was required.

---

# Structured Validation

The script:

```text
analysis/bank_marketing_validation.py
```

performs deterministic validation of the raw dataset.

It validates:

- Required schema columns
- Age range
- Balance presence
- Duration range
- Campaign values
- `pdays` range
- Previous contact count
- Target values

Validation results:

```text
Schema validation: PASSED

Total records: 45211
Valid records: 45211
Rejected records: 0
Records requiring manual review: 0
```

---

# Data Quality Tests

The project contains more than the required five data-quality cases across the dbt layers.

Examples include:

1. Required fields are not null.
2. Target values must be `yes` or `no`.
3. Age must be within a valid range.
4. Numeric fields must satisfy valid ranges.
5. Duration conversion must be consistent.
6. Subscription status must match the boolean field.
7. Previous-contact status must match `pdays`.
8. Categorical values are normalized.
9. Row count remains consistent.
10. Duplicate records are detected using a window function.

## Data Quality Test Cases

| Test Case | Input | Expected | Actual |
|---|---|---|---|
| Required fields | Raw Bank Marketing records | Required fields contain no nulls | Passed |
| Target values | `y` column | Only `yes` or `no` | Passed |
| Age range | `age` column | Values between 18 and 100 | Passed |
| Numeric ranges | `duration`, `campaign`, `pdays`, `previous` | Values satisfy defined ranges | Passed |
| Subscription consistency | `y` and `subscribed` | Values must agree | Passed |
| Previous-contact consistency | `pdays` and `previously_contacted` | Values must agree | Passed |
| Text normalization | Categorical columns | Trimmed and lowercase | Passed |
| Duplicate detection | All semantic source fields | 0 duplicate records | 0 duplicates |
| Row count | Raw vs Silver | 45,211 records preserved | 45,211 |

---

# Reproducibility

The pipeline is designed to be rerunnable.

Running:

```powershell
python ingestion/bank_marketing.py
```

again replaces the existing raw table instead of appending another copy.

The rerun was tested successfully:

```text
Expected rows: 45211
Received rows: 45211
Database count after rerun: 45211
```

No duplicate records were introduced.

---

# Cleaning and Exclusion Decisions

The following decisions were made during transformation:

- dlt metadata columns are excluded from analytical models.
- Source categorical text is trimmed and lowercased.
- Empty categorical values are represented as `unknown`.
- Numeric fields are explicitly cast.
- `duration_minutes` is derived from the original duration.
- `pdays = -1` is preserved because it is meaningful in the source dataset.
- No artificial dates were created because the source does not provide enough information to construct a complete date.
- No physical records were deleted during cleaning.

---

# Final Results

The completed pipeline successfully:

- Extracts the official UCI Bank Marketing dataset.
- Validates source completeness.
- Loads **45,211 records** into PostgreSQL.
- Transforms the data through Bronze, Silver, and Gold dbt layers.
- Applies data quality and consistency tests.
- Produces analytical Gold marts.
- Performs SQL analysis and duplicate detection.
- Validates the execution plan.
- Performs deterministic structured validation.
- Successfully reruns without creating duplicates.
