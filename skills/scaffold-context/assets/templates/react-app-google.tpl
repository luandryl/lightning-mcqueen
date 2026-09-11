import { useEffect, useState } from 'react';

type User = { sub: string; email: string; name: string };
type State = { kind: 'loading' } | { kind: 'guest' } | { kind: 'error' } | { kind: 'ready'; user: User };

export default function App() {
  const [state, setState] = useState<State>({ kind: 'loading' });
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState(() =>
    new URLSearchParams(window.location.search).has('auth_error')
      ? 'Não foi possível entrar com Google. Tente novamente.' : '');

  useEffect(() => {
    const controller = new AbortController();
    void fetch('/v1/auth/session', { credentials: 'same-origin', signal: controller.signal })
      .then(async response => {
        if (response.status === 401) { setState({ kind: 'guest' }); return; }
        if (!response.ok) throw new Error('Session unavailable');
        const user: User = await response.json();
        if (!controller.signal.aborted) setState({ kind: 'ready', user });
      }).catch(() => { if (!controller.signal.aborted) setState({ kind: 'error' }); });
    if (new URLSearchParams(window.location.search).has('auth_error')) {
      window.history.replaceState(null, '', window.location.pathname);
    }
    return () => controller.abort();
  }, []);

  async function logout() {
    setBusy(true); setMessage('');
    try {
      const response = await fetch('/v1/auth/logout', { method: 'POST', credentials: 'same-origin' });
      if (!response.ok) throw new Error('Logout failed');
      setState({ kind: 'guest' });
    } catch { setMessage('Não foi possível sair. Tente novamente.'); }
    finally { setBusy(false); }
  }

  return <div className="auth-shell" data-theme="{{ frontend_theme }}">
    <header className="site-header"><span className="wordmark"><span className="leaf" aria-hidden="true" />{{ project_name }}<span className="brand-dot">.</span></span></header>
    <main className="auth-main">
      <p className="eyebrow">Seu espaço</p>
      <h1>{{ project_name }}</h1>
      {state.kind === 'loading' && <p role="status">Verificando sua sessão…</p>}
      {state.kind === 'guest' && <>
        <p>Entre com sua conta Google para continuar.</p>
        <a className="google-button" href="/v1/auth/google/login"><svg aria-hidden="true" width="20" height="20" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5Z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6C44.4 38.03 46.98 31.86 46.98 24.55Z"/><path fill="#FBBC05" d="M10.53 28.59A14.41 14.41 0 0 1 9.75 24c0-1.59.27-3.13.76-4.59l-7.98-6.19A23.87 23.87 0 0 0 0 24c0 3.87.93 7.53 2.56 10.78l7.97-6.19Z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.91-5.8l-7.73-6c-2.15 1.45-4.92 2.3-8.18 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48Z"/></svg>Entrar com Google</a>
      </>}
      {state.kind === 'error' && <><p role="alert">Não foi possível verificar sua sessão. Confira sua conexão.</p><button className="secondary" onClick={() => window.location.reload()}>Tentar novamente</button></>}
      {state.kind === 'ready' && <div className="account-card"><p className="eyebrow">Conta conectada</p><h2>Olá, {state.user.name}.</h2><p>{state.user.email}</p><button className="secondary" disabled={busy} onClick={() => void logout()}>{busy ? 'Saindo…' : 'Sair'}</button></div>}
      {message && <p className="feedback" role="alert">{message}</p>}
    </main>
  </div>;
}
