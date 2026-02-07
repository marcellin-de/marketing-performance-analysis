from __future__ import annotations

import os
from pathlib import Path

from dagster import asset, Output
import dlt

from ingestion.filesystem_pipeline import marketing_performance_source


def run_dlt_pipeline():
    """Run the DLT pipeline that loads raw CSVs into Snowflake."""
    repo_root = Path(__file__).resolve().parents[3]
    dlt_config_dir = repo_root / "ingestion" / ".dlt"

    # Ensure DLT reads configs/secrets from the ingestion directory
    os.environ.setdefault("DLT_CONFIG_DIR", str(dlt_config_dir))

    pipeline = dlt.pipeline(
        pipeline_name="maven_fuzzy_factory",
        destination="snowflake",
        dataset_name="raw",
    )

    return pipeline, pipeline.run(marketing_performance_source())


@asset(name="dlt_pipeline", group_name="ingestion", compute_kind="dlt")
def dlt_pipeline():
    pipeline, load_info = run_dlt_pipeline()

    # Keep metadata minimal to avoid version-specific LoadInfo attributes.
    return Output(
        {"status": "success"},
        metadata={"pipeline": pipeline.pipeline_name, "load_info": str(load_info)},
    )
