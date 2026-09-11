"""Documentation generated from the selected files, not from sample repositories."""
import ast
import json
from pathlib import PurePosixPath
import re


def safe(s):
    return str(s).replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('|','&#124;').replace('`','&#96;').replace('\n','<br>')


def build(a, files):
    back = '' if a['profile']=='api-root' else 'back/'
    cwd = '.' if not back else 'back'
    front = a['profile']=='fullstack'
    google = a['authentication']=='google'
    entries=[];envs=set();routes=[];settings=[]
    for path, info in sorted(files.items()):
        body=info['body'];symbols=[];imports=[]
        if path.endswith('.py'):
            tree=ast.parse(body)
            for n in tree.body:
                if isinstance(n,(ast.ClassDef,ast.FunctionDef,ast.AsyncFunctionDef)):
                    symbols.append(n.name)
                if isinstance(n,ast.ImportFrom) and (n.module or '').startswith('app'):
                    imports.append(n.module)
            for cls in tree.body:
                if isinstance(cls,ast.ClassDef) and cls.name=='Settings':
                    for field in cls.body:
                        if isinstance(field,ast.AnnAssign) and isinstance(field.target,ast.Name):
                            settings.append((path,field.target.id,ast.unparse(field.annotation),field.lineno))
            for n in ast.walk(tree):
                if isinstance(n,(ast.FunctionDef,ast.AsyncFunctionDef)):
                    for d in n.decorator_list:
                        if isinstance(d,ast.Call) and isinstance(d.func,ast.Attribute) and d.func.attr in ['get','post','put','delete','patch'] and d.args and isinstance(d.args[0],ast.Constant):
                            routes.append((path,n.name,d.func.attr.upper(),str(d.args[0].value)))
        if path.endswith(('.tsx','.ts')):
            symbols=re.findall(r'export\s+(?:default\s+)?(?:function|class|const|interface|type)\s+(\w+)',body)
        if path.endswith('.env.example'):
            envs.update(re.findall(r'^([A-Z][A-Z0-9_]*)=',body,re.M))
        role=('Teste e regressão' if '/test' in '/'+path else 'Configuração e segredos por ambiente' if 'config' in path or '.env' in path else 'Autenticação e sessão' if 'auth' in path.lower() else 'Entrada e composição da aplicação' if path.endswith(('main.py','main.tsx','App.tsx')) else 'Rota técnica HTTP' if '/api/' in path else 'Acesso/ciclo de vida Mongo' if '/db/' in path else 'Infraestrutura HTTP/logs' if '/core/' in path else 'Pipeline de validação' if path.startswith('.github/') else 'Build/container/proxy' if path.startswith('build/') or path.endswith(('.sh','nginx.conf','compose.yml')) else 'Dependências/lockfile' if 'package' in path or path.endswith(('pyproject.toml','requirements.txt')) else 'Estilo do shell' if path.endswith('.css') else 'Suporte do scaffold')
        entries.append(dict(path=path,role=role,symbols=symbols,internal_imports=imports))
    docs={}
    docs['docs/pre-prd.md']='\n'.join([
        '---','artifact: pre-prd','version: 0','status: initial-context','next: write-prd','---','',
        '# '+safe(a['project_name'])+' — contexto inicial (v0)','',
        '## Ideia inicial','',safe(a['intent']).replace('<br>','\n'),'',
        '## Descrição','',safe(a['description']),'',
        '## Objetivo deste início','',
        'Preparar a base técnica para transformar a ideia acima na primeira entrega. O comportamento de negócio ainda será especificado no PRD; este documento preserva a intenção e as decisões já resolvidas.',
        '', '## Estrutura escolhida','',
        '| Decisão | Valor |','|---|---|',
        *['| '+safe(k)+' | '+safe(json.dumps(a[k],ensure_ascii=False))+' |' for k in ['profile','authentication','messaging','worker','required_adapters','deployment','docker','ci','mongo_mode','frontend_theme','backend_port','frontend_port','frontend_container_port']],
        '', '## Escopo técnico entregue','',
        '- API FastAPI com logs, correlação de requisição, health/readiness e versão; MongoDB configurável.',
        '- SPA React com proxy de API.' if front else '- Aplicação somente backend.',
        '- Login Google, sessão e logout técnicos; ativação real requer credenciais e redirect URI.' if google else '- Sem autenticação neste perfil.',
        '', '## Fora do escopo da v0','',
        'Entidades e regras de negócio, endpoints de produto, telas funcionais, critérios de aceite e a definição da primeira entrega. Não presumir que os exemplos técnicos definam o domínio.',
        '', '## Decisões e premissas','',
        'Veja [decisions.md](decisions.md). Defaults aceitos podem ser alterados numa decisão explícita; não reabrir escolhas confirmadas sem motivo.',
        '', '## Questões para o primeiro PRD','',
        *['- '+safe(x) for x in a.get('prd_questions',['Quem utilizará a primeira entrega e qual resultado precisa alcançar?','Qual comportamento entra e fica fora da primeira entrega?','Quais critérios de aceite demonstram esse resultado?'])],
        '', '## Evidência técnica e próximo passo','',
        'Leia [testing.md](testing.md) e o relatório de validação quando disponível. Execute `/write-prd` usando este documento como contexto de entrada; depois `/write-user-stories` e `/story-loop`. A conclusão das verificações está em `docs/scaffold-verification.json`; a presença deste documento não significa que testes já passaram.',''])
    docs['docs/README.md']='''# Documentação do projeto

Comece por [pre-prd.md](pre-prd.md), contexto v0, e [../AGENTS.md](../AGENTS.md), instruções para trabalhar neste repositório.

| Documento | Quando ler |
|---|---|
| [ai-navigation.md](ai-navigation.md) | Encontrar qualquer arquivo/símbolo e escolher onde mudar |
| [architecture.md](architecture.md) | Entender processos, HTTP, banco e limites |
| [development.md](development.md) | Instalar, executar e verificar localmente |
| [configuration.md](configuration.md) | Configurar ambiente sem expor segredos |
| [testing.md](testing.md) | Conhecer cobertura e limites dos testes |
| [decisions.md](decisions.md) | Respeitar escolhas já tomadas |
| [code-map.json](code-map.json) | Consultar o inventário estruturado de arquivos |

Após conclusão: scaffold-manifest.json guarda checksums; scaffold-verification.json guarda resultados; scaffold-telemetry.jsonl e scaffold-telemetry-summary.md guardam metadados da execução. Antes da conclusão, esses relatórios podem ainda não existir. A documentação é permanente; o diretório de execução temporária não é necessário para entender ou evoluir o projeto.
'''
    docs['AGENTS.md']=f'''# Guia para agentes — {safe(a['project_name'])}

## Ordem de leitura

1. `docs/pre-prd.md`: ideia inicial v0 e limites da primeira entrega ainda não especificada.
2. `docs/README.md` e `docs/architecture.md`: estrutura e decisões técnicas.
3. `docs/ai-navigation.md` ou `docs/code-map.json`: arquivos/símbolos relevantes para a tarefa.
4. `docs/development.md`, `docs/configuration.md`, `docs/testing.md`: execução e evidências.

## Onde trabalhar

Backend: `{back}app/`; testes: `{back}tests/`. {'Frontend: `front/src/` e seus testes; proxy/build em `front/vite.config.ts`, `front/nginx.conf` e `build/` quando presentes.' if front else 'Este perfil não tem frontend.'}

Não deduza regra de negócio a partir de health, sessão ou exemplos técnicos. Use `/write-prd` com `docs/pre-prd.md` para definir a primeira entrega; depois `/write-user-stories` e `/story-loop`. Nenhum workflow preliminar de modelagem é necessário.

## Contrato de manutenção

- Preserve alterações existentes e leia as instruções adicionais na área que for modificar.
- A configuração vem do ambiente; documente nomes/finalidade, nunca valores secretos. Não rode testes contra produção.
- Mantenha código e documentação juntos: novo módulo/rota/config/comando exige atualização do mapa, arquitetura/configuração e testes correspondentes.
- Antes de entregar, execute as verificações relevantes em `docs/testing.md`; reporte o que passou, falhou ou não foi executado. Não transforme ausência de ferramenta em sucesso.
- O manifesto e o code-map registram o baseline do scaffold. Ao evoluir o produto, atualize o mapa; não trate os checksums históricos como bloqueio a alterações autorizadas.
- Respeite os limites de autenticação descritos em AUTH.md quando presente; não exponha endpoints de produto sem aplicar a política escolhida.

## Descoberta rápida

Use `rg --files` para localizar arquivos e `rg` para buscar símbolos; prefira leitura direcionada pelo mapa. A documentação contém referências relativas ao repositório e não depende da conversa que gerou o projeto.
'''
    docs['CLAUDE.md']='# Instruções para Claude Code\n\n@AGENTS.md\n'
    docs['agent.MD']='# Entrada para agentes\n\nAs instruções canônicas deste repositório estão em [AGENTS.md](AGENTS.md). Comece também por [docs/pre-prd.md](docs/pre-prd.md) e [docs/README.md](docs/README.md).\n'
    docs['docs/architecture.md']=f'''# Arquitetura do scaffold

Perfil `{a['profile']}`. Backend em `{cwd}`: `{back}app/main.py` compõe FastAPI, lifecycle Mongo e rotas técnicas. `{back}app/core/config.py` define Settings; logs e middleware HTTP ficam em core/; db/mongo.py gerencia conexão. Imports internos e pontos de entrada exatos estão em code-map.json.

HTTP → middleware/correlação → rotas técnicas → Mongo quando necessário. Liveness não depende do banco; readiness verifica Mongo. Domínio e serviços de produto serão definidos pela primeira entrega, não existem implicitamente neste scaffold.

{'Frontend: front/src/main.tsx monta App.tsx. Em desenvolvimento o Vite faz proxy da API; no container nginx serve os assets e encaminha as chamadas. O cliente mantém a mesma origem.' if front else 'Não há processo frontend neste perfil.'}

{'Autenticação: Google OIDC com Authlib, PKCE, cookie assinado HttpOnly e sessão revogável/expirável no Mongo. Tokens Google não são persistidos. AUTH.md documenta registro OAuth e dependências de autenticação. Testes locais não comprovam consentimento real no Google.' if google else 'Sem autenticação: não presumir controle de acesso existente para futuras rotas.'}

Mongo: `{a['mongo_mode']}`. {'Compose fornece serviço local, volume e healthcheck; não equivale a deploy produtivo.' if a['mongo_mode']=='compose' else 'Instância externa configurada por ambiente; disponibilidade real é requisito operacional.'}

## Rotas encontradas

Os caminhos abaixo são os literais das declarações; prefixos de montagem devem ser conferidos no entrypoint e em `/docs` (OpenAPI).

| Método | Caminho declarado | Função | Arquivo |
|---|---|---|---|
'''+''.join(f'| {method} | `{safe(route)}` | `{name}` | `{path}` |\n' for path,name,method,route in routes)
    docs['docs/development.md']=f'''# Desenvolvimento local

Pré-requisitos: Python 3.11+, MongoDB conforme configuration.md. {'Node 20 e npm para o frontend.' if front else ''} {'Docker/Compose para os containers.' if a['docker'] else 'Docker não foi selecionado.'}

No diretório `{cwd}`:

```sh
python3.11 -m venv .venv
.venv/bin/python -m pip install -e '.[dev]'
cp .env.example .env
```

Preencha as configurações locais documentadas; ative `.venv` antes de executar `make dev`, `make lint` ou `make test`. Porta backend: {a['backend_port']}. Abra `/docs` para conferir os endpoints efetivamente registrados. Não reutilize configurações de outro projeto.

'''+(f'''No diretório `front/`:

```sh
npm ci
npm run dev
npm run typecheck
npm test
npm run build
```

Vite: {a['frontend_port']}. Container frontend: {a['frontend_container_port']}.

''' if front else '')+('''Na raiz, após preencher o env_file backend:

```sh
docker compose config --quiet
docker compose up --build
```

Mongo externo exige MONGO_URI acessível do container, não o localhost do host. Mongo de Compose usa o hostname do serviço. Encerrar com `docker compose down`; não apague volumes sem intenção de perder os dados locais.
''' if a['docker'] else '')
    docs['docs/configuration.md']='''# Configuração

Fonte de verdade: os arquivos `.env.example` e a classe Settings do backend; nunca copie credenciais para docs, commits, contexto ou telemetria. Os exemplos contêm apenas configuração de referência; revise-os antes de rodar. Dependências reais e credenciais Google não são testadas pelo scaffold.

## Variáveis declaradas nos exemplos

'''+''.join('- `'+key+'`\n' for key in sorted(envs))+f'''
Backend/API: porta {a['backend_port']}; Vite: {a['frontend_port']}; frontend container: {a['frontend_container_port']}. Banco lógico deriva do nome do projeto. Mongo mode: `{a['mongo_mode']}`. Consulte Settings para aliases, defaults, validação e propriedades derivadas; não adivinhe o nome de uma variável ausente deste inventário.

''' + ('Leia também [../AUTH.md](../AUTH.md) para client ID/secret, session secret, redirect URI, cookies e autenticação real.\n' if google else '')
    docs['docs/configuration.md']+='\n## Campos tipados de Settings\n\nOs defaults e aliases exatos ficam na definição indicada; valores secretos não são reproduzidos.\n\n| Campo | Tipo | Definição |\n|---|---|---|\n'+''.join(f'| `{name}` | `{safe(kind)}` | `{path}:{line}` |\n' for path,name,kind,line in settings)
    docs['docs/testing.md']=f'''# Verificação e limites

Backend (cwd `{cwd}`, venv ativo):

```sh
make lint
make test
```

O lint executa Ruff e mypy; pytest cobre as rotas técnicas usando banco substituto. Veja o inventário em ai-navigation.md para todos os arquivos e símbolos de teste. {'O perfil Google acrescenta testes de OIDC/sessão usando respostas locais; isso não comprova uma configuração real do provedor.' if google else ''}

'''+('Frontend (cwd `front/`): `npm run typecheck`, `npm test`, `npm run build`.\n\n' if front else '')+('Containers: `docker compose config --quiet` e `docker build --build-arg SERVICE=back -f build/Dockerfile .`'+(' (também SERVICE=front).' if front else '.')+'\n\n' if a['docker'] else '')+'''Os resultados executados são publicados em scaffold-verification.json após conclusão; não inferir sucesso pela presença desta documentação. Testes unitários/build não comprovam disponibilidade de Mongo real, OAuth real, integração de negócio ou deploy. Ao acrescentar funcionalidade, crie testes do comportamento e atualize este documento.
'''
    docs['docs/development.md']+='\n## Diagnóstico\n\n- Readiness 503: conferir endereço/rede do Mongo e sua disponibilidade; liveness 200 isolado não comprova banco acessível.\n- Falha de configuração no boot: conferir Settings e nomes de variáveis em configuration.md, sem imprimir valores secretos.\n- Frontend sem API: conferir porta/proxy e upstream nginx quando selecionado.\n- Login indisponível: consultar AUTH.md quando presente e ativação OAuth; testes locais não registram credenciais reais.\n'
    docs['docs/decisions.md']='# Decisões técnicas\n\n| Chave | Valor | Origem | Evidência |\n|---|---|---|---|\n'+''.join('| '+' | '.join(safe(json.dumps(d.get(k,''),ensure_ascii=False)) for k in ['key','value','origin','evidence'])+' |\n' for d in a.get('decisions',[]))+'\nEscolhas explícitas prevalecem sobre defaults. Este documento registra o baseline, não o escopo funcional do produto.\n'
    docs['docs/ai-navigation.md']='# Mapa de navegação para IAs\n\nInventário completo dos arquivos técnicos gerados. Consulte code-map.json para imports internos e símbolos estruturados. Cada linha identifica o papel e os símbolos exportados/declarados; arquivos de dados e lockfiles não precisam ser lidos integralmente para descobrir a aplicação.\n\n| Arquivo | Papel | Símbolos |\n|---|---|---|\n'+''.join('| [`'+e['path']+'`](../'+e['path']+') | '+e['role']+' | '+safe(', '.join(e['symbols']) or '—')+' |\n' for e in entries)+'\nDocumentação: pre-prd.md preserva a ideia; architecture.md os limites; configuration.md as variáveis; development.md os comandos; testing.md a verificação; decisions.md as escolhas. AGENTS.md é a entrada canônica e agent.MD aponta para ela.\n'
    docs['docs/code-map.json']=json.dumps(dict(version=1,profile=a['profile'],files=entries,documentation=sorted([*docs,'docs/code-map.json'])),ensure_ascii=False,indent=2)+'\n'
    return docs
