/// <reference types="vitest/config" />
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

import pkg from './package.json';

export default defineConfig({
  plugins: [react()],
  define: {
    __APP_VERSION__: JSON.stringify(pkg.version),
  },
  server: {
    port: {{ frontend_port }},
    strictPort: true,
    proxy: {
      '/v1': process.env.{{ env_prefix }}_DEV_API_URL || 'http://127.0.0.1:{{ backend_port }}',
    },
  },
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    css: false,
  },
});
