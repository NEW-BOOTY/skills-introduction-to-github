#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT_DIR/scripts/env.sh"
source "$ROOT_DIR/scripts/common.sh"
source "$ROOT_DIR/scripts/api.sh"

bundle_items="${MAX_ITEMS_PER_BUNDLE:-20}"
now="$(date +%Y%m%d-%H%M%S)"

create_bundle() {
  local src="$1" out="$2" type="$3"
  mkdir -p "$out"
  mapfile -t files < <(find "$src" -type f | head -n "$bundle_items")
  [[ ${#files[@]} -eq 0 ]] && return 0
  bundle="$out/${type}-${now}.tar.gz"
  tar -czf "$bundle" "${files[@]}"
  desc=$(openai_chat "$PROMPT_MODEL" "Write SEO title, bullet summary, and sales description for a $type digital product bundle.")
  seo_file="$ROOT_DIR/products/seo-pages/${type}-${now}.md"
  social_file="$ROOT_DIR/marketing/social/${type}-${now}.txt"
  market_file="$ROOT_DIR/products/marketplace-listings/${type}-${now}.json"
  printf '%s\n' "$desc" > "$seo_file"
  printf 'X/Twitter:\nLaunching %s bundle at %s\n\nLinkedIn:\nNew %s bundle ready for creators.\n' "$type" "$WEBSITE_URL" "$type" > "$social_file"
  jq -n --arg name "$type-$now" --arg description "$desc" --arg price "19" --arg currency "$DEFAULT_CURRENCY" '{name:$name,description:$description,price:$price,currency:$currency,platforms:["Gumroad","Ko-fi","Itch.io"]}' > "$market_file"
  append_index "products/$type" "${bundle#$ROOT_DIR/}" "Monetized bundle" "monetized" "$type-$now"
  log INFO "Created monetization bundle: $bundle"
}

create_bundle "$ROOT_DIR/prompts" "$ROOT_DIR/products/prompt-bundles" "prompt-bundle"
create_bundle "$ROOT_DIR/images" "$ROOT_DIR/products/image-packs" "image-pack"
create_bundle "$ROOT_DIR/code" "$ROOT_DIR/products/code-tools" "code-tool"
