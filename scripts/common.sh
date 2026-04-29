#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$ROOT_DIR/logs/system.log"
INDEX_FILE="$ROOT_DIR/master_index.csv"

timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

log() {
  mkdir -p "$ROOT_DIR/logs"
  echo "[$(timestamp)] [$1] $2" | tee -a "$LOG_FILE"
}

require_env() {
  local key="$1"
  if [[ -z "${!key:-}" ]]; then
    log ERROR "Missing required env var: $key"
    exit 1
  fi
}

ensure_index() {
  if [[ ! -f "$INDEX_FILE" ]]; then
    echo "category,filename,timestamp,description,monetization_status,bundle" > "$INDEX_FILE"
  fi
}

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

append_index() {
  ensure_index
  local category="$1" file="$2" desc="$3" status="$4" bundle="$5"
  echo "${category},${file},$(timestamp),\"${desc//"/\"}\",${status},${bundle}" >> "$INDEX_FILE"
}
