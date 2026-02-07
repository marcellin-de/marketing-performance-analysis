# Snowflake Optimization Notes

## Query & Warehouse Recommendations

- Use the smallest warehouse that meets SLAs; scale up only for backfills.
- Prefer incremental models for large fact tables (sessions, orders, order items).
- Partition heavy aggregates by date and use date filters in dashboards.
- Avoid full table scans in BI: always apply `date_day` filters in Metabase.

## Monitoring

- Track dbt run times and warehouse credits.
- Watch for spikes in daily row counts (Elementary report).
