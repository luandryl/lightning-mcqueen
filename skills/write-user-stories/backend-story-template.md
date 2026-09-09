# Backend Story Template

Use this template when the primary deliverable is system behavior: data, migration, service logic, API, job, configuration, or integration.

Write the generated story in PT-BR.

## Format

```md
### História <N>: <verbo no imperativo + objeto>

**Tipo:** Backend | **Status:** Não iniciada

#### Objetivo

<capacidade entregue e resultado esperado, sem narrar tarefas de implementação>

#### Cenários

**Cenário: <nome descritivo>**

**Dado** <estado inicial>

**Quando** <ação ou evento>

**Então** <resultado observável e específico>

#### Critérios de Aceitação

- [ ] <critério verificável>

#### Dependências

- **História <N>** — <o que ela fornece>

#### Limites de Escopo

- <o que esta história explicitamente não inclui>

#### Plano de Testes

- **Preparação:** <dados, fixtures e estado necessários>
- **Cenários:** <ações e assertions exatas>
- **Casos de borda:** <erros, limites, concorrência ou retries relevantes>
- **Não testar:** <responsabilidades cobertas por outra camada ou suíte>
```

State `Nenhuma.` when there are no dependencies. Include happy-path and relevant failure scenarios.

## Optional Sections

Add only when applicable:

```md
#### Contrato de API
#### Alterações no Modelo de Dados
#### Critérios de Performance
#### Idempotência e Concorrência
#### Migração e Rollback
#### Rastreabilidade de Requisitos
```

API contracts should specify method, path, request and response fields, validation, status codes, and error formats. Data changes should specify identity, types, nullability, defaults, constraints, indexes, relationships, migration order, and rollback needs.

Traceability must use the same labels or wording as the source PRD.
