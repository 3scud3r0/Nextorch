#!/usr/bin/env bash
# Linux x86_64, Python 3.12: tested cloud environment installation.
set -euo pipefail
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_ROOT="${NEXTORCH_TOOLS_DIR:-$(dirname "$PROJECT_ROOT")/.tools}"
cd "$PROJECT_ROOT"
python3 -c 'import sys; assert sys.version_info[:2] == (3, 12), "The CPU lock requires Python 3.12; see README for other versions"'
python3 -m venv .venv
PYTHON_BIN="$PROJECT_ROOT/.venv/bin/python"
"$PYTHON_BIN" -m pip install --cache-dir "$(dirname "$PROJECT_ROOT")/.cache/pip" \
  --index-url https://download.pytorch.org/whl/cpu 'torch==2.5.1'
"$PYTHON_BIN" -m pip install --cache-dir "$(dirname "$PROJECT_ROOT")/.cache/pip" -r requirements/cpu-py312.lock
"$PYTHON_BIN" -m pip install --no-deps --no-build-isolation -e .
if [[ "${NEXTORCH_INSTALL_LEAN:-1}" == 1 ]]; then
  if [[ -x "$TOOLS_ROOT/lean/bin/lean" ]]; then
    "$TOOLS_ROOT/lean/bin/lean" --version | grep -F 'version 4.19.0'
  else
    [[ "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]] || {
      echo 'Pinned Lean binary requires Linux x86_64. Set NEXTORCH_INSTALL_LEAN=0 and provide Lean manually.' >&2
      exit 1
    }
    mkdir -p "$TOOLS_ROOT"
    LEAN_TEMP="$(mktemp -d)"
    trap 'rm -rf "$LEAN_TEMP"' EXIT
    curl --fail --show-error --location --proto '=https' --tlsv1.2 \
      https://github.com/leanprover/lean4/releases/download/v4.19.0/lean-4.19.0-linux.tar.zst \
      -o "$LEAN_TEMP/lean.tar.zst"
    (cd "$LEAN_TEMP" && echo '6fe3ce97a58f44e2b3567d455b994eacec5bfe9ae7774f2a573444480ba813fe  lean.tar.zst' | sha256sum --check --strict)
    tar --zstd -xf "$LEAN_TEMP/lean.tar.zst" -C "$LEAN_TEMP"
    # Avoid overwriting any pre-existing directory owned by the user.
    [[ ! -e "$TOOLS_ROOT/lean" ]] || { echo "$TOOLS_ROOT/lean already exists" >&2; exit 1; }
    mv "$LEAN_TEMP/lean-4.19.0-linux" "$TOOLS_ROOT/lean"
  fi
fi
"$PYTHON_BIN" -m pip check
printf 'Nextorch installed. Run scripts/test.sh and .venv/bin/nextorch demo --lean\n'
