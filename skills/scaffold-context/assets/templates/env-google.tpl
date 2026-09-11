MONGO_URI=mongodb://localhost:27017
MONGO_DB={{ project_name }}
APP_ENV=dev
APP_PORT={{ backend_port }}
LOG_LEVEL=INFO
PUBLIC_ORIGIN=http://localhost:{{ frontend_port }}
# Generate a local random value with scripts/configure-local.py. Never commit .env.
SESSION_SECRET=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
