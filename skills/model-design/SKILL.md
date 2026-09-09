---
name: model-design
description: Transform an approved domain in docs/domain/DOMAIN.md into a coherent computational and technical model in docs/domain/MODEL.md. Use for modeling entities, value objects, commands, events, policies, processes, states, boundaries, persistence, contracts, consistency, or migration after domain discovery. Invoke manually with /model-design.
disable-model-invocation: true
metadata:
  author: Luan Andryl
  version: "1.1.0"
---

# Model Design

Transform the approved semantics in `docs/domain/DOMAIN.md` into a coherent software representation. The technical model must preserve domain distinctions and justify every structure through a real semantic or operational need.

## Required Precondition

Before starting, read `docs/domain/DOMAIN.md` and verify:

```yaml
gates:
  ready_for_modeling: true
```

If the file is missing or the gate is not `true`, stop and report that `/domain-discovery` must be completed first. Do not fill semantic gaps with architectural assumptions.

Treat `docs/domain/DOMAIN.md` as the semantic source of truth. The codebase and technical constraints are evidence and constraints, not permission to silently redefine the domain.

If a semantic question could change concepts, identities, states, invariants, authority, or sources of truth, record the blocker, keep the planning gate closed, and state that `DOMAIN.md` must be revisited.

## Scope Boundaries

Do not write a PRD or user stories, and do not implement. Do not automatically apply DDD, Clean Architecture, hexagonal architecture, CQRS, Event Sourcing, microservices, sagas, or any other pattern.

Use a pattern only when a concrete domain or operational property justifies it.

## Subagent and Model Routing

Delegate only bounded, independent analyses. When the runtime supports model and reasoning selection, use the smallest capable model:

Before delegating, compare:

```text
delegated cost = briefing/context transfer + subagent execution + main-agent validation and synthesis
direct cost = main-agent execution
```

Delegate only when the delegated cost is clearly lower, or when parallel analysis materially improves the result without lowering confidence. Batch related mechanical work into one assignment, reuse an existing subagent for follow-ups, and avoid delegation when the task requires most of the main agent's context.

| Class | Model | Effort | Examples |
|---|---|---|---|
| Mechanical | Lightweight available model | `low` | Inventory entities/tables/contracts, extract endpoints and events, organize references, fill the current-model snapshot |
| Bounded analysis | Mid-tier available model | `medium` | Analyze one state machine, candidate boundary, policy, failure flow, or isolated persistence mapping |
| Critical or cross-cutting | Main agent; independent high-capability reviewer only when justified | `high` | Finalize the conceptual model, decide aggregate/module boundaries, choose consistency trade-offs, consolidate migration, open the planning gate |

Do not give a lightweight model decisions that cross several concepts, change invariants, or redefine semantics inherited from `DOMAIN.md`. Subagents return alternatives, evidence, risks, and open decisions; the main agent owns the final model. If model selection is unavailable, keep the task routing and use the inherited model with the lowest suitable effort.

## Procedure

### 1. Summarize the Semantic Model

Record the concepts, relationships, states, invariants, processes, and sources of truth inherited from `DOMAIN.md`. Reference the input file and note relevant technical constraints.

### 2. Build the Conceptual Model

Classify, when applicable and always with justification:

- entities;
- value objects;
- commands;
- domain events;
- policies;
- processes;
- actors;
- reference data;
- projections/views;
- external systems;
- technical artifacts.

Do not force every concept into an Entity, Aggregate, or Domain Service.

### 3. Model Entities and Value Objects

For each entity, describe its purpose, identity, lifecycle, state, relationships, invariants, and allowed transitions.

For each value object, describe its composition, equality, validations, invariants, units, and precision as applicable.

### 4. Model Behavior

Explicitly distinguish:

- command: an intent to cause change;
- validation and decision;
- domain event: a relevant fact that has occurred;
- side effect and integration.

For each policy, describe inputs, decisions, rules, outputs, and failure modes.

For each process, describe its start, states, events, participants, timeouts, retries, compensations, completion, and failures.

Model state machines when business states and transitions must be explicit.

### 5. Define Justifiable Boundaries

Investigate ownership, meaning, lifecycle, atomicity, and consistency. Determine what must change together and what has an independent lifecycle.

Define aggregate boundaries only when they help keep invariants consistent. Do not derive aggregates from table relationships.

Define module boundaries only when semantic cohesion, ownership, or dependencies justify separation. Do not turn every module into a service.

### 6. Derive the Persistence Model

Follow this direction:

```text
Domain → Conceptual Model → Persistence Model
```

For each persisted structure, describe its purpose, identity, fields, constraints, cardinalities, relationships, temporal behavior, history, indexes, ownership, and audit needs. Identify concepts that should not become their own tables.

### 7. Model APIs and Contracts

Model operations around domain intent and semantics, avoiding CRUD when a more expressive operation exists. For each relevant contract, describe:

```text
Intent → API Command → Domain Decision → Domain Event → Response / Side Effect
```

Include payloads, validation, errors, compatibility, and versioning where needed.

### 8. Define Operational Semantics

Make these explicit as applicable:

- transaction boundaries;
- strong and eventual consistency;
- concurrency control and conflicts;
- idempotency and deduplication;
- ordering;
- retries and backoff;
- timeouts;
- partial failures;
- compensations;
- observability and auditability.

Do not leave failures implicit. Describe the resulting state and who owns recovery.

### 9. Map Current to Target

Compare the current system with the proposed model and classify each change:

- `KEEP`: conceptually correct;
- `RENAME`: correct concept, inadequate name;
- `SPLIT`: one structure represents multiple concepts;
- `MERGE`: multiple structures represent one concept;
- `MOVE`: responsibility is in the wrong boundary;
- `DELETE`: accidental or obsolete artifact;
- `INTRODUCE`: required concept is missing.

### 10. Define the Migration Strategy

Prefer incremental transformation. Record each step in PT-BR using:

```text
Mudança:
Motivo:
Dependências:
Risco:
Compatibilidade:
Migração de dados:
Rollback:
Critérios de conclusão:
```

Distinguish semantic change, refactoring, persistence change, contract change, and operational change. Avoid a full rewrite without strong justification.

## Required Artifact

Create or update `docs/domain/MODEL.md`; create `docs/domain/` when needed. Keep the modeling state in the file, not only in the conversation.

Write the entire document in Brazilian Portuguese (PT-BR), including headings and prose. Preserve code identifiers, symbols, enum values, filenames, paths, protocol names, and established technical terms when translating them would reduce precision.

Start the file with:

```yaml
---
artifact: model-design
version: 1
status: draft
inputs:
  domain: docs/domain/DOMAIN.md
gates:
  ready_for_planning: false
open_decisions:
  blocking: 0
  non_blocking: 0
---
```

Update the counts to match the actual open decisions. Use a status that honestly reflects the artifact's maturity; do not declare approval without sufficient validation.

Use exactly these top-level sections:

```md
# Design do Modelo

## 1. Resumo do Modelo de Domínio
## 2. Princípios de Design
## 3. Modelo Conceitual
## 4. Entidades
## 5. Objetos de Valor
## 6. Comandos
## 7. Eventos de Domínio
## 8. Políticas
## 9. Processos
## 10. Máquinas de Estado
## 11. Limites de Agregados
## 12. Limites de Módulos
## 13. Modelo de Persistência
## 14. Contratos Externos
## 15. Limites Transacionais
## 16. Modelo de Consistência
## 17. Concorrência
## 18. Idempotência
## 19. Semântica de Falhas
## 20. Mapeamento Atual → Alvo
## 21. Estratégia de Migração
## 22. Decisões de Design em Aberto
## 23. Riscos
## 24. Diagrama do Modelo
## 25. Conclusões
```

Under `Decisões de Design em Aberto`, separate blocking and non-blocking decisions. Trace every structural decision to a documented semantic need, operational need, or technical constraint.

## Planning Gate

Set `gates.ready_for_planning: true` only when:

- central entities and identities are modeled;
- invariants are represented;
- relevant states and transitions are represented;
- main boundaries are defined and justified;
- the persistence model is sufficiently defined;
- relevant external contracts are defined;
- transactions, consistency, concurrency, idempotency, and failures are addressed where needed;
- the migration strategy is understood;
- no blocking architectural decision remains.

When information is missing, do not invent it. Keep the gate closed and record the exact blocker.

At completion, report only the main decisions, blockers, and the path `docs/domain/MODEL.md`.
