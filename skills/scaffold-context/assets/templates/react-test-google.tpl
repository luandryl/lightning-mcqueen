import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { afterEach, vi } from 'vitest';
import App from '../App';

afterEach(() => { vi.unstubAllGlobals(); window.history.replaceState(null, '', '/'); });
it('offers Google sign-in only after an unauthenticated response', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ status: 401 }));
  render(<App />);
  expect(await screen.findByRole('link', { name: 'Entrar com Google' })).toHaveAttribute('href', '/v1/auth/google/login');
});
it('shows session failures with a retry action', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ status: 503, ok: false }));
  render(<App />);
  expect(await screen.findByRole('alert')).toHaveTextContent('Não foi possível verificar');
  expect(screen.queryByText('Conta conectada')).not.toBeInTheDocument();
});
it('revokes the session when signing out', async () => {
  const fetchMock = vi.fn().mockResolvedValueOnce({ ok: true, json: async () => ({ sub: 'u1', name: 'Ana', email: 'ana@example.test' }) }).mockResolvedValueOnce({ ok: true });
  vi.stubGlobal('fetch', fetchMock);
  render(<App />);
  fireEvent.click(await screen.findByRole('button', { name: 'Sair' }));
  await waitFor(() => expect(fetchMock).toHaveBeenCalledWith('/v1/auth/logout', { method: 'POST', credentials: 'same-origin' }));
  expect(await screen.findByRole('link', { name: 'Entrar com Google' })).toBeInTheDocument();
});
it('keeps the account visible when logout fails', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValueOnce({ ok: true, json: async () => ({ sub: 'u1', name: 'Ana', email: 'ana@example.test' }) }).mockRejectedValueOnce(new Error('offline')));
  render(<App />);
  fireEvent.click(await screen.findByRole('button', { name: 'Sair' }));
  expect(await screen.findByRole('alert')).toHaveTextContent('Não foi possível sair');
  expect(screen.getByText('Conta conectada')).toBeInTheDocument();
});
it('explains an OAuth failure', async () => {
  window.history.replaceState(null, '', '/?auth_error=failed');
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ status: 401 }));
  render(<App />);
  expect(screen.getByRole('alert')).toHaveTextContent('Não foi possível entrar com Google');
  await screen.findByRole('link', { name: 'Entrar com Google' });
});
