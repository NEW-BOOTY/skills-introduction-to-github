#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$ROOT_DIR"/{prompts,images,code,products,marketing,logs,scripts}
mkdir -p "$ROOT_DIR/products"/{prompt-bundles,image-packs,code-tools,seo-pages,marketplace-listings}
mkdir -p "$ROOT_DIR/marketing"/{social,email}
for c in business marketing education dev productivity lifestyle art finance health; do
  mkdir -p "$ROOT_DIR/prompts/$c" "$ROOT_DIR/images/$c" "$ROOT_DIR/code/$c"
done

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
  echo "Created .env from .env.example. Fill in credentials before first run."
fi

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y jq curl coreutils >/dev/null 2>&1 || true
fi

source "$ROOT_DIR/scripts/env.sh"
source "$ROOT_DIR/scripts/common.sh"
require_env OPENAI_API_KEY
require_env OPENAI_BASE_URL
require_env PROMPT_MODEL
require_env CODE_MODEL
require_env IMAGE_MODEL
: > "$ROOT_DIR/logs/system.log"
ensure_index
log INFO "Bootstrap complete"
