from __future__ import annotations

from dagster import ScheduleDefinition

from .jobs import dlt_job

daily_schedule = ScheduleDefinition(
    job=dlt_job,
    cron_schedule="0 6 * * *",   # run DLT ingestion daily at 06:00 UTC
    execution_timezone="UTC",
)