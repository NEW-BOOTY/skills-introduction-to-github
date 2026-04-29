#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

openai_chat() {
  local model="$1" prompt="$2"
  curl -sS "$OPENAI_BASE_URL/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$model\",\"messages\":[{\"role\":\"system\",\"content\":\"You are a profitable content generation engine.\"},{\"role\":\"user\",\"content\":$(jq -Rn --arg v "$prompt" '$v')}] ,\"temperature\":1.1}" | jq -r '.choices[0].message.content'
}

openai_image() {
  local prompt="$1" out="$2"
  local b64
  b64=$(curl -sS "$OPENAI_BASE_URL/images/generations" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$IMAGE_MODEL\",\"prompt\":$(jq -Rn --arg v "$prompt" '$v'),\"size\":\"1024x1024\"}" | jq -r '.data[0].b64_json')
  echo "$b64" | base64 -d > "$out"
}
