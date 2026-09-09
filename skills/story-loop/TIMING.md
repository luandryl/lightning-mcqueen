# Timing Log

Apply only when the run contract enables timing.

Maintain `<work-folder>/timing-log.md` in PT-BR unless the invocation names another path.

Create it with:

```md
| Item | Início (UTC) | Fim (UTC) | Duração | PR |
|---|---|---|---|---|
```

Append a start row immediately after the run contract resolves and before inspecting or implementing the source:

```md
| História 3 — Conciliação contábil | 2026-09-09T14:02:40Z | — | — | — |
```

The start time is when `story-loop` was invoked. If contract questions were necessary, write that original invocation time after the answers arrive.

Close the same row after the story is complete and, when enabled, self-review fixes are pushed. Fill the finish timestamp, human-readable duration, and PR link. Use `—` when no PR exists.

Use one row per contiguous work period. When a story becomes genuinely blocked, close its row before waiting. On resume, append a new row rather than reopening the old one.

For multi-story runs, write and close each story's row as work happens; never reconstruct the log at the end.
