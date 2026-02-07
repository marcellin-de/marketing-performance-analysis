# User Guide

## Daily Workflow

1. Run ingestion (DLT)
2. Run dbt build/test
3. Generate Elementary report
4. Review Metabase dashboard

## Commands

```bash
# DLT ingestion
python ingestion/filesystem_pipeline.py

# dbt build + tests
cd dbt_marketing_perf
DBT_PROFILES_DIR=. dbt deps
DBT_PROFILES_DIR=. dbt build

# Elementary report (local HTML)
../../infra/elementary/run_report.sh
```

## Where to Look

- dbt docs: `dbt docs generate` + `dbt docs serve`
- Elementary report: `dbt_marketing_perf/edr_target/elementary_report.html`
- Metabase dashboard: update exposure URL in `dbt_marketing_perf/models/exposures.yml`

## Dashboard Refresh

- Recommended schedule: daily after the Dagster job finishes.
- Configure in Metabase: Admin → Databases → sync & scan (or per-dashboard refresh).
