from __future__ import annotations

from dagster import job, op

from .assets_dbt import run_dbt_build
from .assets_dlt import run_dlt_pipeline


@op
def dlt_op():
    run_dlt_pipeline()


@op
def dbt_op(context):
    run_dbt_build(context)


@job(name="dlt_pipeline_job")
def dlt_job():
    dlt_op()


@job(name="dbt_build_job")
def dbt_job():
    dbt_op()
