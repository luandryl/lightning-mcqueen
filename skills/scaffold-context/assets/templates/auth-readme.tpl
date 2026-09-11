# Google login

This baseline implements Google OpenID Connect through Authlib, login/logout, and a private session endpoint. It does not implement product screens, URL processing, or offline synchronization.

## Local setup

From the repository root, run `python3 scripts/configure-local.py --mode docker` (or `--mode native`). This creates `{{ backend_dir }}.env` with a random session key and restrictive file permissions, and refuses to overwrite an existing file.

Create a **Web application** OAuth client in Google Cloud. Configure the consent screen and test users if the application is in Testing. Set `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` privately in `{{ backend_dir }}.env`. Never put secrets in Vite variables or the scaffold answers.

Register exact authorized redirect URIs:

- Native: `http://localhost:{{ frontend_port }}/v1/auth/google/callback`
- Docker: `http://localhost:{{ frontend_container_port }}/v1/auth/google/callback`

Set `PUBLIC_ORIGIN` to the frontend origin of the execution mode. All auth requests go through the same-origin `/v1` proxy. Do not open the login route directly on the API port. With no Google credentials, login returns 503 and private resources stay protected.

With `mongo_mode=compose`, `docker compose up --build -d` starts Mongo, the API, and the frontend. Mongo is available on `127.0.0.1:27017` for native development and `mongo:27017` inside Compose. Data persists in the named volume; `docker compose down` preserves it. This unauthenticated Mongo is for local development only and is bound to loopback. For native app development, run `docker compose up -d mongo`, set mode native, then start backend and Vite. An external Mongo profile instead requires its own reachable Mongo URI.

## Session boundary

Google validates identity. Authlib validates OAuth state, PKCE, nonce and the signed ID token. The stable Google `sub` identifies the user. Verified email is required. Sessions expire after one hour and are stored in Mongo; only a random session reference is in the signed HttpOnly, SameSite=Lax cookie. Google access/ID tokens are discarded. Logout checks Origin and revokes the Mongo session. HTTPS and Secure cookies are required outside dev/test.

`GET /v1/auth/session` requires login. Future private routes must use `Depends(require_user)` from `app.api.auth`; product data must be scoped by `user.sub`. Future mutations also need an Origin/CSRF check. Health/version remain public. By default any verified Google account can enter; this is not an administrator allowlist.

The baseline stores no offline user content. When offline storage is added, define per-user cache isolation and cleanup on logout before shipping it.

## Verification limits

Automated checks use locally signed test ID tokens, mocked Google HTTP endpoints and a Mongo substitute. They cover valid login, rejected state/nonce/signature/audience/expiry, session expiry, logout revocation and CSRF rejection. They do not certify live Google credentials, consent configuration or real Mongo reachability. Docker verification builds images and validates Compose without starting services.

Sources: [Google OpenID Connect](https://developers.google.com/identity/openid-connect/openid-connect), [Authlib Starlette client](https://docs.authlib.org/en/v1.6.9/client/starlette.html).
