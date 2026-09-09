# Lightning McQueen ⚡🏎️

> Ka-chow: from domain discovery to verified implementation, one story at a time.

Lightning McQueen is my personal fork of [brunoanken/my-agentic-workflow](https://github.com/brunoanken/my-agentic-workflow), reduced and adapted to my real day-to-day workflow. It intentionally keeps only the five skills I use.

The repository is the source of truth. Skill instructions are written in English; generated planning and operational artifacts are written in Brazilian Portuguese (PT-BR).

## Workflow

```text
domain-discovery → model-design → write-prd → write-user-stories → story-loop
```

Start at `write-prd` for a small, semantically clear feature. Use `domain-discovery` and `model-design` first when the work changes domain concepts, identity, lifecycle, invariants, state, authority, persistence, contracts, consistency, or migration strategy.

| Skill | Purpose | Main artifact |
|---|---|---|
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

The installer symlinks each directory in `skills/` into `~/.claude/skills/`. Editing either path therefore updates this repository rather than creating an untracked copy.

Use `./install.sh --force` only when you want an existing real skill directory backed up and replaced by the repository symlink.

## Requirements

- `git`
- [`gh`](https://cli.github.com) only when `story-loop` is asked to create or update GitHub pull requests

There are no MCP-server, issue-tracker, or third-party-skill dependencies.

## Repository Layout

```text
skills/          The five hand-written skills and their local references
install.sh       Symlinks repository skills into ~/.claude/skills/
CLAUDE.md        Maintenance rules for this content repository
CHANGELOG.md     Material workflow changes
```

## License

MIT
