from __future__ import annotations

from dagster import (
    DagsterRunStatus,
    DefaultSensorStatus,
    RunRequest,
    RunStatusSensorContext,
    run_status_sensor,
)

from .jobs import dlt_job, dbt_job


@run_status_sensor(
    run_status=DagsterRunStatus.SUCCESS,
    request_job=dbt_job,              # trigger dbt
    monitored_jobs=[dlt_job],         # only watch DLT ingestion
    default_status=DefaultSensorStatus.RUNNING,
)
def trigger_dbt_on_dlt_success(context: RunStatusSensorContext):
    """Event-driven orchestration: trigger dbt after successful DLT ingestion."""
    return RunRequest(run_key=f"dbt_after_{context.dagster_run.run_id}")


@run_status_sensor(
    run_status=DagsterRunStatus.FAILURE,
    monitored_jobs=[dlt_job, dbt_job],   # monitor both ingestion and dbt
    default_status=DefaultSensorStatus.RUNNING,
)
def data_quality_failure_sensor(context: RunStatusSensorContext):
    """Emit an alert event when ingestion or dbt fails (data quality signal)."""
    context.log.warning(
        "Pipeline failed. Review DLT ingestion, dbt build/tests, and data freshness."
    )