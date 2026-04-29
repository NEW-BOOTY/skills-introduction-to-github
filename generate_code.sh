#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT_DIR/scripts/env.sh"
source "$ROOT_DIR/scripts/common.sh"
source "$ROOT_DIR/scripts/api.sh"

category="${1:-dev}"
out_dir="$ROOT_DIR/code/$category"
mkdir -p "$out_dir"

payload=$(openai_chat "$CODE_MODEL" "Generate one original, useful micro-utility. Return JSON keys: name,description,language,filename,code. Code must be complete and runnable.")
name=$(echo "$payload" | jq -r '.name')
filename=$(echo "$payload" | jq -r '.filename')
code=$(echo "$payload" | jq -r '.code')
file_base="$(date +%s)-$(slugify "$name")"
out_file="$out_dir/${file_base}-${filename}"
printf '%s\n' "$code" > "$out_file"
chmod +x "$out_file" 2>/dev/null || true
meta_file="$out_dir/${file_base}.json"
echo "$payload" | jq '.' > "$meta_file"
append_index "code/$category" "${out_file#$ROOT_DIR/}" "AI code utility generated" "unmonetized" ""
log INFO "Generated code: $out_file"
