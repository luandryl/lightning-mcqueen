# Decisões do perfil

| Decisão | Valores | Default após aceitação | Efeito |
|---|---|---|---|
| profile | api-root/api-monorepo/fullstack | nenhum | layout e módulos |
| project_name | slug kebab, até 63 caracteres | nenhum | identidade |
| intent | ideia completa, até 20 mil caracteres | nenhum | docs/pre-prd.md v0 |
| description | uma linha, até 500 caracteres | primeira linha da ideia | metadata/README |
| authentication | none/google | nenhum | Google somente fullstack |
| worker/messaging | false/none | respostas explícitas | outros casos não suportados |
| runtime/DB | Python 3.11/FastAPI/Mongo | perfil aceito | dependências |
| docker/ci | boolean | true | containers/pipelines |
| backend_port | porta válida | 8208 | API |
| frontend_port | porta válida | 5180 | Vite |
| frontend_container_port | porta válida | 3105 | container front |
| mongo_mode | external/compose | external | dependência externa ou serviço local |
| frontend_theme | light/dark | light | dark somente shell Google |
| deployment | unspecified/local | resposta explícita | outros ambientes exigem perfil próprio |

Defaults são escolhas técnicas versionadas do catálogo, não requisitos universais. Não transferir nomes, decisões de domínio, pessoas ou políticas de projetos anteriores. Registre a escolha como resposta explícita ou default aceito. `profile_accepted=true` pressupõe confirmação de Python/FastAPI/Mongo. Google e Mongo Compose continuam sendo opções, não inferências automáticas.
