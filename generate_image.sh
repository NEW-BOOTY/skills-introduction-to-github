#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT_DIR/scripts/env.sh"
source "$ROOT_DIR/scripts/common.sh"
source "$ROOT_DIR/scripts/api.sh"

category="${1:-art}"
out_dir="$ROOT_DIR/images/$category"
mkdir -p "$out_dir"

prompt="Create a high-quality, original, commercial stock-style image in the '$category' category."
file_base="image-$(date +%s)-$(slugify "$category")"
out_file="$out_dir/$file_base.png"
meta_file="$out_dir/$file_base.metadata.json"
openai_image "$prompt" "$out_file"
jq -n --arg p "$prompt" --arg c "$category" --arg f "${out_file#$ROOT_DIR/}" --arg t "$(timestamp)" '{prompt:$p,category:$c,file:$f,created_at:$t}' > "$meta_file"
append_index "images/$category" "${out_file#$ROOT_DIR/}" "AI image generated" "unmonetized" ""
log INFO "Generated image: $out_file"
