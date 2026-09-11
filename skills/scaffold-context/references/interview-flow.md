# Progressive Interview — Executable Branch Contract

No more than three related questions per interaction. Read existing answers/context first. Only ask missing questions that change a generated file, dependency, execution shape, local prerequisite or readiness for the first PRD. Selecting a named profile accepts its documented technical defaults; required choices without defaults remain pending. Do not silently convert a suggested profile into an accepted one.

```yaml
version: 1
state:
  phase: inspect
  answers: {}
  decisions: [] # key, value, origin(user|inferred|profile-default), evidence, confidence
  unresolved: []
  template_ids: []
  ready_for_prd: false
turn_limit: 3
transitions:
  inspect:
    action: read target directory and existing CONTEXT; do not read secret values
    if_nonempty: inspect conflicts; only exact matching managed files may be reused
    next: identity_shape
  identity_shape:
    questions:
      - id: project_name
        when: missing(project_name)
        ask: "Qual nome usaremos para o projeto?"
        validate: '^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$; length <= 63'
        affects: [package_names, service_name, mongo_database]
      - id: intent
        when: missing(intent)
        ask: "O que queremos começar e para quem?"
        affects: [CONTEXT, first_prd_direction]
      - id: shape
        when: missing(shape)
        ask: "Teremos API, API com frontend, ou um worker?"
        options: [api, api_spa, worker, another_shape]
        affects: [profile, repository_layout, execution]
    next: structural
  structural:
    questions:
      - id: backend_needed
        when: frontend_explicit_and_backend_unknown
        ask: "A interface terá backend neste repositório?"
        affects: [backend_files, proxy, layout]
      - id: layout
        when: shape == api and missing(layout)
        ask: "A API fica na raiz ou em back/ para um monorepo?"
        options: [root, monorepo]
        affects: [all_backend_paths, CI_paths, Docker_COPY]
      - id: profile
        when: shape in [api, api_spa] and missing(profile_acceptance)
        ask: "Posso seguir o perfil encontrado nas amostras: Python 3.11, FastAPI e MongoDB, com React/Vite se houver frontend?"
        affects: [runtime, dependencies, template_family]
        default_evidence: "versioned profile catalog"
    next: dependencies
  dependencies:
    questions:
      - id: authentication
        when: missing(authentication)
        ask: "Este início precisa de autenticação?"
        options: [none, google, other_required]
        affects: [authentication_profile]
        note: "Google is supported in fullstack. Clarify provider when required; other providers remain unsupported."
      - id: messaging_worker
        when: missing(messaging_worker)
        ask: "Além da API, precisamos de worker ou mensageria já neste início?"
        options: [none, kafka_worker, other_background_execution]
        affects: [runtime_processes, dependencies]
      - id: integrations
        when: structural_integration_unclear
        ask: "Há integração ou infraestrutura que precisa estar conectada já no scaffold?"
        affects: [client_dependencies, local_prerequisites]
    next: eligibility
  eligibility:
    rules:
      - when: unsupported_required_choice
        action: record unsupported requirement and evidence gap; do not invent template
        next: blocked_context
      - when: required_answer_missing
        action: ask only that answer; wait
        next: current_question
      - otherwise: local_defaults
  local_defaults:
    announce:
      - "Perfil técnico selecionado: pytest/Ruff/mypy, logs JSON, health e configuração por ambiente."
      - "Se houver frontend: React/Vite/Tailwind, Vitest e proxy /v1."
      - "Execução nativa e Docker; Mongo externo por default ou local com mongo_mode=compose. Portas do perfil: API 8208, Vite 5180, frontend container 3105."
    ask_only_if_needed:
      - id: local_override
        ask: "Precisa alterar portas ou usar apenas execução nativa?"
        default: use_named_profile_values
        affects: [ports, docker_files]
      - id: mongo_endpoint
        when: docker and mongo_mode != compose and container_reachable_mongo_not_known
        ask: "Qual é o endereço local do Mongo acessível pelo container? Informe sem credenciais."
        affects: [local_execution_readiness]
      - id: deployment
        when: explicit_deployment_requirement
        ask: "Qual ambiente de entrega exige arquivos agora?"
        affects: [deployment_profile_eligibility]
    next: render
  render:
    action: expand exact manifest; validate variables and collisions; copy/render retained templates
    next: verify
  verify:
    action: execute the checks specified in runtime.md; write structured results
    on_failure: fix only known template/parameter issues; otherwise preserve blocked context
    on_success: ready_context
  blocked_context:
    action: persist draft CONTEXT with unanswered questions or unsupported profile; ready_for_prd=false
    terminate: true
  ready_context:
    action: persist ready CONTEXT and file checksums; print handoff
    terminate: true
```

## Questions intentionally excluded

Do not ask for all screens/endpoints, domain entities, reconciliation rules, identifiers for duplicates, functional SLAs, feature acceptance criteria or full delivery scope. Preserve such unsolicited information as PRD input, but do not implement it. Ask about cache, migrations, object storage, Kubernetes/serverless/VM/cloud only if explicitly required and structurally material; these branches are unsupported by the released catalog, so there is no speculative questionnaire about them. CLI, job and library requests stop at shape eligibility.

## Correction and resume semantics

A user correction invalidates all downstream derived choices, manifest and validation affected by that key. Never overwrite edited output on resume. Reuse a completed answer without asking again. Persist after each turn in the target `.scaffold/CONTEXT.md` (draft), with decisions and unresolved questions; metadata contains no secrets. The generation phase replaces only managed draft context and newly generated files. Record template revision/digest to detect stale results.

Permanent handoff: docs/pre-prd.md v0 and the generated documentation index. Verification publishes reports into docs/, removes registered temporary workspaces and deletes .scaffold/. No output should depend on temporary state.
