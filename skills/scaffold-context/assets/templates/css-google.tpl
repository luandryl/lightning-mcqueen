@tailwind base;
@tailwind components;
@tailwind utilities;

:root { font-family: system-ui, -apple-system, sans-serif; font-synthesis: none; }
* { box-sizing: border-box; }
body { margin: 0; }
button, a { -webkit-tap-highlight-color: transparent; }
.auth-shell { --bg: #f6f5f0; --surface: #e9eddf; --ink: #243c32; --muted: #56634f; --line: #c7cdbd; --green: #3d624a; background: var(--bg); color: var(--ink); min-height: 100svh; line-height: 1.6; }
.auth-shell[data-theme="dark"] { color-scheme: dark; --bg: #111813; --surface: #1b261e; --ink: #edf0e5; --muted: #aab6a5; --line: #36463a; --green: #a9c79b; }
.site-header { max-width: 1160px; margin: auto; padding: 29px 40px; border-bottom: 1px solid var(--line); }
.wordmark { font: bold 29px Georgia, serif; letter-spacing: -1.5px; }
.leaf { display: inline-block; width: 23px; height: 23px; background: var(--green); border-radius: 50% 50% 4px 50%; margin-right: 10px; transform: rotate(-15deg); }
.brand-dot { color: var(--green); }
.auth-main { max-width: 860px; margin: 0 auto; padding: 90px 28px; }
.eyebrow { font-size: 10px; letter-spacing: 2px; font-weight: 700; text-transform: uppercase; color: var(--green); }
h1 { font: normal clamp(38px, 7vw, 64px)/1.15 Georgia, serif; letter-spacing: -1.5px; margin: 16px 0 22px; }
p { color: var(--muted); margin: 0; }
.google-button { display: inline-flex; align-items: center; justify-content: center; gap: 12px; padding: 12px 20px; margin-top: 32px; min-height: 44px; border: 1px solid #8e918f; border-radius: 6px; background: #f2f2f2; color: #1f1f1f; text-decoration: none; font-size: 14px; font-weight: 500; }
.google-button:hover { background: #e2e5df; }
.secondary { border: 1px solid var(--line); background: var(--surface); color: var(--ink); border-radius: 6px; padding: 10px 20px; margin-top: 24px; font: inherit; cursor: pointer; min-height: 44px; }
.secondary:disabled { opacity: .6; cursor: wait; }
a:focus-visible, button:focus-visible { outline: 3px solid var(--green); outline-offset: 5px; }
.account-card { background: var(--surface); border: 1px solid var(--line); border-radius: 10px; padding: 28px; max-width: 500px; overflow-wrap: anywhere; }
.account-card h2 { font: 28px/1.3 Georgia, serif; margin: 12px 0; }
.feedback { margin-top: 24px; }
::selection { background: #a9c79b; color: #111813; }
@media (max-width: 600px) { .site-header { padding: 22px 24px; } .auth-main { padding: 60px 24px; } .google-button { width: 100%; } }
