#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}"
export MPLCONFIGDIR="${MPLCONFIGDIR:-$PROJECT_ROOT/artifacts/matplotlib}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$PROJECT_ROOT/artifacts/cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$PROJECT_ROOT/artifacts/config}"
if [[ -x "${NEXTORCH_TOOLS_DIR:-$(dirname "$PROJECT_ROOT")/.tools}/lean/bin/lean" ]]; then
  export NEXTORCH_LEAN="${NEXTORCH_LEAN:-${NEXTORCH_TOOLS_DIR:-$(dirname "$PROJECT_ROOT")/.tools}/lean/bin/lean}"
fi
.venv/bin/ruff check nextorch tests examples
.venv/bin/ruff format --check nextorch tests examples
.venv/bin/python -m pytest --cov=nextorch --cov-report=term-missing --cov-report=json:artifacts/coverage.json "$@"
