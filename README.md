# Lightning McQueen ⚡🏎️

> Ka-chow: from domain discovery to verified implementation, one story at a time.

Lightning McQueen is my personal fork of [brunoanken/my-agentic-workflow](https://github.com/brunoanken/my-agentic-workflow), reduced and adapted to my real day-to-day workflow. It intentionally keeps only the eight skills I use.

The repository is the source of truth. Skill instructions are written in English; generated planning and operational artifacts are written in Brazilian Portuguese (PT-BR).

## Workflow

```text
domain-discovery → model-design → write-prd → write-user-stories → story-loop
```

Use `docs-analitics` independently for documentation archaeology: audit existing documentation in the current state, branches, and history before consolidating validated knowledge. It stops without generating documentation when no relevant prior material exists.

Use `docs-generate` when the same evidence-based workflow must require explicit user confirmation before repository analysis and documentation generation because of its potential token and agent cost.

Start at `write-prd` for a small, semantically clear feature. Use `domain-discovery` and `model-design` first when the work changes domain concepts, identity, lifecycle, invariants, state, authority, persistence, contracts, consistency, or migration strategy.

| Skill | Purpose | Main artifact |
|---|---|---|
| `scaffold-context` | Create an executable scaffold and portable AI navigation documentation. | `docs/pre-prd.md`, `AGENTS.md`, and `CLAUDE.md` |
| `docs-analitics` | Audit existing documentation against implementation with independent validation and model-routing telemetry. | Validated `docs/`, `AGENTS.md`, and PT-BR reports in `.docs-analitics/` |
| `docs-generate` | Generate consolidated documentation from validated existing material after explicit user confirmation. | Validated `docs/`, `AGENTS.md`, and PT-BR reports in `.docs-analitics/` |
| `domain-discovery` | Reconstruct domain semantics from the problem and existing system evidence. | `docs/domain/DOMAIN.md` |
| `model-design` | Turn approved semantics into a justified conceptual and technical model. | `docs/domain/MODEL.md` |
| `write-prd` | Define the problem, outcome, scope, behavior, and success criteria. | `docs/YYYY_MM_DD_feature_name/prd.md` |
| `write-user-stories` | Produce sequenced UI/backend stories with tests and traceability. | `docs/YYYY_MM_DD_feature_name/user-stories.md` |
| `story-loop` | Implement approved stories with research, tests, verification, review, and git delivery. | Code, progress, decision, review, and optional timing artifacts |

`story-loop` is self-contained for implementation quality gates. It does not require separate testing, code-review, database-review, PR-authoring, or issue-tracker skills.

## Install

```bash
git clone <your-fork-url> lightning-mcqueen
cd lightning-mcqueen
./install.sh
```

By default, the installer symlinks each directory in `skills/` into both `~/.claude/skills/` and `~/.codex/skills/`. Editing any linked path therefore updates this repository rather than creating an untracked copy.

Use `./install.sh --target claude` or `./install.sh --target codex` to install for only one runtime.

Install a newly added skill without reinstalling the others:

```bash
./install.sh --skill scaffold-context
./install.sh -s scaffold-context --target claude
./install.sh --skill=scaffold-context --target codex
```

The name must match a directory in `skills/`. Unknown names fail before any installation. Omit `--skill` to install all skills.

`scaffold-context` supports Claude Code and Codex; its generated `CLAUDE.md` imports the canonical `AGENTS.md`. The optional `agents/openai.yaml` contains Codex UI metadata. Running the scaffold requires Python 3.11+; frontend verification also requires Node/npm, and Docker builds require Docker when selected. Dependency installation requires network access.

Use `./install.sh --force` only when you want an existing real skill directory backed up and replaced by the repository symlink.

## Requirements

- `git`
- An agent runtime with delegation support for `docs-analitics` and `docs-generate` independent analysis and validation; model selection is used when available, and unavailable telemetry is reported explicitly
- [`gh`](https://cli.github.com) only when `story-loop` is asked to create or update GitHub pull requests

There are no MCP-server, issue-tracker, or third-party-skill dependencies.

## Repository Layout

```text
skills/          The eight hand-written skills and their local references
install.sh       Symlinks repository skills into Claude Code and Codex
CLAUDE.md        Maintenance rules for this content repository
CHANGELOG.md     Material workflow changes
```

## License

MIT
