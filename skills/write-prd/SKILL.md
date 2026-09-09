---
name: write-prd
description: Turn a feature idea into a scoped Product Requirements Document after inspecting available domain artifacts and the codebase. Use when the problem, goals, user-visible behavior, boundaries, and success criteria must be agreed before user stories or implementation.
metadata:
  author: Luan Andryl
  version: "3.1.0"
---

# Write PRD

Turn a feature idea into a Product Requirements Document at `docs/YYYY_MM_DD_feature_name/prd.md`.

The PRD defines why the work matters and what outcome is required. It may include relevant technical constraints, but it must not become an implementation plan.

## Principles

- Start with the problem and user outcome, not a proposed solution.
- Make goals and non-goals explicit.
- Prefer the smallest scope that achieves the outcome; reject speculative flexibility and imagined scale.
- Describe observable behavior from the user's perspective.
- Ground claims in domain artifacts and the actual codebase.
- Omit conditional sections that do not apply.
- Reference real files and symbols instead of copying implementation snippets.

## Inputs and Upstream Artifacts

Read the user's request first, then inspect the repository instructions and relevant code.

If present, read these artifacts before drafting:

- `docs/domain/DOMAIN.md` for approved semantics, invariants, language, and sources of truth;
- `docs/domain/MODEL.md` for approved boundaries, contracts, persistence, and operational constraints.

Use approved artifacts as constraints. Do not silently contradict them. If a product decision exposes a semantic gap that could change identity, state, invariants, authority, or a source of truth, stop drafting that portion and recommend revisiting `domain-discovery`. If technical modeling is materially unresolved, recommend `model-design`.

Do not require those artifacts for a small feature that introduces no meaningful domain ambiguity.

## Subagent and Model Routing

Delegate only bounded, independent tasks. Before delegating, compare:

```text
delegated cost = briefing/context transfer + subagent execution + main-agent validation and synthesis
direct cost = main-agent execution
```

Delegate only when the delegated cost is clearly lower, or when parallel investigation materially improves coverage without lowering confidence. Batch related searches into one assignment, reuse an existing subagent for follow-ups, and keep small or context-heavy PRDs with the main agent.

When the runtime supports model and reasoning selection, use the smallest capable model:

| Class | Model | Effort | Examples |
|---|---|---|---|
| Mechanical | Lightweight available model | `low` | Map relevant files, locate similar features, inventory endpoints/configuration, collect references for the key-files tables |
| Bounded analysis | Mid-tier available model | `medium` | Reconstruct one user flow, compare one existing pattern, investigate one integration or isolated technical constraint |
| Critical or cross-cutting | Main agent; independent high-capability reviewer only when justified | `high` | Define scope and non-goals, resolve product trade-offs, reconcile domain/model constraints, approve the final PRD |

Do not ask a lightweight model to infer requirements, decide scope, or reconcile contradictions. Subagents return evidence, uncertainties, and source paths; the main agent owns product synthesis and validation. If model selection is unavailable, preserve the routing and use the inherited model with the lowest suitable effort.

## Workflow

### 1. Investigate

Identify the problem, affected users, urgency, desired outcome, and stated constraints. Then inspect:

- similar features and established patterns;
- likely files and interfaces affected;
- reusable components or services;
- relevant APIs, events, jobs, storage, and integrations;
- repository conventions in `CLAUDE.md`, `AGENTS.md`, or `README.md`.

Resolve discoverable facts before asking questions. Ask only focused questions whose answers materially change scope or behavior.

### 2. Lock Scope

Propose goals, non-goals, and any remaining decision points with trade-offs. Recommend the simplest viable option when evidence supports one.

For every proposed goal, ask whether removing or shrinking it would still achieve the outcome. Move anything justified only as “nice to have,” future flexibility, premature scale, or polish into non-goals with a short reason.

Do not proceed as though an unresolved product decision were approved. Record non-blocking unknowns under `Perguntas em Aberto`.

### 3. Draft

Create `docs/YYYY_MM_DD_feature_name/prd.md` using today's date and a snake_case feature name.

Write the entire artifact in Brazilian Portuguese (PT-BR), including headings and prose. Preserve code identifiers, paths, payload fields, enum values, protocol names, and established technical terms when translation would reduce precision.

### 4. Validate

Before presenting the PRD, verify that:

- every goal traces to the problem statement;
- every explicit non-goal remains excluded elsewhere in the document;
- success criteria are observable;
- technical context supports rather than replaces product requirements;
- file references exist and are relevant;
- no unresolved question is presented as a decision.

Present the draft and incorporate user corrections. The approved PRD becomes the input to `write-user-stories`.

## Artifact Structure

Always include:

```md
# PRD: <nome da funcionalidade>

## 1. Declaração do Problema
## 2. Objetivos e Não Objetivos
## 3. Descrição da Funcionalidade
```

Include only the applicable conditional sections, preserving this order:

```md
## 4. Fluxos do Usuário
## 5. Contexto Técnico
## 6. Superfície de API
## 7. Alterações no Modelo de Dados
## 8. Alterações Incompatíveis
## 9. Critérios de Sucesso
## 10. Configuração e Ambiente
```

Always end with:

```md
## 11. Arquivos Principais
## 12. Perguntas em Aberto
```

Under `Arquivos Principais`, include separate tables for existing files to modify and new files to create. Cite paths and relevant symbols or line numbers where useful.

Under `Perguntas em Aberto`, explain what remains unknown and why it could not be resolved. If none remain, state: `Nenhuma — todas as decisões foram resolvidas durante o levantamento de requisitos.`

## Content Guidance

- `Declaração do Problema`: two to four sentences describing the pain or opportunity.
- `Objetivos e Não Objetivos`: specific outcomes and explicit scope exclusions, including deliberately removed complexity.
- `Descrição da Funcionalidade`: observable behavior and outcomes, without implementation steps.
- `Fluxos do Usuário`: happy path, variations, empty/loading/error states when relevant.
- `Contexto Técnico`: existing patterns, constraints, and source references only.
- `Superfície de API`: operations, schemas, errors, compatibility, and versioning as applicable.
- `Alterações no Modelo de Dados`: semantic data changes and constraints; derive details from an approved `MODEL.md` when available.
- `Alterações Incompatíveis`: impact and required response for each incompatible change.
- `Critérios de Sucesso`: measurable or directly observable completion signals.
- `Configuração e Ambiente`: new variables, flags, dependencies, or service connections.

## Boundaries

Do not:

- invent requirements from implementation details;
- add implementation tasks, commit plans, or code snippets;
- include empty sections;
- weaken a non-goal elsewhere in the document;
- design for hypothetical volume or future reuse without current evidence;
- draft from imagination when repository evidence is available.

At completion, report only the main scope decisions, open questions, and the path to the PRD.
