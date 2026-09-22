# Per-turn diff summary

Implementation: `~/.pi/agent/extensions/turn-diff.ts` (auto-discovered globally).
Run `/reload` in existing Pi sessions, or restart Pi, to enable it.

At the end of a complete response, a small transcript entry shows:

```text
Turn diff · 2 files · +8 -3
M src/example.ts  +5 -3
A tests/example.test.ts  +3 -0
```

- Compares actual files before/after the response, not against Git HEAD.
- Multiple tool calls and retries accumulate into one **net** diff. Reverted
  changes and no-op turns produce no entry. Aborted turns still show changes
  left on disk. Queued continuations remain part of the response until Pi settles.
- Displays after the final response using `agent_settled`, not after each model
  tool-call batch. Works with `current-turn-tools.ts`; hiding tools does not hide
  the summary.
- Persists only paths, statuses and counts as a custom entry, never file contents
  or an LLM message. Summaries survive reload/resume and add no model tokens.
- TUI only (regular and fullscreen). Print/JSON/RPC behavior is unchanged.

## Scope and limits

- Git workspaces: scans the repository's tracked and non-ignored untracked files.
  The real index, refs, and working tree are never modified by the extension.
- Non-Git workspaces: scans the current directory, excluding VCS metadata,
  `node_modules`, `.venv`, `venv`, `__pycache__`, and `.cache`.
- Pi runtime directories (`sessions`, `npm`, `git`, `backups`) and the active
  session file are excluded from automatic scans.
- Explicit `edit`/`write` calls also capture ignored, external, and submodule
  files, starting immediately before the first such call. Arbitrary shell edits
  outside the scanned workspace or inside excluded directories aren't tracked.
- Filesystem snapshots cannot distinguish agent changes from simultaneous local
  edits by another process. Remote tool backends aren't tracked.
- Renames appear as deletion plus addition. Binary, symlink, mode-only, and
  empty-file changes still count as changed files; line counts are shown when
  available. Text files over 2 MiB, or beyond a 64 MiB snapshot budget, are hashed
  and listed without line counts. Git is required for modified-text line counts.
- Scans are limited to 20,000 files. Scan failures fall back to explicit file
  tracking; nonempty incomplete summaries are marked partial.

## Offline verification

```sh
node --test ~/.pi/agent/tests/turn-diff.test.mjs
python3 ~/.pi/agent/tests/turn-diff-terminal.py  # requires tmux
```

The terminal test uses the bundled Pi CLI and an offline fixture provider in
isolated config/work directories. It verifies final-response placement, exact
counts, zero suppression, display-only persistence, reload, and compatibility
with tool hiding in both TUI modes. It makes no API calls and does not use real
credentials. `turn-diff-fixture.ts` is test-only, not an installed extension.
