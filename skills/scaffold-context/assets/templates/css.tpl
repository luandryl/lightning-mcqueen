@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply antialiased;
  }

  ::selection {
    @apply bg-primary-200 dark:bg-primary-800;
  }

  :focus-visible {
    @apply outline-2 outline-offset-2 outline-primary-500;
  }

  dialog::backdrop {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
  }

  ::-webkit-scrollbar {
    width: 6px;
    height: 6px;
  }
  ::-webkit-scrollbar-track {
    @apply bg-transparent;
  }
  ::-webkit-scrollbar-thumb {
    @apply bg-zinc-300 dark:bg-zinc-600 rounded-full;
  }
}

@layer components {
  /* Componentes visuais reutilizáveis do projeto. */
  .btn-primary {
    @apply inline-flex items-center justify-center gap-2 h-10 px-4 rounded-xl;
    @apply bg-primary-600 hover:bg-primary-700 text-white text-sm font-medium;
    @apply disabled:opacity-60 disabled:cursor-not-allowed transition-colors;
  }
  .btn-secondary {
    @apply inline-flex items-center justify-center gap-2 h-10 px-4 rounded-xl;
    @apply border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900;
    @apply text-zinc-700 dark:text-zinc-300 text-sm font-medium;
    @apply hover:bg-zinc-50 dark:hover:bg-zinc-800 disabled:opacity-60 transition-colors;
  }
  .btn-sm {
    @apply h-8 px-3 text-xs rounded-lg;
  }
  .input-bmp {
    @apply h-10 px-3 rounded-xl border border-zinc-200 dark:border-zinc-700;
    @apply bg-zinc-50 dark:bg-zinc-800 text-sm text-zinc-900 dark:text-zinc-100 placeholder-zinc-400;
    @apply focus:outline-none focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 transition-all;
  }
  .card-bmp {
    @apply bg-white dark:bg-zinc-900 rounded-2xl border border-zinc-200 dark:border-zinc-800;
  }
  .th-bmp {
    @apply text-left px-4 py-3 text-xs font-medium text-zinc-500 dark:text-zinc-400 uppercase tracking-wider whitespace-nowrap select-none;
  }
}
