---
name: write-user-stories
description: Turn an approved PRD into sequenced, implementation-ready UI and backend stories with acceptance criteria, concrete test specifications, dependencies, and requirement traceability. Use after write-prd and before story-loop.
metadata:
  author: Luan Andryl
  version: "2.1.0"
---

# Write User Stories

Transform a PRD into a sequenced set of implementation-ready stories at `docs/YYYY_MM_DD_feature_name/user-stories.md`.

Each story must be a meaningful unit of work with a clear outcome, scope boundary, dependencies, acceptance criteria, and test plan. Stories implement the PRD and must not expand it.

## Inputs

Accept a PRD path or locate the most recent `prd.md` under `docs/`. Read it completely, including goals, non-goals, behavior, interfaces, data changes, success criteria, key files, and open questions.

Also read referenced `DOMAIN.md` and `MODEL.md` artifacts when present. Preserve their approved semantics and technical decisions. If the PRD contradicts them or leaves a blocking requirement unresolved, report the conflict instead of hiding it inside a story.

Treat non-goals as hard boundaries. If a natural implementation shape crosses one, stop the story at that boundary and state the exclusion.

## Subagent and Model Routing

Delegate only bounded, independent tasks. Before delegating, compare:

```text
delegated cost = briefing/context transfer + subagent execution + main-agent validation and synthesis
direct cost = main-agent execution
```

Delegate only when the delegated cost is clearly lower, or when parallel analysis materially improves coverage without lowering confidence. Batch related work into one assignment, reuse an existing subagent for follow-ups, and keep a small PRD or tightly coupled story set with the main agent.

When the runtime supports model and reasoning selection, use the smallest capable model:

| Class | Model | Effort | Examples |
|---|---|---|---|
| Mechanical | Lightweight available model | `low` | Extract requirements, build an initial traceability index, inventory referenced files/contracts, check numbering and backward-only dependencies |
| Bounded analysis | Mid-tier available model | `medium` | Draft test scenarios for one bounded story, decompose one isolated subsystem, compare a story against its applicable template |
| Critical or cross-cutting | Main agent; independent high-capability reviewer only when justified | `high` | Choose story boundaries and sequence, reconcile UI/backend contracts, resolve scope conflicts, validate complete PRD traceability |

Do not ask a lightweight model to invent story boundaries, resolve product ambiguity, or approve completeness. Subagents return candidate work, evidence, and gaps; the main agent owns final decomposition, sequencing, and validation. If model selection is unavailable, preserve the routing and use the inherited model with the lowest suitable effort.

## Workflow

### 1. Identify Work Units

Map every PRD requirement to one or more deliverables. Group tightly coupled tasks into a useful unit of value; do not create a story for every file or mechanical step.

Classify each unit as:

- `Backend`: migrations, storage, services, business behavior, APIs, jobs, configuration, or integrations;
- `UI`: pages, forms, components, navigation, user feedback, or other visible interaction.

Split mixed units when UI and backend can be delivered and verified independently. Put the backend story first and make the UI dependency explicit.

### 2. Read the Applicable Templates

Before writing the first story of each type, read the matching file from this skill directory:

- `backend-story-template.md`
- `ui-story-template.md`

Follow mandatory sections exactly. Include optional sections only when relevant.

### 3. Sequence

Order stories by actual dependency, usually:

1. data and migrations;
2. domain/application behavior and APIs;
3. UI and integration;
4. cleanup that becomes safe only after the new path exists.

Dependencies must point backward only. Number stories sequentially.

### 4. Specify Verification

Every story needs a risk-proportionate test plan containing:

- required setup and fixtures;
- scenarios with preconditions, actions, and exact expected assertions;
- relevant error, boundary, authorization, concurrency, or retry paths;
- what is explicitly not being tested because another layer already owns it.

Prefer assertions about identity, exact values, persisted state, visible text, and side effects. Avoid vague “works,” truthy-only, count-only, or status-only assertions when a stronger observable result exists.

### 5. Trace and Validate

Add a traceability matrix mapping every PRD requirement to stories. Before presenting the document, verify:

- every goal and behavior is covered;
- no non-goal leaked into a story;
- dependencies are acyclic and point backward;
- each story can be implemented and verified independently enough to be useful;
- API, data, and UI contracts agree across stories;
- new questions are explicit rather than encoded as assumptions.

Present the draft and incorporate user corrections. The approved document becomes the input to `story-loop`.

## Output Language and Structure

Write the entire artifact in Brazilian Portuguese (PT-BR), including headings, scenarios, statuses, and prose. Preserve code identifiers, paths, payload fields, enum values, protocol names, and established technical terms when translation would reduce precision.

Create the file beside its source PRD using the same date and feature name:

```md
# Histórias de Usuário: <nome da funcionalidade>

> Fonte: `docs/YYYY_MM_DD_feature_name/prd.md`
> Gerado em: YYYY-MM-DD

## Mapa das Histórias

| # | Título | Tipo | Status | Depende de |
|---|---|---|---|---|
| 1 | <título> | Backend | Não iniciada | — |
| 2 | <título> | UI | Não iniciada | História 1 |

## Histórias

<cada história segue seu template>

## Matriz de Rastreabilidade

| Requisito do PRD | Coberto por |
|---|---|
| <requisito> | História 1 |

## Perguntas em Aberto
```

Valid statuses are `Não iniciada`, `Em andamento`, `Concluída`, `Descartada`, and `Bloqueada`.

## Boundaries

Do not:

- invent sections instead of reading the templates;
- add fields, endpoints, options, abstractions, or behaviors absent from the PRD;
- combine UI and backend merely to reduce story count;
- over-split a small feature into mechanical tasks;
- paste implementation code;
- use vague acceptance criteria or test assertions;
- omit a PRD requirement from the traceability matrix.

At completion, report only the story count and sequence, blocking questions, and the path to `user-stories.md`.
