# Changelog

Material workflow changes, newest first.

## 2026-09-10 — Confirmed documentation generation

- Added `docs-generate` to generate consolidated documentation from validated material already present in the repository, branches, or history.
- Translated its operating instructions into English while keeping confirmation prompts, generated documentation, audit artifacts, telemetry, and final reports in PT-BR.
- Preserved the mandatory confirmation gate before repository analysis, agent spawning, searches, or documentation changes.

## 2026-09-10 — Repository documentation archaeology

- Added `docs-analitics` to audit existing documentation across the current state, unmerged branches, and history, with independent factual validation before consolidation.
- Translated skill instructions into English and provided PT-BR artifact templates, including consolidated documentation, AGENTS.md, readiness reports, and telemetry summaries.
- Preserved the no-documentation stop gate, LOW/MEDIUM/HIGH routing, seven-document concurrency cap, and honest telemetry requirements.
- Documented the agent-delegation requirement; unavailable model/consumption metrics remain explicit rather than fabricated.

## 2026-09-09 — Claude Code and Codex installer targets

- Made `install.sh` install every retained skill into both `~/.claude/skills/` and `~/.codex/skills/` by default.
- Added `--target claude`, `--target codex`, and `--target all` while preserving collision backups through `--force`.

## 2026-09-09 — Cost-aware subagent routing

- Standardized a direct-versus-delegated cost calculation across all five skills.
- Added smallest-capable-model routing to `write-prd`, `write-user-stories`, and `story-loop`.
- Tightened `story-loop` delegation to avoid per-phase agent fan-out, duplicated context, routine high-capability reviews, and parallel edits with shared state.

## 2026-09-09 — Renamed to Lightning McQueen

- Renamed the project and local directory to `Lightning McQueen` / `lightning-mcqueen`.
- Documented the project explicitly as Luan Andryl's personal fork of
  [brunoanken/my-agentic-workflow](https://github.com/brunoanken/my-agentic-workflow), adapted to
  his real workflow.

## 2026-09-09 — Workflow focused on five skills

### Added

- `domain-discovery` for evidence-based domain semantics in `docs/domain/DOMAIN.md`.
- `model-design` for the conceptual and technical model in `docs/domain/MODEL.md`.

### Changed

- Standardized `metadata.author` as `Luan Andryl` across every retained skill.
- Standardized English skill instructions and PT-BR generated artifacts.
- Revised `write-prd` to consume approved domain/model evidence when applicable and investigate before asking questions.
- Revised `write-user-stories` and both story templates for PT-BR output, stronger traceability, and exact verification criteria.
- Made `story-loop` self-contained: it now owns testing, diff review, database checks, verification, PR creation, and PR self-review without invoking separate quality-gate skills.
- Reduced intake to the local artifact chain: domain model, PRD, user stories, and implementation.
- Removed all issue-tracker and MCP dependencies.

### Removed

- `create-pr`
- `database-change-modeler`
- `enhance-code`
- `record-demo-video`
- `review-postgres-schema`
- `review-pr`
- `test-coverage`

## 2026-08-14 — Initial repository

Created the repository as the versioned source of truth for the personal workflow and added the original planning and implementation skills.
