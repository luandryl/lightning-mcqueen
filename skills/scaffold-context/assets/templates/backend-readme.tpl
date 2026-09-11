# {{ project_name }} API

{{ project_description }}

Python 3.11. From this directory: create a virtual environment, copy `.env.example` to `.env`, run `make install`, then `make dev`. MongoDB must be reachable.

Validation: `make lint`, `make test`. API: `/health`, `/health/ready`, `/v1/version`, `/docs`.

First delivery: `/write-prd` uses the repository `{{ docs_from_backend }}pre-prd.md`.

## Navegação para IAs

Leia [{{ docs_from_backend }}README.md]({{ docs_from_backend }}README.md) para o índice de documentação e [{{ docs_from_backend }}ai-navigation.md]({{ docs_from_backend }}ai-navigation.md) para o mapa completo de arquivos e símbolos. As instruções canônicas ficam no AGENTS.md da raiz.
