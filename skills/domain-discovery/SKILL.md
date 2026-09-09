---
name: domain-discovery
description: Semantically investigate a problem and the existing codebase before technical design, producing or updating docs/domain/DOMAIN.md. Use for domain discovery, investigation, archaeology, or clarification of concepts, states, invariants, language, and sources of truth. Invoke manually with /domain-discovery.
disable-model-invocation: true
metadata:
  author: Luan Andryl
  version: "1.1.0"
---

# Domain Discovery

Investigate the user's problem and the current codebase before proposing a technical solution.

The goal is to discover and formalize domain semantics. Treat the codebase, database, APIs, events, and documentation as evidence: they may contain accidental decisions, historical names, duplicated or conflated concepts, obsolete rules, and technical limitations disguised as business rules.

## Scope Boundaries

Do not design architecture, propose the final persistence model or tables, write a PRD or user stories, or implement anything.

Before asking the user a question, determine whether the answer is available in the codebase or other artifacts. Use the evidence you find to ask specific questions.

## Procedure

### 1. Reconstruct the Problem

Describe the domain phenomenon independently of its current implementation:

- actors and goals;
- decisions that must be made;
- inputs, outputs, and side effects;
- required information;
- possible failures;
- reversible and irreversible actions;
- traceability needs;
- external dependencies.

### 2. Perform Codebase Archaeology

Investigate as applicable:

- data: entities, schemas, tables, migrations, constraints, enums, indexes, identifiers, relationships, and temporal fields;
- behavior: services, use cases, handlers, controllers, jobs, consumers, workflows, validations, and state transitions;
- integrations: APIs, events, queues, webhooks, files, providers, and external systems;
- language: recurring names, aliases, synonyms, polysemy, comments, and documentation;
- rules: guards, exceptions, conditionals, constraints, retries, compensations, and special cases.

Use parallel subagents only when they materially improve coverage. Split concrete, independent investigations such as persistence/model, behavior/workflows, integrations/contracts, vocabulary/semantics, and invariants/edge cases. Subagents collect evidence; the main agent consolidates the semantics and must not ask them for competing architectures.

## Subagent and Model Routing

Delegate only bounded, independent tasks. When the runtime supports model and reasoning selection, use the smallest capable model:

Before delegating, compare:

```text
delegated cost = briefing/context transfer + subagent execution + main-agent validation and synthesis
direct cost = main-agent execution
```

Delegate only when the delegated cost is clearly lower, or when parallel coverage materially improves the result without lowering confidence. Batch related mechanical searches into one assignment, reuse an existing subagent for follow-ups, and avoid delegation when the task requires most of the main agent's context.

| Class | Model | Effort | Examples |
|---|---|---|---|
| Mechanical | Lightweight available model | `low` | Map files, enumerate schemas/enums/endpoints, collect names, locate references, build an evidence index |
| Bounded analysis | Mid-tier available model | `medium` | Reconstruct one workflow, compare two sources, find contradictions or invariant candidates in one area |
| Critical or cross-cutting | Main agent; independent high-capability reviewer only when justified | `high` | Resolve semantic ambiguity, consolidate concepts, classify P0 questions, decide whether the gate can open |

Do not give a lightweight model work that requires resolving ambiguity, combining many codebase areas, or deciding final semantics. Ask it to return evidence with paths, symbols, confidence, and uncertainties. The main agent validates and synthesizes. If model selection is unavailable, keep the task routing and use the inherited model with the lowest suitable effort.

### 3. Reconstruct Domain Language

Build a provisional glossary. For each term, record its likely meaning, evidence, ambiguities, synonyms, neighboring concepts, and confidence.

Look especially for:

- synonymy: different names for one concept;
- polysemy: one name for different concepts;
- conceptual collision: distinct concepts merged into one structure;
- fragmentation: multiple structures representing one concept;
- technical vocabulary presented as business language.

### 4. Discover Concepts and Behavior

For each central concept, investigate:

- identity: when two occurrences are the same thing;
- existence: when it begins and ceases to exist;
- essential properties;
- lifecycle and temporality;
- states and transitions;
- relationships and cardinalities;
- relevant events;
- invariants;
- authority to create, modify, or correct it;
- source of truth and conflict resolution.

Distinguish intent, validation, decision, fact, and side effect. Do not confuse technical state with business state or a current implementation constraint with a domain invariant.

### 5. Consolidate Evidence

Classify each relevant conclusion as:

- `CONFIRMADO`: strong, consistent evidence;
- `PROVÁVEL`: supported but still needs confirmation;
- `AMBÍGUO`: multiple plausible interpretations;
- `CONTRADITÓRIO`: relevant sources disagree;
- `DESCONHECIDO`: insufficient evidence.

These classification labels are intentionally in PT-BR because they appear in the generated artifact.

Always distinguish explicitly between:

- the domain requires X;
- the current system implements or assumes X;
- X is an inference.

Never turn an inference into a fact.

### 6. Form Questions and Hypotheses

Ask only what investigation could not resolve. Classify open questions as:

- `P0`: the answer materially changes the domain model;
- `P1`: the answer changes relevant rules, invariants, or boundaries;
- `P2`: a non-blocking detail that can be resolved later.

Record each hypothesis in PT-BR using:

```text
Hn: <hipótese>
Evidência: <fontes e observações>
Confiança: <alta|média|baixa>
Como falsificar: <teste ou evidência contrária>
```

## Required Artifact

Create or update `docs/domain/DOMAIN.md`; create `docs/domain/` when needed. Keep the work state in the file, not only in the conversation.

Write the entire document in Brazilian Portuguese (PT-BR), including headings and prose. Preserve code identifiers, symbols, enum values, filenames, paths, protocol names, and established technical terms when translating them would reduce precision.

Start the file with:

```yaml
---
artifact: domain-discovery
version: 1
status: draft
gates:
  ready_for_modeling: false
open_questions:
  p0: 0
  p1: 0
  p2: 0
---
```

Update the counts to match the actual open questions. Use a status that honestly reflects the artifact's maturity; do not declare approval without sufficient validation.

Use exactly these top-level sections:

```md
# Descoberta do Domínio

## 1. Declaração do Problema
## 2. Atores
## 3. Linguagem do Domínio
## 4. Glossário
## 5. Conceitos Centrais
## 6. Identidade
## 7. Relacionamentos
## 8. Estados e Transições
## 9. Eventos
## 10. Invariantes
## 11. Processos
## 12. Fontes de Verdade
## 13. Semântica do Sistema Existente
## 14. Ambiguidades
## 15. Contradições
## 16. Perguntas em Aberto
## 17. Hipóteses
## 18. Evidências
## 19. Mapa do Domínio
## 20. Conclusões
```

Under `Perguntas em Aberto`, add `P0`, `P1`, and `P2` subsections. Under `Evidências`, cite concrete file paths, symbols, schemas, contracts, or documents whenever possible.

## Modeling Gate

Set `gates.ready_for_modeling: true` only when:

- no P0 question remains open;
- the central concepts are identified;
- the identities of the main concepts are understood;
- the main states and transitions are understood;
- the relevant invariants are identified;
- the relevant sources of truth are identified;
- critical contradictions are resolved or explicitly accepted.

When information is missing, do not invent it. Keep the gate closed and record the exact blocker.

At completion, report only the main findings, blocking questions, and the path `docs/domain/DOMAIN.md`.
