# Google OIDC fullstack extension

Select only after the user requires Google login. Use `authentication=google`, `profile=fullstack`; do not silently downgrade authentication to `none`. Keep Google secrets out of interview JSON, context and telemetry. The generated AUTH.md is the operational reference for OAuth registration, redirect URIs and local setup.

Google uses Authlib 1.7.2, PKCE and OIDC validation, an opaque session reference in a signed HttpOnly cookie, and expiring/revocable Mongo session documents. Google tokens are not stored. The private session endpoint demonstrates the authentication dependency; future product endpoints must use it and scope resources by the verified Google sub. Login permits any verified Google account. Ask about an allowlist only when restricted access is requested.

The shell supports light/dark themes. Record product-specific visual references in docs/pre-prd.md; never copy product-specific domain or business screens into reusable templates. Google button branding remains distinct from application colors.

For local infrastructure requested by the user, choose mongo_mode=compose. This is a local-development service with a persistent volume and loopback port; it is not a production deployment profile. An empty Google configuration keeps login unavailable while allowing the shell and health endpoints to run. Real OAuth setup is an external activation prerequisite, separate from the automated verification gate.

When extending templates, first work in an isolated skill copy, update template-index hashes/provenance, generate a fresh fixture and run regression/security tests plus verify. Publish only the tested catalog and helper, preserving unrelated installed skill files. Re-generate into a fresh or owned draft destination; never patch managed application output.

The Google frontend uses an independent lockfile with Vite 6.4.3 and Vitest 4.1.11 (Node 20), replacing vulnerable development-tool versions found in the base catalog. Its production dependencies are React/ReactDOM only. Other profiles retain their original lockfile; announce this version difference when selecting Google.
