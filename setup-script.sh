#!/usr/bin/env bash
set -euo pipefail

# setup-script.sh: Prepare local environment files from templates
# Usage:
#   GITHUB_PAT=ghp_xxx WORKSPACE_DIR=/workspace ./setup-script.sh
# or pass flags: --github-pat ghp_xxx --workspace-dir /workspace --db-url postgres://...

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[setup] Preparing environment files..."

# Defaults
GITHUB_PAT="${GITHUB_PAT:-${GITHUB_PERSONAL_ACCESS_TOKEN:-${GITHUB_TOKEN:-}}}"
WORKSPACE_DIR_VAL="${WORKSPACE_DIR:-/workspace}"
DB_URL_VAL="${DATABASE_URL:-postgres://postgres:@127.0.0.1:5432/shadow_dev}"
BETTER_AUTH_SECRET_VAL="${BETTER_AUTH_SECRET:-dev-secret}"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --github-pat)
      GITHUB_PAT="$2"; shift 2 ;;
    --workspace-dir)
      WORKSPACE_DIR_VAL="$2"; shift 2 ;;
    --db-url)
      DB_URL_VAL="$2"; shift 2 ;;
    --auth-secret)
      BETTER_AUTH_SECRET_VAL="$2"; shift 2 ;;
    *) echo "[setup] Unknown arg: $1"; exit 1 ;;
  esac
done

# Ensure directories
mkdir -p "$ROOT_DIR/apps/server" "$ROOT_DIR/apps/frontend" "$ROOT_DIR/packages/db"

# Copy templates if missing
[[ -f "$ROOT_DIR/apps/server/.env" ]] || cp "$ROOT_DIR/apps/server/.env.template" "$ROOT_DIR/apps/server/.env"
[[ -f "$ROOT_DIR/apps/frontend/.env.local" ]] || cp "$ROOT_DIR/apps/frontend/.env.template" "$ROOT_DIR/apps/frontend/.env.local"
[[ -f "$ROOT_DIR/packages/db/.env" ]] || cp "$ROOT_DIR/packages/db/.env.template" "$ROOT_DIR/packages/db/.env"

# Helper to upsert key=value in a file
upsert() {
  local file="$1"; shift
  local key="$1"; shift
  local value="$1"; shift
  if grep -q "^${key}=" "$file"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  else
    echo "${key}=${value}" >> "$file"
  fi
}

# Populate server .env
SERVER_ENV="$ROOT_DIR/apps/server/.env"
upsert "$SERVER_ENV" DATABASE_URL "$DB_URL_VAL"
upsert "$SERVER_ENV" DIRECT_URL "$DB_URL_VAL"
upsert "$SERVER_ENV" BETTER_AUTH_SECRET "$BETTER_AUTH_SECRET_VAL"
upsert "$SERVER_ENV" WORKSPACE_DIR "$WORKSPACE_DIR_VAL"
[[ -n "$GITHUB_PAT" ]] && upsert "$SERVER_ENV" GITHUB_PERSONAL_ACCESS_TOKEN "$GITHUB_PAT"
[[ -n "$GITHUB_PAT" ]] && upsert "$SERVER_ENV" GITHUB_TOKEN "$GITHUB_PAT"
upsert "$SERVER_ENV" NODE_ENV development
upsert "$SERVER_ENV" AGENT_MODE local
upsert "$SERVER_ENV" API_PORT 4000
upsert "$SERVER_ENV" API_URL http://localhost:4000

# Populate frontend .env.local
FRONT_ENV="$ROOT_DIR/apps/frontend/.env.local"
upsert "$FRONT_ENV" NEXT_PUBLIC_SERVER_URL http://localhost:4000
upsert "$FRONT_ENV" NEXT_PUBLIC_VERCEL_ENV development
upsert "$FRONT_ENV" BETTER_AUTH_SECRET "$BETTER_AUTH_SECRET_VAL"
[[ -n "$GITHUB_PAT" ]] && upsert "$FRONT_ENV" GITHUB_PERSONAL_ACCESS_TOKEN "$GITHUB_PAT"
[[ -n "$GITHUB_PAT" ]] && upsert "$FRONT_ENV" GITHUB_TOKEN "$GITHUB_PAT"

# Populate db .env
DB_ENV="$ROOT_DIR/packages/db/.env"
upsert "$DB_ENV" DATABASE_URL "$DB_URL_VAL"
upsert "$DB_ENV" DIRECT_URL "$DB_URL_VAL"

echo "[setup] Done. Files created/updated:"
echo "  - apps/server/.env"
echo "  - apps/frontend/.env.local"
echo "  - packages/db/.env"