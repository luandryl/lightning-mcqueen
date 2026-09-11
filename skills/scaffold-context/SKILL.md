---
name: scaffold-context
metadata:
  author: Luan Andryl
description: Cria scaffold executável com entrevista progressiva, contexto v0 em docs/pre-prd.md e documentação completa de navegação para IAs. Use ao iniciar um projeto; não implementa a primeira funcionalidade.
---

# Scaffold Context

Entregue um repositório que outra IA consiga entender e evoluir **sem acesso à conversa de criação**. A entrega inclui código técnico, `AGENTS.md`, `CLAUDE.md`, `agent.MD`, `docs/` e a ideia inicial formatada na versão 0 de `docs/pre-prd.md`. Não mencione projetos usados como referência nem a história da investigação no projeto gerado.

## Entrevista e perfis

Leia [references/interview-flow.md](references/interview-flow.md); consulte [references/decision-matrix.md](references/decision-matrix.md) quando precisar de defaults. Pergunte 1–3 pontos relacionados por vez. Reuse decisões explícitas e não presuma respostas obrigatórias.

Resolva nome, intenção, forma/layout, aceitação do perfil técnico, auth, worker/mensageria, integrações e execução local. Preserve a intenção completa, inclusive parágrafos e listas, no pré-PRD; não invente requisitos. Perguntas sobre comportamento e aceite da primeira entrega pertencem a `/write-prd`.

Perfis: `api-root`, `api-monorepo`, `fullstack`; Python 3.11/FastAPI/Mongo, com React/Vite/TypeScript/Tailwind no fullstack. Login Google/OIDC é suportado no fullstack; leia [references/google-auth.md](references/google-auth.md). Há Mongo local em Compose e tema dark no shell Google. Anuncie os defaults do perfil e respeite overrides. Outros stacks, workers/Kafka e integrações não catalogadas exigem um perfil próprio; não improvise boilerplate nem troque a intenção para contornar uma lacuna.

## Execução

Use `scripts/scaffold.py` deste pacote, com Python 3.11+. [references/runtime.md](references/runtime.md) documenta o esquema e os comandos.

1. Inspecione o destino, sem sobrescrever conteúdo existente. Execute `workspace --target DESTINO` para criar uma área temporária **registrada e exclusiva**. Guarde nela respostas, venv, caches e outros arquivos temporários. Não use nomes fixos compartilhados em `/tmp`.
2. Execute `draft` durante a entrevista. O estado é exclusivamente `.scaffold/`; nunca crie `.result/` no projeto. Ainda não é uma entrega concluída.
3. `plan` expande os caminhos e verifica hashes; `generate` copia/renderiza os templates **e toda a documentação**, inclusive `docs/pre-prd.md` v0. Não escreva boilerplate manualmente.
4. Instale dependências no ambiente temporário registrado; execute `verify` usando esse Python/Node. Ele verifica integridade, lint, tipos, testes e build; com Docker, verifica Compose e constrói imagens temporárias.
5. Após sucesso, `verify` publica manifesto, resultados e telemetria em `docs/`, remove os temporários registrados e remove `.scaffold/`. Nunca chame pronto se os testes ou a limpeza final falharem.
6. Em falha, mantenha `.scaffold/` para retomada; se encerrar a tentativa, execute `cleanup` para retirar temporários externos próprios. Não apague arquivos do usuário, diretórios globais de cache, volumes Docker ou conteúdo de `/tmp` sem propriedade comprovada. Caminhos antigos só podem ser limpos se houver registro de criação nesta execução.

Não use `.env` de outros projetos. Testes não validam disponibilidade de integrações reais. Preserve alterações de terceiros ao atualizar a própria skill; corrija templates em cópia isolada e publique somente após testes.

## Documentação obrigatória para IAs

O gerador entrega estes arquivos, ajustados ao perfil e inventário reais:

- `docs/pre-prd.md`: ideia inicial formatada, versão 0, objetivo, limites, escolhas e perguntas para o primeiro PRD.
- `AGENTS.md`: ordem de leitura, áreas de mudança, comandos e contrato de manutenção. `agent.MD` aponta para esse arquivo canônico; `CLAUDE.md` o importa com `@AGENTS.md`.
- `docs/README.md`: índice e roteiro de leitura.
- `docs/architecture.md`: processos, fluxo HTTP/Mongo/auth, rotas técnicas e limites.
- `docs/ai-navigation.md` e `docs/code-map.json`: **todos os arquivos técnicos gerados**, papéis, símbolos e imports internos.
- `docs/development.md`: pré-requisitos, instalação, execução, portas e diagnóstico.
- `docs/configuration.md`: variáveis dos exemplos e campos tipados de Settings com arquivo/linha; sem valores secretos.
- `docs/testing.md`: comandos, cobertura e limites das verificações.
- `docs/decisions.md`: decisões confirmadas/defaults e sua origem.
- Relatórios finais `docs/scaffold-*`: manifesto, resultados e telemetria, sem dependência de estado temporário.

Confirme que os links locais resolvem e que os arquivos documentados correspondem ao perfil. Não entregue apenas uma lista genérica de tecnologias. A IA seguinte deve conseguir localizar onde alterar código, executar testes e saber o que ainda não foi implementado. Mudanças futuras de módulos, rotas, config e comandos devem atualizar os mapas/documentos no mesmo passo.

## Handoff

Mostre `docs/pre-prd.md`, a documentação e o resultado de validação. Próximo passo: `/write-prd` lê **docs/pre-prd.md** e define a primeira entrega; depois `/write-user-stories` e `/story-loop`. Só invoque workflows existentes automaticamente quando autorizado. Nenhuma dependência de domain-discovery/model-design; nenhum PRD funcional completo é criado pelo scaffold.

## Esforço e telemetria

Scripts para copiar/renderizar/documentar/verificar, sem agente. LOW para extrair respostas; MEDIUM para ambiguidade estrutural. HIGH somente após MEDIUM insuficiente em uma questão material, com razão registrada antes da escalada. Modelo/esforço efetivos e tokens estimados devem ser identificados honestamente.

Durante execução, eventos ficam em `.scaffold/telemetry.jsonl`; ao concluir, são publicados em `docs/scaffold-telemetry.jsonl`. Use `event` para registrar entrevista ou delegação com metadados operacionais apenas. Sem prompts completos, código, credenciais ou valores secretos. Nunca recrie `.scaffold/` depois da finalização só para escrever um evento.

## Runtime portability

This skill supports Claude Code and Codex. Resolve `SKILL_DIR` to this installed skill directory before running helpers; resolve scripts and templates relative to the package, not the target project. `agents/openai.yaml` is optional Codex UI metadata and is not required by Claude Code. LOW/MEDIUM/HIGH describe routing intent: use available runtime controls and report unsupported model, effort, or token telemetry as unavailable. Do not require Codex-specific tools.
