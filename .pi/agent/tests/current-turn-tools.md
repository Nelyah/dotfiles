# Current-turn inline tools

Installed as `~/.pi/agent/extensions/current-turn-tools.ts`. Run `/reload` to activate.

- During a response, only its tool calls/results are visible, using their native inline renderers.
- After the complete response settles (including cancellation/errors), tools disappear entirely, not just collapse. Assistant/user text stays.
- Ctrl+O hides/shows the current response's tools while running. While idle, it hides/shows saved tool history in the current transcript.
- Each delivered user message resets visibility to the new response; retries continue the same response. Intermediate tool batches do not trigger auto-hide.
- Ctrl+Shift+O keeps native output expansion available on terminals that distinguish it. Fullscreen mouse expansion is unchanged.
- `/turn-tools` is an alternative visibility toggle. `/turn-tools off` restores stock display until `/reload`.
- Resume, reload, and branch navigation start with past tools hidden.
- User-entered `!`/`!!` shell commands are not agent tool calls and retain their native display.

No sidebar, settings/keybinding changes, tool overrides, model-context filtering, session edits, installed-package patches, or editor/footer replacements. Applies only in TUI mode, both regular and fullscreen. The Astra footer is preserved.

## Compatibility

Pi has no public API for hiding entire tool rows. This adapter uses guarded runtime access to the stock transcript container, tool call IDs, and focus lookup. It temporarily wraps individual render methods, restores them on teardown, and leaves tool components mounted for native updates and results.

There is no version gate: the adapter attempts initialization on any Pi version and warns only when its runtime checks detect an incompatible API, layout, or renderer (or initialization throws). Detected issues disable hiding and retain/restore native output rather than making tools inaccessible.

Originally validated on **stock pi 0.86.1**. The 23 offline component tests also pass on **0.87.0**; terminal and TypeScript checks below were last run on 0.86.1.

Regular-mode transcript rewrites can clear/repaint terminal scrollback, as with Pi's native expansion changes. Fullscreen uses Pi's managed scroll region. Image protocol rendering was not tested; text/fallback renderers and custom self-shell renderers were tested.

## Offline verification

```sh
node --test ~/.pi/agent/tests/current-turn-tools.test.mjs
python3 ~/.pi/agent/tests/current-turn-tools-terminal.py
```

The terminal suite requires tmux and uses private config/session/work directories with a local synthetic provider. No real credentials or provider calls. It reports the temporary evidence directory.

- 23 automated tests with real exported Pi components, including silent compatible startup, actual incompatibility warnings, and no repeated warning after runtime disable.
- 48 real-terminal checks: both UI modes, streaming/multiple batches, final-answer streaming, hide/show, small-terminal scrollback, new-response isolation, cancellation, reload/resume, dialogs, footer coexistence, unchanged model context/session results, and disable/restore.
- Strict TypeScript checking with erasable syntax against installed stock declarations.
