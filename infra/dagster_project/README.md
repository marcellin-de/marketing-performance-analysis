# Dagster Orchestration

This Dagster project orchestrates the DLT ingestion pipeline and dbt build/test.

## Setup

1. Create a virtual environment and install requirements:

```bash
python -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

2. Generate a dbt manifest (required by dagster-dbt):

```bash
cd ../../dbt_marketing_perf
DBT_PROFILES_DIR=. dbt deps
DBT_PROFILES_DIR=. dbt parse
```

3. Start Dagster:

```bash
cd ../infra/dagster_project
DAGSTER_HOME=$(pwd)/.dagster dagster dev
```

## Notes

- The dbt assets depend on the `dlt_pipeline` asset.
- Schedule: daily at 06:00 UTC.
- Data quality sensor logs a warning on pipeline failures.
