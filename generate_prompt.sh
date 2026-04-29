#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT_DIR/scripts/env.sh"
source "$ROOT_DIR/scripts/common.sh"
source "$ROOT_DIR/scripts/api.sh"

category="${1:-business}"
out_dir="$ROOT_DIR/prompts/$category"
mkdir -p "$out_dir"

prompt_text=$(openai_chat "$PROMPT_MODEL" "Generate one original, commercially useful AI prompt in category '$category'. Return JSON with keys: title, prompt, description.")
file_base="prompt-$(date +%s)-$(slugify "$category")"
out_file="$out_dir/$file_base.json"
echo "$prompt_text" | jq '.' > "$out_file"
append_index "prompts/$category" "${out_file#$ROOT_DIR/}" "AI prompt generated" "unmonetized" ""
log INFO "Generated prompt: $out_file"
