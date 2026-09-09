# Decisions and Open Questions

Default to progress: make defensible, reversible technical decisions and record them. Interrupt only for a genuinely blocking user or business decision.

Read the target repository's instructions and upstream domain/model artifacts before deciding. They provide the tie-breakers.

## Artifact

Maintain one append-only file at `<work-folder>/decisions-and-open-questions.md`. Write it in PT-BR. Never rewrite or delete earlier entries; append a resolution when a decision changes.

Use:

```md
### D<N> — <título curto>

- **Data:** <data UTC>
- **Status:** Decidido autonomamente | Aberto — não bloqueante | Aberto — BLOQUEANTE | Resolvido em <data>
- **Contexto:** <o que estava sendo feito, com referências file:line>
- **Ambiguidade:** <o que os artefatos e o código não resolvem>
- **Opções:** <trade-offs de correção, robustez, custo e risco>
- **Decisão e justificativa:** <decisão aplicada ou recomendação>
- **Impacto e reversão:** <o que muda se a decisão for revertida>
- **Acompanhamento:** <história futura, correção ou nenhum>
```

## Non-Blocking Decisions

If one option is clearly preferable and reversible, apply it, log it, and continue. This includes naming, local structure, implementation ordering, tactical design, and unrelated improvements discovered during the story.

Do not expand current scope to absorb adjacent work. Record enough detail for a future story.

## Blocking Decisions

A decision is blocking only when all are true:

1. no path can produce correct work without material risk, such as data loss, financial error, destructive behavior, or a result worse than the status quo;
2. no safe, reversible default exists;
3. it is a product or business choice outside technical authority.

When blocked:

1. append an `Aberto — BLOQUEANTE` entry with a recommendation;
2. close the current timing row when timing is enabled;
3. mark and park only the affected story or portion;
4. continue independent work;
5. batch blocking questions until a natural checkpoint, unless no useful work remains.

On resume, append the resolution, open a fresh timing row, and continue from the parked step.
