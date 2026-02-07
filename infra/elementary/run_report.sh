#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
DBT_DIR="$ROOT_DIR/dbt_marketing_perf"

cd "$DBT_DIR"

edr report \
  --profiles-dir . \
  --project-dir . \
  --open-browser false \
  --file-path "$DBT_DIR/edr_target/elementary_report.html"
