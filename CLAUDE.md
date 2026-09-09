# Lightning McQueen

Lightning McQueen is Luan Andryl's personal fork of `brunoanken/my-agentic-workflow`, adapted to his day-to-day workflow and reduced to five hand-written Claude Code skills.

Upstream: <https://github.com/brunoanken/my-agentic-workflow>

This is a content repository. Its deliverables are Markdown instructions that agents execute in other projects; there is no application to build here.

## Do Not Execute Skill Source

Files under `skills/` are artifacts to edit, review, and document. Reading a `SKILL.md` in this repository does not invoke it and does not make its instructions active for the current task.

Invoke an installed skill through the runtime's skill mechanism when the task genuinely requires using it.

## Retained Skills

Only these skill directories belong in the repository:

- `domain-discovery`
- `model-design`
- `write-prd`
- `write-user-stories`
- `story-loop`

## Conventions

- Use one kebab-case directory per skill, matching the frontmatter `name`.
- Every `SKILL.md` requires `name`, a discriminating trigger-oriented `description`, and `metadata.author: Luan Andryl`.
- Write skill instructions and maintenance documentation in English.
- Write generated planning and operational artifacts in PT-BR. Keep code identifiers, paths, schema names, enum values, and protocol terms unchanged where translation reduces precision.
- Keep substantial conditional guidance in referenced files beside `SKILL.md`; link each reference from the entrypoint.
- Use relative paths within a skill. Never embed home-directory or machine-specific absolute paths.
- Refer to another retained skill by name and invoke it through the runtime's skill mechanism. Never read a sibling `SKILL.md` as a substitute for invocation.
- Preserve repository-specific user changes and authorization boundaries.

## Installation Model

`install.sh` creates:

```text
~/.claude/skills/<name> → <repository>/skills/<name>
```

The repository remains the origin. Do not copy skills into `~/.claude/skills/`; copies drift.

## Dependencies

The current workflow has no MCP-server, issue-tracker, or third-party-skill dependencies. `git` is required; `gh` is conditional on GitHub PR delivery in `story-loop`.

If a future change adds a dependency, document what requires it, where to obtain it, and the behavior when unavailable in `README.md` and `CHANGELOG.md` in the same change.

## Public Repository Safety

This repository is intended to be public. Never copy raw runtime configuration, credentials, tokens, authorization headers, or machine-specific secrets into it.
