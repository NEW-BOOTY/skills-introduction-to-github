#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT_DIR/scripts/env.sh"
source "$ROOT_DIR/scripts/common.sh"

run_module() {
  local cmd="$1"
  if bash -lc "$cmd"; then
    log INFO "Module succeeded: $cmd"
  else
    log ERROR "Module failed: $cmd. Retrying in 5s"
    sleep 5
    bash -lc "$cmd" || log ERROR "Module retry failed: $cmd"
  fi
}

log INFO "Orchestrator started"
while true; do
  run_module "$ROOT_DIR/generate_prompt.sh business"
  run_module "$ROOT_DIR/generate_prompt.sh marketing"
  run_module "$ROOT_DIR/generate_image.sh art"
  run_module "$ROOT_DIR/generate_code.sh dev"
  run_module "$ROOT_DIR/categorize.sh"
  run_module "$ROOT_DIR/monetize.sh"
  sleep "${LOOP_INTERVAL_SECONDS:-300}"
done
