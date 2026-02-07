from __future__ import annotations

from pathlib import Path

from dagster_dbt import DbtCliResource, dbt_assets

DBT_PROJECT_DIR = Path(__file__).resolve().parents[3] / "dbt_marketing_perf"
DBT_PROFILES_DIR = DBT_PROJECT_DIR
DBT_MANIFEST_PATH = DBT_PROJECT_DIR / "target" / "manifest.json"


dbt_cli = DbtCliResource(project_dir=str(DBT_PROJECT_DIR), profiles_dir=str(DBT_PROFILES_DIR))


@dbt_assets(
    manifest=DBT_MANIFEST_PATH,
)
def dbt_assets(context):
    """Run dbt build for all models and tests after ingestion."""
    yield from dbt_cli.cli(["build"], context=context).stream()


def run_dbt_build(context):
    """Helper for running dbt build in jobs or assets."""
    # Use wait() to avoid asset-event parsing that requires manifest["nodes"]
    dbt_cli.cli(["build"], context=context).wait()
