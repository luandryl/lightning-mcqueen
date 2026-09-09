# Intake

Produce one ordered work list whose stories have acceptance criteria and backward-only dependencies. Establish the work folder that will contain the source, decisions, timing, reviews, and progress.

## Work Folder

- When the source is on disk, use its directory.
- For a bare request, upstream planning creates `docs/YYYY_MM_DD_feature_name/`; use that directory.

Do not create a parallel location for the same body of work.

## Follow Provenance Upward

Read the source and its available upstream artifacts:

```text
user-stories.md → prd.md → docs/domain/MODEL.md → docs/domain/DOMAIN.md
```

Stop when another level adds no relevant constraints. Do not expand into sibling work outside the selected scope.

Check applicable gates:

- `MODEL.md` must not silently conflict with `DOMAIN.md`;
- a model consumed as approved input must have `gates.ready_for_planning: true`;
- open product questions in the PRD must not be disguised as implementation decisions;
- the user-stories document must have been reviewed when it was derived from a PRD.

## Route the Source

### Approved User Stories

1. Read the document completely.
2. Normalize each selected story into id, title, status, acceptance criteria, dependencies, and source references.
3. Preserve its identifiers, order, scope boundaries, and status convention.
4. Check actual repository state with git history, branches, and open PRs when available. Resolve discrepancies before duplicating work.
5. If the invocation did not name a story or say “everything remaining,” state the proposed selection and ask once.

### Approved PRD

Invoke `write-user-stories` through the available skill mechanism. Use its generated and user-approved `user-stories.md` as the work list. Do not implement directly from a PRD unless the user explicitly limits the work to a trivial, single unit whose acceptance criteria are already complete.

### Bare Feature Request

Invoke `write-prd`, obtain approval of the resulting PRD, then invoke `write-user-stories` and obtain approval of the story list. Only then enter implementation.

If existing domain semantics are unclear enough to affect identity, lifecycle, states, invariants, authority, or sources of truth, route through `domain-discovery` before `write-prd`. If the approved domain requires a technical model, route through `model-design` before product planning.

## Intake Boundaries

Do not:

- implement during intake;
- invent work outside the source's goals;
- include explicit non-goals;
- trust stale status text over repository evidence;
- bypass upstream approval when deriving scope;
- narrow or reorder stories merely to avoid difficult work.

Record adjacent discoveries as follow-ups in the decisions log rather than silently adding them to the current story.
