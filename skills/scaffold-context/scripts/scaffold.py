#!/usr/bin/env python3
"""Deterministic scaffold generator; Python 3.11+, stdlib only."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from urllib.parse import urlsplit
from uuid import uuid4

from documentation import build as build_documentation

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets'
MARKER = 'scaffold-context'
FIELDS = set('project_name intent description profile profile_accepted authentication messaging worker required_adapters deployment local_prerequisites_resolved docker ci backend_port frontend_port frontend_container_port mongo_container_uri mongo_mode frontend_theme prd_questions decisions unresolved'.split())
REQUIRED = set('project_name intent profile profile_accepted authentication messaging worker required_adapters deployment local_prerequisites_resolved'.split())
TOKEN = re.compile(r'{{\s*(\w+)\s*}}')


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + '.tmp-' + uuid4().hex)
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')
    os.replace(tmp, path)


def read_json(path):
    return json.loads(Path(path).read_text())


def digest(body):
    return hashlib.sha256(body).hexdigest()


def text(value):
    return str(value).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('|', '&#124;').replace('`', '&#96;').replace('\n', '<br>')


def event(target, kind, phase, status='running', **data):
    folder = target / '.scaffold'
    folder.mkdir(parents=True, exist_ok=True)
    row = dict(timestamp=datetime.now(timezone.utc).isoformat(), run_id=RUN_ID,
               event=kind, phase=phase, status=status, **data)
    with (folder / 'telemetry.jsonl').open('a') as handle:
        handle.write(json.dumps(row, ensure_ascii=False) + '\n')


def summary(target):
    rows = [json.loads(x) for x in (target / '.scaffold/telemetry.jsonl').read_text().splitlines()]
    lines = ['# Scaffold execution', '', '| Run | Phase | Event | Status | Duration ms |', '|---|---|---|---|---|']
    for r in rows:
        if r['event'] in ('run_completed', 'phase_completed', 'validation_completed', 'validation_failed', 'agent_completed', 'agent_escalated'):
            lines.append('| ' + ' | '.join(text(r.get(k, '')) for k in ['run_id', 'phase', 'event', 'status', 'duration_ms']) + ' |')
    lines += ['', 'Direct helper operations use no reasoning agent. Agent tokens are available only when explicitly recorded; missing usage is not zero.']
    (target / '.scaffold/telemetry-summary.md').write_text('\n'.join(lines) + '\n')


def validate(a, partial=False):
    if not isinstance(a, dict) or set(a) - FIELDS:
        raise ValueError('Unknown answer fields or invalid object')
    missing = sorted(REQUIRED - set(a))
    if missing and not partial:
        raise ValueError('Missing answers: ' + ', '.join(missing))
    if 'intent' in a and (not isinstance(a['intent'],str) or not a['intent'].strip() or len(a['intent'])>20000 or any(ord(c)<32 and c not in '\n\t' for c in a['intent'])):
        raise ValueError('intent must be nonempty text, max 20000 characters')
    if 'description' in a and (not isinstance(a['description'],str) or not a['description'].strip() or len(a['description'])>500 or any(ord(c)<32 for c in a['description'])):
        raise ValueError('description must be single-line text, max 500 characters')
    if 'project_name' in a and (not isinstance(a['project_name'], str) or not re.fullmatch(r'[a-z][a-z0-9]*(?:-[a-z0-9]+)*', a['project_name']) or len(a['project_name']) > 63):
        raise ValueError('Invalid project_name')
    for key in ['profile_accepted', 'worker', 'docker', 'ci', 'local_prerequisites_resolved']:
        if key in a and type(a[key]) is not bool:
            raise ValueError(key + ' must be boolean')
    for key in ['required_adapters', 'unresolved', 'prd_questions']:
        if key in a and (not isinstance(a[key], list) or any(not isinstance(x, str) for x in a[key])):
            raise ValueError(key + ' must be a list of strings')
    if 'decisions' in a and (not isinstance(a['decisions'], list) or any(not isinstance(x, dict) or set(x) - {'key','value','origin','evidence','confidence'} for x in a['decisions'])):
        raise ValueError('Invalid decisions metadata')
    if partial:
        return a, missing
    if a['profile'] not in ['api-root', 'api-monorepo', 'fullstack']:
        raise ValueError('Unsupported profile')
    if a['profile_accepted'] is not True or a['authentication'] not in ['none', 'google'] or a['messaging'] != 'none' or a['worker'] is not False or a['required_adapters'] or a['deployment'] not in ['unspecified', 'local']:
        raise ValueError('Required structure is not supported by this catalog')
    if a['local_prerequisites_resolved'] is not True or a.get('unresolved'):
        raise ValueError('Resolve structural/local prerequisites before generating')
    if a['authentication'] == 'google' and a['profile'] != 'fullstack':
        raise ValueError('Google authentication requires the fullstack same-origin proxy profile')
    if a.get('mongo_mode', 'external') not in ['external', 'compose']:
        raise ValueError('mongo_mode must be external or compose')
    if a.get('frontend_theme', 'light') not in ['light', 'dark']:
        raise ValueError('frontend_theme must be light or dark')
    if a.get('frontend_theme', 'light') != 'light' and a['authentication'] != 'google':
        raise ValueError('Dark theme currently requires the Google fullstack shell')
    a = dict(a)
    a.setdefault('mongo_mode', 'external')
    a.setdefault('frontend_theme', 'light')
    if a['mongo_mode'] == 'compose':
        if not a.get('docker', True):
            raise ValueError('Compose Mongo requires Docker')
        if a.get('mongo_container_uri', 'mongodb://mongo:27017') != 'mongodb://mongo:27017':
            raise ValueError('Compose Mongo URI is fixed to mongodb://mongo:27017')
        a['mongo_container_uri'] = 'mongodb://mongo:27017'
    supplied = set(a)
    a = dict(description=a['intent'].splitlines()[0][:500], docker=True, ci=True, backend_port=8208, frontend_port=5180, frontend_container_port=3105, **{k:v for k,v in a.items() if k not in ['description','docker','ci','backend_port','frontend_port','frontend_container_port']}) | {k:a[k] for k in ['description','docker','ci','backend_port','frontend_port','frontend_container_port'] if k in a}
    for key in ['backend_port', 'frontend_port', 'frontend_container_port']:
        if type(a[key]) is not int or not 1024 <= a[key] <= 65535:
            raise ValueError('Invalid port: ' + key)
    if a['profile'] == 'fullstack' and len({a[k] for k in ['backend_port','frontend_port','frontend_container_port']}) != 3:
        raise ValueError('Ports collide')
    if a['docker']:
        uri = a.get('mongo_container_uri', '')
        u = urlsplit(uri)
        if u.scheme != 'mongodb' or not u.hostname or u.username or u.password or u.query or u.fragment or u.path not in ('', '/'):
            raise ValueError('Provide mongo_container_uri without credentials/query/database path')
        if any(c.isspace() for c in uri):
            raise ValueError('Invalid Mongo host')
        if u.port is not None and not 1 <= u.port <= 65535:
            raise ValueError('Invalid Mongo port')
    decisions = list(a.get('decisions', []))
    recorded = {d.get('key') for d in decisions}
    for key in ['profile','authentication','messaging','worker','deployment','docker','ci','backend_port','frontend_port','frontend_container_port','mongo_mode','frontend_theme']:
        if key not in recorded:
            decisions.append(dict(key=key,value=a[key],origin='user' if key in supplied else 'profile-default',evidence='explicit answer' if key in supplied else 'catalog-default-v2',confidence='CONFIRMED'))
    a['decisions'] = decisions
    return a, []


def context(target, a, status, pending=None, checks=None):
    ready = status == 'ready'
    lines = ['---', 'artifact: scaffold-context', 'version: 1', 'status: ' + status,
             'ready_for_prd: ' + str(ready).lower(), 'next: write-prd',
             'profile: ' + json.dumps(a.get('profile', 'unselected')), '---', '', '# Contexto do projeto', '',
             '## Projeto', '', '**Nome:** ' + text(a.get('project_name','unknown')),
             '', '**Descrição:** ' + text(a.get('description',a.get('intent','unknown'))),
             '', '## Intenção e direção inicial', '', text(a.get('intent','unknown')),
             '', '## Estrutura e decisões', '', '| Decisão | Escolha |', '|---|---|']
    # Endpoint is deliberately omitted; keep no connection strings in context.
    for k in sorted(a):
        if k not in ['intent','description','mongo_container_uri','decisions','prd_questions']:
            lines.append('| ' + text(k) + ' | ' + text(json.dumps(a[k], ensure_ascii=False)) + ' |')
    lines += ['', '## Perfil técnico', '', 'Python 3.11, FastAPI, MongoDB. Frontend React/Vite/TypeScript/Tailwind apenas em fullstack. Login Google quando authentication=google; instruções em AUTH.md.' if a.get('profile_accepted') else 'Perfil técnico ainda não aceito.',
              '', '## Origem das decisões', '', 'Perfil técnico aceito pelo usuário. Layout raiz ou back/ conforme perfil explícito. Defaults aplicados apenas após aceitação do perfil.']
    for d in a.get('decisions',[]):
        lines.append('- ' + text(json.dumps(d, ensure_ascii=False)))
    lines += ['', '## Execução local', '', 'Backend: raiz para api-root, back/ nos demais. Instalar em venv com pip install -e ".[dev]"; make dev; make lint; make test. Mongo por ambiente; mongo_mode=compose inclui serviço local no Docker Compose. No frontend: npm ci, npm run dev, npm run typecheck, npm test, npm run build.',
              '', '## Deploy', '', text(a.get('deployment','unknown')), '', '## Premissas', '', 'Sem implementação de produto; verificação sem conexão real a integrações. Login Google usa tokens assinados e respostas HTTP locais nos testes; credenciais e consentimento reais exigem configuração no Google Cloud. A disponibilidade real do Mongo é distinta dos testes com substituto.',
              '', '## Pendências estruturais', '']
    lines += ['- ' + text(x) for x in pending] if pending else ['Nenhuma.' if ready else 'Geração/verificação ainda não concluída.']
    lines += ['', '## Questões para o PRD', ''] + ['- ' + text(x) for x in a.get('prd_questions',['Definir primeira entrega, comportamento, escopo e critérios de aceite.'])]
    lines += ['', '## Manifesto e verificação', '', 'Manifesto: .scaffold/scaffold-manifest.json; resultados: .scaffold/verification.json.']
    if checks:
        lines += ['- ' + text(c['id']) + ': ' + c['status'] for c in checks]
    lines += ['', '## Próximo passo', '', 'Executar /write-prd usando este contexto para definir a primeira entrega. Depois /write-user-stories e /story-loop.' if ready else 'Resolver pendências e executar verify; ainda não pronto para /write-prd.']
    (target / '.scaffold/CONTEXT.md').write_text('\n'.join(lines) + '\n')
    event(target,'artifact_written','context','completed',path='.scaffold/CONTEXT.md')


def owned(target, allow_generated=False):
    if target.is_symlink():
        raise ValueError('Refuse symlink target')
    if not target.exists():
        return
    children = list(target.iterdir())
    if not children:
        return
    state = target / '.scaffold/answers.json'
    if (target / '.scaffold').is_symlink() or not state.is_file() or state.is_symlink():
        raise ValueError('Target is not an empty directory or managed draft')
    data = read_json(state)
    if data.get('artifact') != MARKER:
        raise ValueError('Unrecognized state')
    if not allow_generated and (data.get('generated') or any(p.name != '.scaffold' for p in children)):
        raise ValueError('Refuse to overwrite an existing scaffold')


def expand(a):
    index = read_json(ASSETS / 'template-index.json')
    c = dict(a, google_auth=a['authentication']=='google', local_mongo=a['mongo_mode']=='compose', backend=True, frontend=a['profile']=='fullstack', monorepo=a['profile']!='api-root',
             backend_dir='' if a['profile']=='api-root' else 'back/',
             docs_from_backend='docs/' if a['profile']=='api-root' else '../docs/',
             backend_workdir='.' if a['profile']=='api-root' else 'back',
             backend_glob='**' if a['profile']=='api-root' else 'back/**',
             env_prefix=a['project_name'].upper().replace('-','_'),
             project_description=text(a['description']), description_json=json.dumps(a['description'], ensure_ascii=False))
    def render(s):
        return TOKEN.sub(lambda m: str(c[m.group(1)]), s)
    output = {}
    for e in index:
        yes = all(not c[t[4:]] if t.startswith('not ') else True if t == 'always' else c[t] for t in e['condition'].split(' and '))
        if not yes:
            continue
        raw = (ASSETS/e['template']).read_bytes()
        if digest(raw) != e['sha256']:
            raise ValueError('Template hash mismatch: '+e['id'])
        dest = render(e['destination'])
        if Path(dest).is_absolute() or '..' in Path(dest).parts or dest in output:
            raise ValueError('Unsafe or conflicting destination')
        body = render(raw.decode())
        if e['id']=='root-readme' and not c['frontend']:
            body=body.replace(' Frontend, when selected: `front/` (React/Vite).','').replace(' Frontend: `npm ci`, `npm run dev`, `npm run typecheck`, `npm test`, `npm run build` from `front/`.','')
        # A literal marker in user text is allowed as data; no recursive substitution.
        output[dest] = dict(body=body, template_id=e['id'], template_sha256=e['sha256'], rendered_sha256=digest(body.encode()), mode='0755' if dest.endswith('.sh') else '0644')
    for dest, body in build_documentation(a, output).items():
        if dest in output:
            raise ValueError('Documentation destination collision: '+dest)
        output[dest] = dict(body=body,template_id='documentation-v2',template_sha256=digest((ROOT/'scripts/documentation.py').read_bytes()),rendered_sha256=digest(body.encode()),mode='0644')
    return output, digest(json.dumps(index,sort_keys=True).encode())


def state(target, a, generated):
    write_json(target/'.scaffold/answers.json',dict(artifact=MARKER,version=1,generated=generated,answers=a))


def generate(target,a):
    owned(target)
    output, revision = expand(a)
    target.parent.mkdir(parents=True,exist_ok=True)
    stage=Path(tempfile.mkdtemp(prefix='.scaffold-',dir=target.parent))
    try:
        if (target/'.scaffold').exists():
            shutil.copytree(target/'.scaffold',stage/'.scaffold')
        else:
            (stage/'.scaffold').mkdir()
        for dest,info in output.items():
            path=stage/dest;path.parent.mkdir(parents=True,exist_ok=True);path.write_text(info['body']);path.chmod(int(info['mode'],8))
        state(stage,a,True)
        write_json(stage/'.scaffold/scaffold-manifest.json',dict(artifact=MARKER,version=1,template_revision=revision,profile=a['profile'],files=[dict(path=p,**{k:v for k,v in data.items() if k!='body'}) for p,data in sorted(output.items())]))
        event(stage,'run_started','generate',phase_weights=dict(render=70,context=30))
        event(stage,'phase_started','render')
        for dest in output:event(stage,'artifact_written','render','completed',path=dest)
        event(stage,'phase_progress','render',completed_units=len(output),total_units=len(output))
        context(stage,a,'draft',pending=['Executar validação do scaffold.'])
        event(stage,'phase_completed','render','completed',duration_ms=int((time.monotonic()-START)*1000))
        event(stage,'run_completed','generate','completed',duration_ms=int((time.monotonic()-START)*1000))
        summary(stage)
        # Swap only a verified managed draft, preserving its state in staging.
        backup=None
        if target.exists():
            owned(target)
            backup=target.with_name('.scaffold-backup-'+uuid4().hex)
            target.rename(backup)
        try:stage.rename(target)
        except BaseException:
            if backup:backup.rename(target)
            raise
        if backup:shutil.rmtree(backup)
    finally:
        if stage.exists():shutil.rmtree(stage)
    return dict(files=len(output),target=str(target),ready_for_prd=False)


def integrity(target):
    owned(target,True)
    s=read_json(target/'.scaffold/answers.json')
    if not s.get('generated'):raise ValueError('Scaffold not generated')
    a,_=validate(s['answers']);output,revision=expand(a)
    manifest=read_json(target/'.scaffold/scaffold-manifest.json')
    expected=[dict(path=p,**{k:v for k,v in data.items() if k!='body'}) for p,data in sorted(output.items())]
    if manifest.get('files')!=expected or manifest.get('template_revision')!=revision:
        raise ValueError('Manifest is stale or changed')
    for dest,info in output.items():
        p=target/dest
        if p.is_symlink() or any(x.is_symlink() for x in p.parents if x!=target.parent) or not p.is_file() or digest(p.read_bytes())!=info['rendered_sha256']:
            raise ValueError('Managed file changed: '+dest)
    return a


def verify(target, python):
    owned(target,True)
    a=read_json(target/'.scaffold/answers.json')['answers']
    context(target,a,'blocked',pending=['Verificação em andamento.'])
    checks=[]
    event(target,'run_started','verify')
    try:
        a=integrity(target)
        back=target if a['profile']=='api-root' else target/'back'
        commands=[('ruff',[python,'-m','ruff','check','app','tests'],back),('mypy',[python,'-m','mypy','app'],back),('pytest',[python,'-m','pytest','-q'],back)]
        if a['profile']=='fullstack':
            commands += [(name,['npm','run',name],target/'front') for name in ['typecheck','test','build']]
        if a['docker']:
            # Compose reads a temporary empty env_file; no secrets loaded or overwritten.
            envfile=back/'.env';created=not envfile.exists()
            if created:envfile.write_text('')
            try:
                env=os.environ.copy();env['MONGO_URI']=a['mongo_container_uri']
                run_check(target,checks,'compose',['docker','compose','config','--quiet'],target,env)
            finally:
                if created:envfile.unlink()
            for service in (['back','front'] if a['profile']=='fullstack' else ['back']):
                tag='scaffold-check-'+uuid4().hex
                try:run_check(target,checks,'docker-'+service,['docker','build','--build-arg','SERVICE='+service,'-f','build/Dockerfile','-t',tag,'.'],target)
                finally:subprocess.run(['docker','image','rm',tag],capture_output=True)
        for name,cmd,cwd in commands:run_check(target,checks,name,cmd,cwd)
        # Checks cannot authorize stale/modified generated files.
        integrity(target)
        write_json(target/'.scaffold/verification.json',dict(status='passed',ready_for_prd=True,checks=checks))
        context(target,a,'ready',checks=checks)
        event(target,'run_completed','verify','completed',duration_ms=int((time.monotonic()-START)*1000))
        finalize(target)
        return dict(ready_for_prd=True,checks=len(checks),context='docs/pre-prd.md',temporary_state_removed=True)
    except Exception as ex:
        write_json(target/'.scaffold/verification.json',dict(status='failed',checks=checks))
        context(target,a,'blocked',pending=['Validação falhou; veja resultados e saída do comando.'],checks=checks)
        event(target,'run_completed','verify','failed',duration_ms=int((time.monotonic()-START)*1000))
        raise ex
    finally:
        if (target/'.scaffold').exists():summary(target)


def run_check(target,checks,name,cmd,cwd,env=None):
    t=time.monotonic();event(target,'validation_started','verify',validation_id=name)
    try:
        r=subprocess.run(cmd,cwd=cwd,env=env,timeout=900)
        code=r.returncode
    except (OSError,subprocess.TimeoutExpired):code=127
    row=dict(id=name,status='passed' if code==0 else 'failed',exit_code=code,duration_ms=int((time.monotonic()-t)*1000))
    checks.append(row);event(target,'validation_completed' if code==0 else 'validation_failed','verify',row['status'],validation_id=name,exit_code=code,duration_ms=row['duration_ms'])
    if code:raise ValueError('Validation failed: '+name)


def workspace(target):
    owned(target,True)
    target.mkdir(parents=True,exist_ok=True)
    if not (target/'.scaffold/answers.json').exists():state(target,{},False)
    registry=target/'.scaffold/temporary.json'
    records=read_json(registry) if registry.exists() else []
    path=Path(tempfile.mkdtemp(prefix='scaffold-context-')).resolve()
    token=uuid4().hex
    owner=dict(artifact=MARKER,target=str(target.resolve()),token=token)
    write_json(path/'.scaffold-owner.json',owner)
    records.append(dict(path=str(path),owner=owner))
    write_json(registry,records)
    event(target,'workspace_created','interview','completed',temporary_id=path.name)
    return dict(workspace=str(path))


def cleanup_temporaries(target):
    registry=target/'.scaffold/temporary.json'
    records=read_json(registry) if registry.exists() else []
    for item in records:
        path=Path(item['path'])
        if not path.exists():continue
        if path.is_symlink() or path.resolve().parent!=Path(tempfile.gettempdir()).resolve() or not path.name.startswith('scaffold-context-'):
            raise ValueError('Refuse unowned temporary path')
        marker=path/'.scaffold-owner.json'
        if marker.is_symlink() or not marker.is_file() or read_json(marker)!=item['owner'] or item['owner']['target']!=str(target.resolve()):
            raise ValueError('Temporary ownership marker mismatch')
        shutil.rmtree(path)
    if registry.exists():write_json(registry,[])


def finalize(target):
    # Only called after successful checks and a second integrity check.
    mapping={'scaffold-manifest.json':'scaffold-manifest.json',
             'verification.json':'scaffold-verification.json',
             'telemetry.jsonl':'scaffold-telemetry.jsonl',
             'telemetry-summary.md':'scaffold-telemetry-summary.md'}
    for name in mapping.values():
        if (target/'docs'/name).exists() or (target/'docs'/name).is_symlink():
            raise ValueError('Refuse to overwrite final report: '+name)
    cleanup_temporaries(target)
    event(target,'cleanup_completed','finalize','completed')
    summary(target)
    for source,name in mapping.items():
        with (target/'docs'/name).open('xb') as dest:
            dest.write((target/'.scaffold'/source).read_bytes())
    # All context/docs and operational proof are now permanent.
    shutil.rmtree(target/'.scaffold')


def main():
    p=argparse.ArgumentParser();p.add_argument('command',choices=['plan','draft','generate','verify','event','workspace','cleanup']);p.add_argument('--target',type=Path);p.add_argument('--answers',type=Path);p.add_argument('--python',default=sys.executable);p.add_argument('--metadata',type=Path);args=p.parse_args()
    if args.command!='plan' and args.target is None:p.error('--target required')
    target=args.target.absolute() if args.target else None
    if args.command in ['plan','draft','generate']:
        if not args.answers:p.error('--answers required')
        a,missing=validate(read_json(args.answers),partial=args.command=='draft')
        if args.command=='plan':
            out,rev=expand(a);result=dict(paths=sorted(out),template_revision=rev)
        elif args.command=='generate':result=generate(target,a)
        else:
            owned(target);target.mkdir(parents=True,exist_ok=True);state(target,a,False)
            event(target,'run_started','interview');context(target,a,'draft',pending=missing+a.get('unresolved',[]));event(target,'run_completed','interview','completed');summary(target);result=dict(pending=missing,ready_for_prd=False)
    elif args.command=='workspace':result=workspace(target)
    elif args.command=='cleanup':
        owned(target,True);cleanup_temporaries(target);result=dict(cleaned=True)
    elif args.command=='verify':result=verify(target,str(Path(args.python).absolute()) if '/' in args.python else args.python)
    else:
        owned(target,True)
        if not args.metadata:p.error('--metadata required')
        data=read_json(args.metadata)
        allowed=set('event phase status agent_id task model effort reason_for_routing duration_ms tokens previous_effort new_effort reason unresolved_question evidence_considered completed_units total_units'.split())
        if not isinstance(data,dict) or set(data)-allowed:raise ValueError('Invalid event metadata')
        kind=data.pop('event');phase=data.pop('phase');status=data.pop('status','running')
        event(target,kind,phase,status,**data);summary(target);result=dict(recorded=True)
    print(json.dumps(result,ensure_ascii=False))


RUN_ID='scaffold-'+uuid4().hex
START=time.monotonic()
if __name__=='__main__':
    try:main()
    except (ValueError,KeyError,OSError,TypeError) as exc:
        print('scaffold-context: '+str(exc),file=sys.stderr);sys.exit(2)
