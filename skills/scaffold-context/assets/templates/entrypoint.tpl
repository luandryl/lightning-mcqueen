#!/bin/sh
set -eu
if [ "$#" -gt 0 ]; then exec "$@"; fi
exec uvicorn app.main:app --host 0.0.0.0 --port "${APP_PORT:-{{ backend_port }}}"
