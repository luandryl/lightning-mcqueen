# Runtime

O helper scripts/scaffold.py é autocontido (stdlib, Python 3.11+). Usa apenas os templates deste pacote e scripts/documentation.py para gerar documentação a partir dos arquivos selecionados. Não lê repositórios externos.

## Respostas JSON

Campos obrigatórios em respostas completas:

```json
{
  "project_name": "contratos",
  "intent": "Registrar contratos para a equipe operacional",
  "profile": "api-root",
  "profile_accepted": true,
  "authentication": "none",
  "messaging": "none",
  "worker": false,
  "required_adapters": [],
  "deployment": "unspecified",
  "local_prerequisites_resolved": true,
  "docker": false
}
```

Este é um exemplo de respostas explícitas, não respostas presumidas para uma intenção vaga. `profile_accepted` requer aceitação do perfil Python/FastAPI/Mongo; runtime/banco alternativo não é aceito por este esquema. `local_prerequisites_resolved` só é true quando a dependência Mongo e a forma de executar estão identificadas. Para Docker, informe também `mongo_container_uri` sem credenciais (mongodb://host:porta), acessível do container. Valores com usuário/senha, query ou fragmento são rejeitados. Não grave segredos no JSON; a aplicação recebe-os pelo ambiente fora do contexto.

Defaults quando o perfil é aceito: `description=intent`, `docker=true`, `ci=true`, `backend_port=8208`, `frontend_port=5180`, `frontend_container_port=3105`. `deployment` pode ser unspecified/local; outro ambiente que exija arquivos é não suportado. Overrides opcionais: esses defaults, `prd_questions` (lista de texto), `decisions` (lista de objetos key/value/origin/evidence/confidence), `unresolved` (lista de pendências). Campos desconhecidos são rejeitados para evitar ignorar requisitos. Formato `project_name`: kebab-case iniciado por letra, até 63 caracteres. Texto é escapado por contexto, nunca avaliado como código.

## Comandos

```
python3 SKILL_DIR/scripts/scaffold.py draft --answers WORKSPACE/answers.json --target /path/project
python3 SKILL_DIR/scripts/scaffold.py plan --answers WORKSPACE/answers.json
python3 SKILL_DIR/scripts/scaffold.py generate --answers WORKSPACE/answers.json --target /path/project
python3 SKILL_DIR/scripts/scaffold.py verify --target /path/project --python /path/venv/bin/python
python3 SKILL_DIR/scripts/scaffold.py event --target /path/project --metadata WORKSPACE/event.json
```

`draft` aceita respostas parciais. Atualize o mesmo rascunho durante a entrevista; após geração, respostas são imutáveis para não desalinhar o scaffold. `generate` não sobrescreve código existente. `plan` não escreve arquivos. `verify` pode ser repetido após corrigir o ambiente e verifica integridade antes dos comandos. Comandos retornam exit code 2 em erro, estado temporário fica bloqueado em falha de verificação.

Instalação antes de verificar (cwd backend: raiz ou back/):

```
python3.11 -m venv WORKSPACE/venv
WORKSPACE/venv/bin/python -m pip install -e '.[dev]'
```

No fullstack, execute `npm ci` em front/. Use Python/Node instalados no runtime; Node 20 é o runtime do template Docker. Não troque versões do catálogo silenciosamente. `verify` usa python -m ruff/mypy/pytest e npm run typecheck/test/build. Docker precisa de engine e rede para construir; não inicia serviços reais. Imagens recebem tags exclusivas e são removidas. Saídas de comandos são mostradas ao agente mas não copiadas à telemetria. JSON de verificação contém comandos, duração, exit code e status.

## Saídas e consistência

.scaffold/ contém respostas e estado durante a execução. docs/pre-prd.md v0 e a documentação para IAs são gerados permanentemente. Após verify bem-sucedido, relatórios são publicados como docs/scaffold-manifest.json, docs/scaffold-verification.json, docs/scaffold-telemetry.jsonl e docs/scaffold-telemetry-summary.md; .scaffold/ e os workspaces temporários registrados são removidos. Campos internos de estado têm marca `artifact=scaffold-context`, version=1. Em cada execução o helper valida paths relativos, hashes de templates e colisões; a publicação do scaffold usa rename de staging no mesmo filesystem. Arquivos alterados manualmente nunca são substituídos.

O ready gate exige todos os campos estruturais, perfil suportado, nenhuma pendência estrutural, manifesto íntegro e todas as verificações executadas com sucesso. Não há API para forçar status ready nem para enviar resultados de teste fictícios. O contexto gera sugestões de perguntas funcionais para /write-prd e não exige respostas a elas.

`event` aceita somente metadados operacionais definidos no script. Use timestamps/durações/tokens reais quando disponíveis e estimados explicitamente caso contrário; não passe texto de usuário ou variáveis de ambiente como metadados. Simulações nunca contam como consumo real.

## Extensões Google e Mongo local

`authentication` aceita `none` ou `google`. Google exige `profile=fullstack`; `required` sem provedor continua não suportado. `mongo_mode` aceita `external` (default histórico) ou `compose` (exige Docker e deriva `mongo_container_uri=mongodb://mongo:27017`). `frontend_theme` aceita `light` (default) ou `dark` (shell Google). O helper rejeita combinações que o catálogo não implementa.

Para Mongo local, `local_prerequisites_resolved=true` pode registrar a escolha explícita de criar infraestrutura Compose: não significa que o serviço foi iniciado ou que o ping foi validado. Com Google, credenciais não entram nas respostas; o template AUTH.md explica o registro do cliente OAuth. `python3 scripts/configure-local.py --mode docker` cria .env com chave de sessão aleatória, permissões 0600 e sem sobrescrever arquivo existente. Google não configurado retorna 503 no login e não libera sessão.

`ready_for_prd` continua sendo o resultado das verificações de código, integridade e builds. Não representa validação de credenciais Google reais; documente a ativação externa pendente separadamente de requisitos estruturais. Os testes Google validam tokens e fluxos contra HTTP simulado, sem contas externas.


## Workspace e limpeza

Antes de criar arquivos temporários:

```
python3 SKILL_DIR/scripts/scaffold.py workspace --target /path/project
```

O JSON retornado contém `workspace`, um diretório exclusivo em tempfile.gettempdir() (pode ser /tmp ou o diretório temporário privado do SO). Use esse caminho em WORKSPACE; grave nele answers.json, venv, cache pip/npm e metadados. Não use /tmp inteiro como workspace. A propriedade é registrada com marcador e token, validados antes de apagar. verify limpa somente esses diretórios após publicar os documentos. Não apagar arquivos de entrada externos fornecidos pelo usuário; só temporários registrados são automaticamente removidos.

Em tentativa interrompida: `cleanup --target /path/project` remove workspaces registrados e preserva .scaffold/ para retomada. Falhas preservam o estado; sucesso remove .scaffold/ totalmente. Um projeto finalizado deve ser evoluído com os comandos documentados em docs/testing.md, sem depender do gerador nem recriar seu estado.

`intent` admite parágrafos/listas (até 20 mil caracteres), preservados no pré-PRD; `description` continua uma linha curta. O status de prontidão fica no relatório final de verificação; o pré-PRD é a versão 0 permanente do contexto, não um PRD de produto.
