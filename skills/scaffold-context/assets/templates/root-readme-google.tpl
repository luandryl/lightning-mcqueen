# {{ project_name }}

{{ project_description }}

Python 3.11 / FastAPI / MongoDB in `back/`; React 18 / Vite 6 / TypeScript / Tailwind in `front/`. Google login, a {{ frontend_theme }} account shell, technical health checks, and CI are included. Product screens and processing remain for the first PRD.

## Start locally

```sh
python3 scripts/configure-local.py --mode docker
docker compose up --build -d
```

Open http://localhost:{{ frontend_container_port }}. The API is at http://localhost:{{ backend_port }}/health. When `mongo_mode=compose`, Mongo is included with a persistent volume and loopback access at port 27017. External Mongo profiles require a separately configured reachable URI.

For working Google login, configure `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in `back/.env`, as described in [AUTH.md](AUTH.md), then restart the backend. Never commit this file. Login stays unavailable until credentials are configured.

Native development: Python venv plus `pip install -e '.[dev]'` in `back/`, then `make dev`. Use Node 20 and `npm ci`, `npm run dev` in `front/`. Native `PUBLIC_ORIGIN` is `http://localhost:{{ frontend_port }}`. Mongo can remain in Compose with `docker compose up -d mongo`.

Backend checks: `make lint`, `make test`. Frontend: `npm run typecheck`, `npm test`, `npm run build`.

Context: [docs/pre-prd.md](docs/pre-prd.md). Next: `/write-prd` → `/write-user-stories` → `/story-loop`.

## Navegação para IAs

Leia [docs/README.md](docs/README.md) para o índice de documentação e [docs/ai-navigation.md](docs/ai-navigation.md) para o mapa completo de arquivos e símbolos. As instruções canônicas ficam no AGENTS.md da raiz.
