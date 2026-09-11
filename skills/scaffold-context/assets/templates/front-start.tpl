#!/bin/sh
set -eu

PORT="${PORT:-80}"
API_BASE="${{{ env_prefix }}_FRONT_API_BASE_URL:-/v1}"

if [ -z "${{{ env_prefix }}_FRONT_API_UPSTREAM:-}" ]; then
  echo "[startup] ERROR: {{ env_prefix }}_FRONT_API_UPSTREAM is required (host:port of {{ project_name }}-back)." >&2
  exit 1
fi

cat > /usr/share/nginx/html/runtime-config.js <<CFG
window.__APP_CONFIG__ = { {{ env_prefix }}_FRONT_API_BASE_URL: "${API_BASE}" };
CFG

export PORT {{ env_prefix }}_FRONT_API_UPSTREAM
envsubst '${PORT} ${{{ env_prefix }}_FRONT_API_UPSTREAM}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
nginx -t
exec nginx -g "daemon off;"
