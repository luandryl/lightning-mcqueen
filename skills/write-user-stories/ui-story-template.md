# UI Story Template

Use this template when the primary deliverable is something a user sees or interacts with.

Write the generated story in PT-BR.

## Format

```md
### História <N>: <título orientado ao resultado>

**Tipo:** UI | **Status:** Não iniciada

**Como** <papel>, **quero** <ação>, **para** <benefício>.

#### Objetivo

<capacidade entregue e resultado percebido pelo usuário>

#### Critérios de Aceitação

- [ ] <critério observável e verificável>

#### Fluxo de Interação

1. <ação do usuário e resposta da interface>

#### Estados Visuais

- **Carregando:** <feedback>
- **Vazio:** <mensagem e ação disponível>
- **Preenchido:** <estado normal>
- **Erro:** <mensagem e recuperação>
- **Desabilitado:** <quando e por quê>

#### Dependências

- **História <N>** — <o que ela fornece>

#### Limites de Escopo

- <o que esta história explicitamente não inclui>

#### Plano de Testes

- **Preparação:** <dados e estado necessários>
- **Cenários:** <interações e assertions exatas sobre texto, navegação e estado>
- **Casos de borda:** <entradas ou sequências incomuns>
- **Não testar:** <responsabilidades cobertas por outra camada ou suíte>
```

State `Nenhuma.` when there are no dependencies. Include only the visual states that apply.

## Optional Sections

Add only when applicable:

```md
#### Reutilização de Componentes
#### Acessibilidade
#### Casos de Borda
#### Rastreabilidade de Requisitos
```

Reference reusable components by file path. Accessibility guidance should cover keyboard behavior, focus, screen-reader semantics, labels, and contrast only where relevant. Traceability must use the same labels or wording as the source PRD.
