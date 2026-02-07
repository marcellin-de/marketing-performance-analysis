# Marketing Performance Analysis

End‑to‑end analytics stack for the Maven Fuzzy Factory e‑commerce dataset (teddy bears). This repo ingests CSVs with DLT, transforms with dbt, orchestrates with Dagster, and serves KPIs for a Metabase dashboard.

## What This Project Answers
- Trend of website sessions and orders
- Session‑to‑order conversion rate over time
- Best performing marketing channels
- Revenue per order and per session

## Repository Structure
- `data/` – raw CSVs (sessions, pageviews, orders, items, refunds, products)
- `ingestion/` – DLT pipeline (CSV → Snowflake `raw` schema)
- `dbt_marketing_perf/` – dbt project (staging → intermediate → marts + tests)
- `infra/` – orchestration (Dagster) + Elementary report helper
- `dashboard/` – Metabase dashboard export
- `docs/` – runbooks, optimization notes, KT checklist

## Quick Start (Local)

### 1) Python environment
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2) Ingest data (DLT)
```bash
python ingestion/filesystem_pipeline.py
```

### 3) dbt build + tests
```bash
cd dbt_marketing_perf
DBT_PROFILES_DIR=. dbt deps
DBT_PROFILES_DIR=. dbt build
```

### 4) dbt docs
```bash
DBT_PROFILES_DIR=. dbt docs generate
DBT_PROFILES_DIR=. dbt docs serve
```

### 5) Elementary report (local HTML)
```bash
./infra/elementary/run_report.sh
```

## Orchestration (Dagster)
Event‑driven: **DLT → dbt** via run status sensor.

```bash
cd infra
# Start Dagster UI
DAGSTER_HOME=$(pwd)/.dagster dagster dev -w dagster_project/workspace.yaml
```

Jobs:
- `dlt_pipeline_job`
- `dbt_build_job` (triggered automatically on DLT success)

## dbt Project Highlights
- **Layers**: staging → intermediate → marts (core + kpis)
- **Incremental**: facts + KPI marts
- **Tests**: dbt_utils, dbt_expectations, Elementary schema change monitoring
- **Exposures**: Metabase dashboard + analysis artifacts

Key models:
- `marts/core/fct_sessions`, `fct_orders`, `fct_order_items`, `fct_refunds`
- `marts/kpis/kpi_daily_marketing_channels`, `kpi_daily_overview`

## Metabase Dashboard
Public link (local):
- `http://localhost:3000/public/dashboard/998d3922-02d0-44d4-8fcc-4a863cee58a4`

## CI/CD (GitHub Actions)
- `develop` → `dbt build --target dev`
- `main` → `dbt build --target prod`

Workflows:
- `.github/workflows/dbt_ci_dev.yml`
- `.github/workflows/dbt_ci_prod.yml`

## Configuration Notes
- **Snowflake** credentials are read from environment variables (see `dbt_marketing_perf/profiles.yml`).
- **DLT** reads config from `ingestion/.dlt/` (or `infra/.dlt/` if running Dagster locally).
- For production, use secrets manager or CI secrets. Do not hardcode credentials.

## Documentation
- `docs/user_guide.md` – how to run the pipeline
- `docs/ops_optimization.md` – Snowflake optimization guidance
- `docs/kt_checklist.md` – knowledge transfer checklist

## Suggested Workflow
1. DLT ingestion
2. dbt build/tests
3. Elementary report
4. Review Metabase KPIs

---
If you want this README to include architecture diagrams, SLA/ownership, or deployment steps, tell me and I’ll add them.

## Architecture (High Level)
```
CSV files (data/)
        |
        v
     DLT ingestion
        |
        v
Snowflake (raw schema)
        |
        v
dbt (staging -> intermediate -> marts)
        |
        v
KPI tables + exposures
        |
        +--> Elementary report (HTML)
        |
        +--> Metabase dashboard
```

## SLA and Ownership
- **Ingestion SLA**: daily by 06:00 UTC (Dagster schedule)
- **Transform SLA**: completes within 30 minutes after ingestion
- **Data Quality**: dbt tests + Elementary schema change monitoring
- **Owner**: Analytics Engineering (update owners in `dbt_marketing_perf/models/exposures.yml`)
- **On‑call / escalation**: document in `docs/kt_checklist.md` or your internal runbook

## Deployment Steps (Prod)

1) **Provision Snowflake**
- Create warehouse, database, schemas (`raw`, `staging`, `intermediate`, `marts`, `ELEMENTARY`)
- Grant least‑privilege roles to the service account

2) **Configure Secrets**
- GitHub Actions secrets for Snowflake (`SNOWFLAKE_*`)
- DLT secrets in a secret manager or runtime env (avoid plaintext files)

3) **Deploy Orchestration (Dagster)**
- Containerize `infra/dagster_project` or deploy on your platform
- Set `DAGSTER_HOME` to persistent storage
- Enable schedule and sensors

4) **Run Initial Backfill**
- Trigger `dlt_pipeline_job`
- Run `dbt build --target prod`
- Generate Elementary report

5) **Deploy Metabase**
- Point to `marts` schema
- Configure dashboard refresh after dbt completion

6) **Enable CI/CD**
- `develop` → dev checks
- `main` → prod dbt build
