# Artifact Templates

Use these templates when producing the corresponding artifacts. Headings and human-readable content intentionally use Brazilian Portuguese (PT-BR); preserve machine-readable keys and status values. Replace ellipses with evidence-backed content. Report unavailable metrics as `UNAVAILABLE`, never as zero. A zero is valid only when observed.

## Branch Candidates — `.docs-analitics/branch-candidates.md`

```markdown
# Candidatos de Documentação em Branches

## <branch/ref>

Commits relevantes:
- ...

Autor, quando disponível:
...

Documentação alterada:
- ...

Relação com a documentação atual:
...

Integrado à branch atual:
YES | NO | PARTIAL

Motivo da relevância:
...

Candidato à avaliação:
YES | NO
```

## Inventory — `.docs-analitics/inventory.md`

```markdown
# Inventário Documental

## <logical-document-id>

Caminho atual:
...

Fontes:
- CURRENT
- branch/<name>
- commit/<sha>

Variantes:
- ...

Finalidade:
...

Tópicos:
- ...

Possíveis evidências na implementação:
- ...

Prioridade:
HIGH | MEDIUM | LOW
```

## Findings — `.docs-analitics/findings/<document>.md`

Repeat the claim section for each claim.

```markdown
# <document>

## Fontes avaliadas

- Estado atual: ...
- Branch: ...
- Commit: ...

## Afirmação 1

Afirmação:
...

Fonte:
...

Evidências:
- ...

Status da evidência:
CONFIRMED | INFERRED | UNKNOWN

Avaliação:
SUPPORTED | PARTIAL | CONTRADICTED | NOT_VERIFIABLE

Versão preferida:
CURRENT | <branch> | MERGE | NONE

Observações:
...

## Status sugerido do documento

OK | PARTIAL | OUTDATED | INVALID
```

## Validation — `.docs-analitics/validation/<document>.md`

```markdown
# Validação — <document>

Resultado:
VALIDATED | VALIDATED_WITH_CORRECTIONS | REJECTED | INSUFFICIENT_EVIDENCE

## Versão atual

...

## Versões candidatas em branches

...

## Conclusões confirmadas

...

## Conclusões rejeitadas

...

## Evidências adicionais

...

## Fonte recomendada

CURRENT | <branch> | SEMANTIC_MERGE | NONE

## Status final do documento

OK | PARTIAL | OUTDATED | INVALID
```

## Synthesis — `.docs-analitics/synthesis.md`

```markdown
# Relatório de Veracidade e Prontidão Documental

## Fontes documentais

Estado atual:
...

Branches não mergeadas avaliadas:
...

Candidatos históricos avaliados:
...

## Documentos

| Documento | Estado atual | Candidato em branch | Status de veracidade | Validação | Ação recomendada |
|-----------|--------------|---------------------|----------------------|-----------|------------------|

## Conhecimento confirmado

...

## Conhecimento contradito

...

## Conhecimento não verificável

...

## Lacunas documentais

...

## Trabalho útil ainda não mergeado

...

## Consolidação recomendada

...

## Prontidão do AGENTS.md

...
```

## Repository Guide — `AGENTS.md`

Use only after the existence gate and independent validation. Put long explanations in `docs/` and link them here.

```markdown
# Guia do Repositório

## O que este repositório faz

Descrição curta.

## Mapa do repositório

Principais áreas e responsabilidades.

## Arquitetura

Resumo curto.

Consulte:
- docs/architecture.md

## Conhecimento do domínio

- docs/domain/...

## Desenvolvimento

Como trabalhar no projeto.

## Verificação

Como verificar alterações.

## Restrições importantes

Regras relevantes confirmadas.

## Documentação adicional

Mapa dos documentos.
```

## Agent Telemetry — `.docs-analitics/telemetry/agents/<agent-id>.json`

This is a conceptual schema. Populate actual values where available; timestamps, durations, tokens, and costs below are deliberately unavailable rather than fictitious measurements. Add escalation events with their reasons, documents, and branches when applicable.

```json
{
  "agent_id": "analysis-architecture-01",
  "parent_agent_id": "orchestrator",
  "phase": "document-analysis",
  "task": "Analisar docs/architecture.md",
  "document": "docs/architecture.md",
  "branch": "UNAVAILABLE",
  "complexity": "MEDIUM",
  "requested_model_class": "MEDIUM",
  "actual_model": "UNAVAILABLE",
  "started_at": "UNAVAILABLE",
  "finished_at": "UNAVAILABLE",
  "duration_ms": "UNAVAILABLE",
  "input_tokens": "UNAVAILABLE",
  "output_tokens": "UNAVAILABLE",
  "cached_tokens": "UNAVAILABLE",
  "cost_usd": "UNAVAILABLE",
  "cost_basis": "UNAVAILABLE",
  "delegated_agents": [],
  "escalations": [],
  "status": "completed",
  "routing_violation": false
}
```

For a routing violation, record:

```json
{
  "routing_violation": true,
  "violation_type": "HIGH_PERFORMED_LOW_WORK",
  "task": "Descoberta de arquivos em todo o repositório"
}
```

## Telemetry Summary — `.docs-analitics/telemetry/telemetry-summary.md`

```markdown
# Telemetria da Execução

## Agentes

Agentes criados: N
LOW: N
MEDIUM: N
HIGH: N
Máximo de análises documentais simultâneas: N

## Uso de modelos

| Modelo | Classe | Agentes | Tokens de entrada | Tokens de saída | Custo |
|--------|--------|---------|-------------------|-----------------|-------|

## Consumo

Tokens de entrada: ...
Tokens de saída: ...
Tokens em cache: ...
Custo medido (MEASURED): ...
Custo calculado (CALCULATED): ...
Custo indisponível (UNAVAILABLE): ...
Duração total: ...

## Custo por fase

Descoberta: ...
Análise de branches: ...
Análise documental: ...
Validação independente: ...
Síntese: ...
Integração documental: ...

## Custos unitários

Documentos analisados: ...
Afirmações validadas: ...
Custo por documento analisado: ...
Custo por documento validado independentemente: ...
Custo por afirmação validada: ...

## Roteamento

Escalonamentos LOW → MEDIUM: ...
Escalonamentos MEDIUM → HIGH: ...
Delegações HIGH → LOW: ...
HIGH executando trabalho LOW: ...
Violações de roteamento: ...

## Paralelismo

Pico de paralelismo documental: ...
Lotes executados: ...

## Reaproveitamento de branches

Branches inspecionadas: ...
Branches com documentação relevante: ...
Documentos não mergeados reaproveitados: ...
Documentos integrados semanticamente: ...

## Avaliação

Eficiência do roteamento:
GOOD | QUESTIONABLE | POOR | INSUFFICIENT_DATA

Justificativa:
...
```

## Final Response

The mandatory `NOT_FOUND` stop response in `SKILL.md` takes precedence over this template when no prior documentation exists.

```text
Prontidão Documental do Repositório: XX%

Base da avaliação de prontidão:
...

Veracidade:
...

Prontidão para agentes:
...

Saúde da documentação:
OK | NEEDS_WORK | UNRELIABLE | NOT_FOUND

Documentos descobertos: N
Documentos analisados: N
Documentos atuais: N
Documentos candidatos não mergeados: N

OK: N
PARTIAL: N
OUTDATED: N
INVALID: N

Afirmações confirmadas: N
Afirmações contraditas: N
Afirmações não verificáveis: N

Branches inspecionadas: N
Branches com documentação útil: N

Documentação reaproveitada de outros desenvolvedores:
- ...

Documentação criada:
- ...

Documentação atualizada:
- ...

Documentação removida:
- ...

AGENTS.md:
CREATED | UPDATED | UNCHANGED | NOT_CREATED

Agentes criados: N
LOW: N
MEDIUM: N
HIGH: N

Tokens de entrada: ...
Tokens de saída: ...
Custo total: ...
Custo por documento validado: ...
Custo por afirmação validada: ...

HIGH executando trabalho LOW: N

Eficiência do roteamento:
GOOD | QUESTIONABLE | POOR | INSUFFICIENT_DATA

Incertezas restantes:
- ...

Principais contradições:
- ...
```
