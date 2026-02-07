from __future__ import annotations

from dagster import Definitions

from .assets_dlt import dlt_pipeline
from .assets_dbt import dbt_assets
from .jobs import dlt_job, dbt_job
from .schedules import daily_schedule
from .sensors import data_quality_failure_sensor, trigger_dbt_on_dlt_success

defs = Definitions(
    assets=[dlt_pipeline, dbt_assets],
    jobs=[dlt_job, dbt_job],
    schedules=[daily_schedule],
    sensors=[trigger_dbt_on_dlt_success, data_quality_failure_sensor],
)