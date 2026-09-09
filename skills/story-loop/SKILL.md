---
name: story-loop
description: Implement an approved user-stories document autonomously, one story at a time, with research, tests, verification, diff review, acceptance checks, git delivery, and optional PR self-review. Use when asked to run the story loop or implement a PRD or stories document end to end.
metadata:
  author: Luan Andryl
  version: "2.1.0"
---

# Story Loop

Run an implementation loop over an approved source of work. The preferred input is `user-stories.md`; a PRD or bare feature request must first pass through the upstream planning skills described in `INTAKE.md`.

Act as an orchestrator when subagents are available and the routing gate below favors delegation, but keep ownership of scope, decisions, verification evidence, and the final result. Delegate only concrete, bounded tasks. If delegation is unavailable or would cost more than direct execution, perform the same steps yourself.

Read the target repository's `CLAUDE.md`, `AGENTS.md`, and `README.md` before implementation. Repository instructions override generic process guidance here.

## Subagent and Model Routing

Optimize total run cost, not the number of main-agent tokens in isolation. Before delegating, compare:

```text
delegated cost = briefing/context transfer + subagent execution + main-agent validation and synthesis + merge/conflict risk
direct cost = main-agent execution
```

Delegate only when the delegated cost is clearly lower, or when safe parallelism materially reduces elapsed time without lowering confidence. A small story should normally stay with the main agent. Batch compatible research, implementation, and tests for one bounded area into a single assignment instead of spawning one agent per phase. Reuse an existing subagent for follow-ups when its context remains relevant.

When the runtime supports model and reasoning selection, use the smallest capable model:

| Class | Model | Effort | Examples |
|---|---|---|---|
| Mechanical | Lightweight available model | `low` | Large file/reference inventory, locate tests and call sites, summarize long command output, build a read-only evidence index |
| Bounded analysis or implementation | Mid-tier available model | `medium` | Research one isolated subsystem, implement a self-contained change with explicit acceptance criteria, add focused tests, review a bounded diff |
| Critical or cross-cutting | Main agent; independent high-capability reviewer only when risk justifies its added cost | `high` | Resolve scope or architecture, change authorization/concurrency/data semantics, approve migrations, perform final acceptance and delivery decisions |

Apply these cost controls throughout the loop:

- do not delegate a task whose brief must reproduce most of the source artifacts or repository context;
- do not create separate research, implementation, test, and review subagents by default;
- parallelize only stories or investigations with satisfied dependencies and no overlapping files, git state, or decisions;
- keep final diff review, verification evidence, acceptance mapping, and externally visible git actions with the main agent;
- use a high-capability reviewer only for high-risk changes or unresolved findings, not as a routine second pass;
- if model selection is unavailable, preserve the task routing and use the inherited model with the lowest suitable effort.

Subagents must return changed files or evidence paths, commands run, observed results, risks, and uncertainties. The main agent validates their work before accepting it.

## Invocation

```text
/story-loop docs/2026_09_09_feature/user-stories.md — Story 2, stage only
```

```text
/story-loop docs/2026_09_09_feature/user-stories.md — everything remaining, one branch and PR per story, full self-review
```

Parse free text after the command into a run contract. Ask once for material choices that remain unresolved.

## Step 0: Resolve the Run Contract

Resolve these settings before reading the source:

| Setting | Options | Default |
|---|---|---|
| Scope | one named story, a subset, or everything remaining | ask |
| Git policy | `branch-pr`, `branch-pr-from-trunk`, `same-branch`, `stage-only`, `none` | ask |
| Timing | on with a log path, or off | off |
| PR self-review | `off`, `blocking-only`, `all-findings` | `blocking-only` when a PR is created; otherwise `off` |
| Autonomy | full send, or check in between stories | full send |

Git policies:

- `branch-pr`: one branch and draft PR per story, stacked on the previous story by default;
- `branch-pr-from-trunk`: one independent branch and draft PR per story, each based on trunk;
- `same-branch`: commit and push the current branch; update an existing PR when present;
- `stage-only`: stage the completed story without commits or remote changes;
- `none`: do not mutate git state.

Never assume permission to force-push, rewrite shared history, merge, close, or delete a branch. These actions require explicit authorization even under full autonomy.

Echo the resolved contract in one compact block. For multi-story runs, persist it in `<work-folder>/progress.md`.

## Step 1: Start Timing When Enabled

If timing is on, read `TIMING.md` and write the story's start row before source inspection or implementation. If timing is off, do not create or mention a timing log.

## Step 2: Build the Work List

Read `INTAKE.md`. The result must be an ordered list of stories with acceptance criteria and backward-only dependencies.

- An approved `user-stories.md` is consumed directly.
- An approved PRD must be converted by invoking `write-user-stories`.
- A bare feature request must first invoke `write-prd`, then `write-user-stories`.

Do not implement while a required upstream artifact still awaits user approval. Once the source is approved, check repository reality (`git log`, branches, and open PRs when available) instead of trusting its status column alone.

If the source defines its own execution contract or ordering, it takes precedence.

## Step 3: Execute Each Story

For every selected story:

1. **Prepare git state.** Follow the run contract. Check for unrelated user changes and preserve them. Do not place two stories on one new branch under a per-story branch policy.
2. **Mark in progress.** Update the source document using its own status convention.
3. **Research.** Inspect the acceptance criteria, upstream PRD/domain/model artifacts, relevant code, tests, and repository conventions. For non-trivial work, a read-only subagent may return a brief with concrete `file:line` evidence.
4. **Implement.** Make the smallest coherent change that satisfies the story. Do not absorb adjacent work or weaken acceptance criteria.
5. **Add or strengthen tests.** Cover new and changed behavior at the most valuable layer. Prefer realistic workflows and exact assertions about identity, values, state, visible text, errors, and side effects. Include relevant failure paths. Avoid tests that merely repeat implementation details.
6. **Review the diff.** Review all story changes, including tests, against these gates:
   - correctness and acceptance completeness;
   - security, authorization, data exposure, and unsafe input handling;
   - data integrity, concurrency, idempotency, retries, and partial failures where relevant;
   - query behavior, constraints, indexes, migration safety, backfills, and rollback when storage changes;
   - performance regressions on realistic paths;
   - repository conventions, unnecessary complexity, dead code, and scope creep.
7. **Verify.** Run the repository's relevant tests, typecheck, lint, formatter checks, builds, or targeted smoke checks. Record commands and observed results. “Looks correct” is not verification.
8. **Fix and repeat.** Apply valid findings and rerun affected checks. After three unsuccessful rounds on the same failure, record it in `DECISIONS.md`. Continue only when evidence shows the failure is pre-existing and unrelated; otherwise park the story and move to independent work.
9. **Acceptance check.** Map the final diff and test evidence to every acceptance criterion. Fix gaps; never narrow the story to make it pass.
10. **Mark complete.** Update the source status only after acceptance and verification pass.
11. **Commit.** When permitted, create one conventional commit or a small coherent set. Do not include unrelated changes.
12. **Deliver.** Push or open/update a draft PR according to the contract.
13. **Self-review.** When enabled, follow `REVIEW.md` before starting the next story.
14. **Record progress.** Update timing, decisions, PR link, and `progress.md` for multi-story runs.

## PR Creation

When the git policy creates a PR, use the repository's supported GitHub tooling. `gh` is the default when available. Create a draft PR and explicitly set its base branch.

Generate a PT-BR description from verified repository state, using only applicable sections:

```md
## O que foi entregue

## O que está incluído

## Como foi verificado

## Decisões e trade-offs

## Adiado

## Fonte
```

The first section is a concise stakeholder-facing outcome. The technical sections must reflect the final diff and actual verification commands. Link the source story or PRD. For stacked PRs, state the stack position and base branch.

Do not add issue-tracker references, inferred ticket IDs, or external links not supplied by the user or repository evidence.

## Autonomy and Blocking

After the contract and source are approved, proceed without routine check-ins when autonomy is `full send`. Record defensible, reversible decisions in `decisions-and-open-questions.md` and keep moving.

A decision is blocking only when all are true:

1. every available path risks material harm or incorrect behavior;
2. no reversible default exists;
3. the decision belongs to the user or business, not to technical judgment.

Park only the affected work and continue independent stories. Ask when nothing useful remains or before an irreversible/external action that lacks authorization. Follow `DECISIONS.md` for the record format.

## End of Run

Finish with a concise summary containing:

- stories completed, parked, and remaining;
- verification performed and any failures;
- branches, commits, and PR links created;
- autonomous decisions and unresolved blockers;
- links to the source, decisions log, timing log, and progress file when they exist.

## References

- `INTAKE.md`: source routing and work-list construction;
- `DECISIONS.md`: autonomous decisions, blockers, and follow-ups;
- `TIMING.md`: optional timing-log rules;
- `REVIEW.md`: direct PR self-review and fix loop.
