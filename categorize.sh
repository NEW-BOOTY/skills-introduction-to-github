#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT_DIR/scripts/env.sh"
source "$ROOT_DIR/scripts/common.sh"

classify_text() {
  local txt="$1"
  if [[ "$txt" =~ (python|bash|script|api|tool|cli) ]]; then echo dev
  elif [[ "$txt" =~ (sales|copy|seo|ad|brand) ]]; then echo marketing
  elif [[ "$txt" =~ (money|invest|finance|budget) ]]; then echo finance
  else echo business; fi
}

while IFS= read -r -d '' file; do
  body=$(jq -r '.description // .prompt // .name // ""' "$file" 2>/dev/null || true)
  catg=$(classify_text "${body,,}")
  parent=$(basename "$(dirname "$file")")
  if [[ "$parent" != "$catg" ]]; then
    new_dir="$(dirname "$(dirname "$file")")/$catg"
    mkdir -p "$new_dir"
    mv "$file" "$new_dir/"
    log INFO "Recategorized $file to $catg"
  fi
done < <(find "$ROOT_DIR/prompts" "$ROOT_DIR/code" -type f \( -name '*.json' -o -name '*.md' \) -print0)
