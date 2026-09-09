# PR Self-Review

Apply only when the run contract sets self-review to `blocking-only` or `all-findings` and a PR exists.

Review after the PR is opened or updated and before the next story begins. Fix findings on the same branch and PR.

## 1. Review Independently

Prefer a separate read-only subagent when available so the implementer does not grade its own work. Give it:

- the PR diff and description;
- the source story, PRD, and relevant domain/model artifacts;
- repository instructions;
- verification results.

Ask for findings only in these groups:

- `Bloqueantes`: new bugs, unmet acceptance criteria, security or data-integrity risks, unsafe migrations, or unjustified scope gaps;
- `Não bloqueantes`: maintainability, performance, clarity, or simplification improvements that do not prevent the story outcome.

Each finding must include severity, concrete `file:line` evidence, impact, and a suggested direction. Review these lenses only where relevant:

1. acceptance completeness and behavioral correctness;
2. tests and assertion strength;
3. authorization, data exposure, unsafe inputs, and other security risks;
4. persistence, queries, constraints, indexes, migration safety, and rollback;
5. concurrency, idempotency, retries, partial failures, and performance;
6. repository conventions, accidental complexity, dead code, and scope creep.

Write the review in PT-BR to `<work-folder>/reviews/<story-id>-pr<N>.md`. Do not post it as the PR review.

## 2. Select Findings

- `blocking-only`: fix every valid blocking finding; log non-blocking findings.
- `all-findings`: also fix worthwhile non-blocking findings that remain within the story's scope.

Never silently discard a finding. Log disagreements and out-of-scope findings in the decisions artifact with rationale.

## 3. Fix and Re-verify

1. Apply selected fixes on the same branch.
2. Add or update tests for changed behavior.
3. Review the fix diff against the same quality gates as the original work.
4. Run affected tests, typecheck, lint, and build checks.
5. Recheck every acceptance criterion.
6. Commit and push to the existing PR.

Use at most two review rounds. If valid blocking findings remain after the second round, record and park them according to `DECISIONS.md` instead of looping indefinitely.

## 4. Refresh the PR Record

Update any stale PR-description section so it describes the final state, not the history of edits. When useful, add one concise comment summarizing findings fixed, intentionally deferred items, and the decisions-log path. Do not paste the full review artifact.

Keep self-review and fixes inside the story's existing timing row. Record the round count and outcome in `progress.md` for multi-story runs.
