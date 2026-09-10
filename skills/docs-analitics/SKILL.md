---
name: docs-analitics
description: >
  Audit existing repository documentation, including unmerged branches and
  historical candidates, independently verify it against the implementation,
  and consolidate validated knowledge into docs/ and AGENTS.md. Use for
  documentation archaeology, truthfulness audits, and agent readiness reviews.
  Measure agent usage, cost, and model-routing efficiency. Never create
  documentation from scratch when no relevant prior documentation exists.
metadata:
  author: Luan Andryl
  version: "1.0.0"
---

# Docs Analitics

Audit existing repository documentation, verify that it matches actual implementation behavior, and organize validated knowledge for future agents and developers.

Use specialized agents, controlled parallelism, independent validation, and explicit model routing by complexity. Keep the workflow independent of provider, model, harness, and agent runtime. When multiple models are available, route by complexity class.

## Output Language

Write all generated artifacts and the final response in Brazilian Portuguese (PT-BR), including headings, prose, findings, validation reports, telemetry summaries, consolidated `docs/` content, and `AGENTS.md`. The templates in [references/artifact-templates.md](references/artifact-templates.md) intentionally use PT-BR.

Preserve code identifiers, paths, filenames, schema keys, enum/status values, model classes, protocol names, and established technical terms where translation would reduce precision. JSON keys and machine-readable status values remain unchanged; human-readable JSON values use PT-BR.

## Objective

1. Discover existing documentation in the current repository state.
2. Investigate branches and history for documentation not yet merged.
3. Identify documentation work another developer has already started.
4. Evaluate `HEAD` documentation and branch candidates with equal rigor.
5. Verify documentary claims against code, configuration, tests, and other real evidence.
6. Validate conclusions through independent agents.
7. Classify documentation health.
8. Integrate only validated documentary knowledge.
9. Structure `docs/` and `AGENTS.md` only when existing documentary material justifies it.
10. Produce a readiness, truthfulness, and execution-consumption report.

## Mandatory Stop Rule

Before generating any new documentation, discover whether documentation already exists in:

- A: the current repository state;
- B: available branches;
- C: history indicating documentation work not yet incorporated.

If A, B, and C are all empty, STOP. Do not analyze code to generate documentation from scratch, create `AGENTS.md` or `docs/`, reconstruct architecture, or propose new documentation. Return only:

```text
Status da documentação: NOT_FOUND

Nenhuma documentação relevante preexistente foi encontrada no estado atual
do repositório, nas branches disponíveis ou no histórico do repositório.

Nenhuma documentação foi gerada.
```

This condition ends the skill.

## Source of Truth

Existing documentation is the subject of the audit, not the final source of truth. Use this indicative evidence hierarchy:

```text
executable behavior / tests
        ↓
implementation
        ↓
configuration
        ↓
schemas / migrations
        ↓
scripts
        ↓
documentation
        ↓
comments
        ↓
inference
```

The ordering is not absolute. Resolve conflicts against actual system behavior. Never use another agent as the sole factual evidence.

## Execution Workspace

Use `.docs-analitics/` exclusively for persistence and information exchange between agents:

```text
.docs-analitics/
├── repository-state.md
├── branch-candidates.md
├── inventory.md
├── findings/
│   └── <document>.md
├── validation/
│   └── <document>.md
├── telemetry/
│   ├── agents/
│   │   └── <agent-id>.json
│   └── telemetry-summary.md
└── synthesis.md
```

This is not official project documentation. It may contain hypotheses, intermediate results, evidence, conflicts, telemetry, and rejected conclusions. Never move its contents mechanically into `docs/`. Paths refer to the target repository root.

Read [references/artifact-templates.md](references/artifact-templates.md) when writing the corresponding execution artifacts.

## Execution Model

Use an ORCHESTRATOR agent to decompose work, classify tasks, select model classes, create agents, control parallelism, track dependencies, maintain execution state, collect telemetry, ensure analysis/validation independence, and consolidate results. The ORCHESTRATOR must not perform analytical work that can be delegated.

If the runtime cannot delegate to independent agents, report the validation limitation and do not integrate unvalidated documentation or claim independent validation occurred. If model selection is unavailable, retain task classes, use the available model, and record the actual model or `UNAVAILABLE` honestly.

### Model Routing

Classify every task as `LOW`, `MEDIUM`, or `HIGH` before execution. Determine the class by reasoning difficulty, ambiguity, decision risk, cross-cutting context, synthesis needs, and architectural judgment. Text volume alone does not increase complexity.

| Class | Responsibility | Examples |
|---|---|---|
| LOW | Use the fastest, most economical suitable model for mechanical work; perform most factual collection. | Run Git queries; locate commits, documentation, files, symbols, configuration, tests, and references; search; extract sections; collect evidence; build inventories; compare paths; normalize structures; write mechanically after decisions are settled. |
| MEDIUM | Bounded interpretation. May request LOW agents for additional collection. | Analyze a document, extract claims, map evidence, interpret local implementation, verify a documented flow, compare documentary versions, analyze branch documentation, classify documents, identify bounded gaps. |
| HIGH | Reserve for judgment, synthesis, conflicts, independent validation, architectural decisions, cross-cutting reasoning, and important ambiguities. | Validate another agent's analysis, resolve contradictions, reconcile branch versions, decide which knowledge survives, distinguish structural from accidental behavior, synthesize documents, choose the final docs/ structure and AGENTS.md content, produce the global verdict. |

### Fundamental Constraint: HIGH Must Never Perform LOW Work

When a task can be decomposed into collection → LOW, interpretation → MEDIUM, and judgment → HIGH, decompose it.

Correct: LOW locates authentication commits/files; MEDIUM interprets the changes; HIGH resolves the documentation/implementation conflict.

Incorrect: HIGH explores the entire repository, runs searches, locates files, builds an inventory, and then makes a decision.

HIGH must not list files, mechanically explore branches, run trivial searches, locate symbols or references, build inventories, perform broad collection, or execute formatting-only tasks. When HIGH needs more evidence: HIGH requests LOW → receives structured evidence → decides.

### Escalation

Allow LOW → MEDIUM and MEDIUM → HIGH for contradictory evidence, implicit domain rules, multiple components, no clear source of truth, documentation/implementation disagreement, high risk of incorrect conclusions, architectural decisions, or conflicts between documentary versions.

Do not escalate because of size. Try decomposition first.

## Phase 0 — Repository and Branch Discovery

Before analyzing documents, use LOW agents to investigate the documentary state. Record `.docs-analitics/repository-state.md` and `.docs-analitics/branch-candidates.md`.

### Current State

Identify the current branch, working tree, existing documentation, `AGENTS.md`, `README*`, `docs/`, ADRs, RFCs, runbooks, architecture/domain/operational documents, and other files clearly used as documentation.

### Available Branches and History

Inspect available local branches, remote-tracking branches, divergent branches, and commits not yet incorporated into the current branch. Avoid indiscriminate checkouts. Prefer `git branch`, `git branch -a`, `git log`, `git show`, `git diff`, `git merge-base`, or safe equivalents.

Look especially for creation of `AGENTS.md`, README changes, creation/modification of `docs/`, new ADRs/RFCs, architecture/domain documentation, and commits apparently intended to document the system.

Determine whether another developer has started relevant documentation that has not reached the current state. For every candidate, record branch/ref, relevant commits, author when available, changed documentary files, relationship to current documentation, merge status, relevance, and whether it warrants evaluation.

### Candidate Rule and Existence Gate

Branch documentation is real candidate documentation. Apply the SAME analysis → factual verification → independent validation process. Do not assume unmerged means invalid or another developer's authorship means correct. Provenance does not change validation rigor.

- No documentation in the current state, available branches, or relevant unincorporated history: apply the mandatory stop rule.
- Documentation only in another branch: continue; it may be incorporated after validation.
- Documentation in both current and other branches: evaluate both as competing versions of the same knowledge base.

## Phase 1 — Documentation Inventory

Use LOW to produce `.docs-analitics/inventory.md`. Record each logical document's current path, sources (`CURRENT`, `branch/<name>`, `commit/<sha>`), variants, purpose, topics, potential implementation evidence, and priority (`HIGH | MEDIUM | LOW`). Document priority is importance, not model class.

The unit of analysis is a logical document. For example, `docs/architecture.md` at HEAD and on `branch/foo` form one logical document with two variants. Evaluate competing versions together to avoid wasting agents.

### Parallelism

Analyze at most **7 logical documents simultaneously**, each assigned to an independent MEDIUM agent. For more than seven, run batches of up to seven and consolidate between batches. Respect any lower runtime concurrency limit.

## Phase 2 — Document Analysis

Assign a MEDIUM agent to each logical document to:

1. Read all relevant variants.
2. Extract factual claims.
3. Identify version differences.
4. Request LOW to locate evidence.
5. Compare documentation with implementation.
6. Assess which version has the strongest factual correspondence.
7. Record valid information exclusive to each variant.
8. Detect outdated documentation.
9. Detect missing knowledge.
10. Propose a final state.

Classify evidence as `CONFIRMED | INFERRED | UNKNOWN` and correspondence as `SUPPORTED | PARTIAL | CONTRADICTED | NOT_VERIFIABLE`.

Write `.docs-analitics/findings/<document>.md` with sources, per-claim evidence and assessment, preferred version (`CURRENT | <branch> | MERGE | NONE`), notes, and proposed document status (`OK | PARTIAL | OUTDATED | INVALID`).

## Phase 3 — Independent Validation

The analyzing agent must never validate its own result. Use HIGH.

Give the validator candidate documents, variants, the MEDIUM report, and evidence references. It must independently investigate rather than assume the report's conclusions are true. Delegate evidence location to LOW; HIGH does not perform collection.

The validator must select material claims, recheck correspondence, seek contradictory evidence, test weak conclusions, identify false positives and inferences incorrectly promoted to facts, assess competing versions, and validate the integration strategy.

Write `.docs-analitics/validation/<document>.md`. Record result (`VALIDATED | VALIDATED_WITH_CORRECTIONS | REJECTED | INSUFFICIENT_EVIDENCE`), current/candidate versions, confirmed/rejected conclusions, additional evidence, recommended source (`CURRENT | <branch> | SEMANTIC_MERGE | NONE`), and final status (`OK | PARTIAL | OUTDATED | INVALID`).

## Phase 4 — Conflict Resolution

When MEDIUM and HIGH materially disagree, do not simply accept HIGH's answer. Request new independent LOW collection, new localized MEDIUM interpretation if necessary, and final HIGH resolution. Record the decision's evidence.

## Phase 5 — Cross-document Synthesis

After all documents finish, use HIGH to consume structured results and produce `.docs-analitics/synthesis.md`. Do not repeat discovery or browse the entire repository. Request LOW if evidence is missing.

Include documentation sources, evaluated unmerged/historical candidates, document statuses and actions, confirmed/contradicted/unverifiable knowledge, gaps, useful unmerged work, recommended consolidation, and `AGENTS.md` readiness.

## Phase 6 — Documentation Integration

Change official documentation only after independent validation. Sources may be `CURRENT`, `BRANCH`, or `GENERATED_FROM_VALIDATED_MATERIAL`.

Do not blindly merge a whole documentary branch: it may include code, experiments, abandoned changes, or unrelated work. Integrate only validated documentary content, preferably through semantic integration:

```text
current documentation
+ valid branch content
+ evidence-supported corrections
= consolidated documentation
```

Preserve authorship/history when version control allows it without incorporating unrelated changes. Never incorporate code merely because it shares a branch with documentation.

## Phase 7 — Documentation Structure

Prefer `AGENTS.md`, `docs/`, and README. Avoid unnecessary file proliferation. Consolidate confirmed knowledge.

- `CONFIRMED` knowledge may be documented as fact.
- `INFERRED` knowledge may appear only as an explicit inference when it has real value.
- `UNKNOWN` knowledge must not become documentary fact.

`AGENTS.md` is a navigation map plus an operational contract for agents, not a context dump. Include repository purpose/map, a short architecture summary with links, domain knowledge links, development and verification guidance, confirmed constraints, and further documentation. Put long explanations in `docs/`.

## Mandatory Telemetry

The ORCHESTRATOR must collect enough telemetry to evaluate LOW/MEDIUM/HIGH routing. Give every agent an `agent_id` and record `.docs-analitics/telemetry/agents/<agent-id>.json` using the reference schema.

Never invent telemetry. Use `UNAVAILABLE` when a metric is not exposed by the runtime. Do not estimate tokens from character counts and present them as measured. Costs derived from real tokens and a known price table must be labeled `CALCULATED`, not `MEASURED`.

Even without token/cost metrics, record agent creation, parent, task, phase, class, actual model when identifiable, start/end, status, delegated agents, escalations, document, branch, and escalation reason. Mark unavailable values honestly.

Explicitly record every case where HIGH performs LOW work with `routing_violation: true` and `violation_type: HIGH_PERFORMED_LOW_WORK`. The target is zero violations; never falsify results to satisfy it.

Write `.docs-analitics/telemetry/telemetry-summary.md` with agent counts by class/model, input/output/cached tokens, measured/calculated/unavailable costs, duration, cost by phase, unit economics, escalations/delegations/violations, peak document parallelism, batches, and branch reuse.

### Routing Assessment

At completion, HIGH evaluates only aggregated telemetry:

- `GOOD`: LOW handled discovery/collection, MEDIUM handled local analysis, HIGH mainly validated/synthesized, no significant LOW work occurred in HIGH, and escalations were justified.
- `QUESTIONABLE`: unnecessary MEDIUM/HIGH concentration, many escalations, little LOW use, or apparently disproportionate costs.
- `POOR`: HIGH performed discovery/collection, almost all work went to HIGH, unnecessary escalation, substantial parallel duplication, or validation cost disproportionate to value.
- `INSUFFICIENT_DATA`: runtime information is insufficient for a defensible assessment.

## Documentation Readiness and Final Result

Assess separately:

- **Truthfulness:** Does the documentation match the implementation?
- **Agent Readiness:** Can an agent or developer understand, navigate, change, and verify the repository using this documentation?

Do not assess software production readiness; assess only the repository's documentary interface.

Use the PT-BR final-result template in the references. Report readiness percentage, documentation health (`OK | NEEDS_WORK | UNRELIABLE | NOT_FOUND`), document/claim/branch counts, reused work, created/updated/removed documentation, `AGENTS.md` status, agent counts, consumption, unit costs, HIGH/LOW violations, routing efficiency, remaining uncertainties, and major contradictions. Explain the basis of any readiness percentage; do not imply it is a measured runtime metric.

## Final Rules

Never generate documentation from scratch when none existed; ignore documentation because it is unmerged; trust another developer's documentation without validation; blindly merge a branch for its docs; incorporate unrelated code; invent architecture or domain rules; promote inference to fact; use agent consensus as evidence; let an agent analyze and validate the same result; use HIGH for LOW work; analyze more than seven logical documents simultaneously; or invent tokens, costs, or duration.

Success means reusing existing knowledge, eliminating false documentation, validating knowledge against the actual system, improving the documentary interface for humans and agents, and measuring the cost of doing so.
