// Offline tests with real files, Git, and Pi's TUI renderer. No model calls.
// Run: node --test ~/.pi/agent/tests/turn-diff.test.mjs
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { chmod, mkdir, mkdtemp, readFile, realpath, rename, rm, symlink, writeFile } from "node:fs/promises";
import { createRequire } from "node:module";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";
import { stripVTControlCharacters as plain } from "node:util";

const root = join(homedir(), ".local/lib/node_modules/@earendil-works/pi-coding-agent");
const require = createRequire(join(root, "package.json"));
const { createJiti } = require("jiti");
const jiti = createJiti(import.meta.url, { alias: {
  "@earendil-works/pi-coding-agent": join(root, "dist/index.js"),
  "@earendil-works/pi-tui": require.resolve("@earendil-works/pi-tui"),
} });
const { default: factory, TurnDiff } = await jiti.import(fileURLToPath(new URL("../extensions/turn-diff.ts", import.meta.url)));
const { visibleWidth } = await jiti.import(require.resolve("@earendil-works/pi-tui"));
const { getThemeByName } = await jiti.import(join(root, "dist/modes/interactive/theme/theme.js"));
const git = (cwd, ...args) => execFileSync("git", ["-C", cwd, ...args], { encoding: "utf8" });

async function workspace(t, repo = false) {
  const cwd = await realpath(await mkdtemp(join(tmpdir(), "pi-turn-diff-test-")));
  t.after(() => rm(cwd, { recursive: true, force: true }));
  if (repo) git(cwd, "init", "-q");
  const put = async (name, data) => {
    const path = join(cwd, name);
    await mkdir(join(path, ".."), { recursive: true });
    await writeFile(path, data);
  };
  const start = async () => { const tracker = new TurnDiff(cwd); await tracker.start(); return tracker; };
  return { cwd, put, start };
}

function harness(cwd, mode = "tui") {
  const handlers = new Map(), entries = [], renderers = new Map(), warnings = [];
  let idle = true;
  const ctx = { cwd, mode, isIdle: () => idle, sessionManager: { getSessionFile: () => undefined },
    ui: { notify: text => warnings.push(text) } };
  factory({
    on(name, fn) { const list = handlers.get(name) ?? []; list.push(fn); handlers.set(name, list); },
    appendEntry: (customType, data) => entries.push({ type: "custom", customType, data }),
    registerEntryRenderer: (name, render) => renderers.set(name, render),
  });
  const emit = async (name, event = {}) => {
    for (const fn of handlers.get(name) ?? []) assert.equal(await fn(event, ctx), undefined);
  };
  return {
    entries, warnings, emit,
    start: async () => { idle = false; await emit("agent_start"); },
    settle: async () => { idle = true; await emit("agent_settled"); },
    track: path => emit("tool_call", { toolName: "write", input: { path } }),
    render: (entry, theme = "dark") => renderers.get("turn-diff")(entry, { outputPad: 1 }, getThemeByName(theme)),
  };
}

for (const repo of [false, true]) test(`unchanged dirty/untracked workspace is silent (git=${repo})`, async t => {
  const w = await workspace(t, repo);
  await w.put("old.txt", "existing dirty content\n");
  const h = harness(w.cwd); await h.start(); await h.settle();
  assert.deepEqual(h.entries, []); assert.deepEqual(h.warnings, []);
});

test("modified files show net line changes, not summed tool diffs", async t => {
  const w = await workspace(t); await w.put("a.txt", "one\ntwo\nthree\n");
  const h = harness(w.cwd); await h.start(); await h.track("a.txt");
  await w.put("a.txt", "ONE\ntwo\nthree\n");
  await h.emit("turn_end"); await h.emit("agent_end");
  assert.equal(h.entries.length, 0);
  await h.track("a.txt"); await w.put("a.txt", "one\nTWO\nthree\nfour\n");
  await h.settle();
  assert.deepEqual(h.entries[0].data.files, [{ path: "a.txt", status: "M", added: 2, removed: 1 }]);
  await h.settle(); assert.equal(h.entries.length, 1);
});

test("changes fully reverted within a turn produce no summary", async t => {
  const w = await workspace(t); await w.put("a.txt", "original\n");
  const h = harness(w.cwd); await h.start(); await h.track("a.txt");
  await w.put("a.txt", "changed\n"); await w.put("a.txt", "original\n");
  await w.put("temporary.txt", "new\n"); await rm(join(w.cwd, "temporary.txt"));
  await h.settle(); assert.deepEqual(h.entries, []);
});

test("pre-existing staged and unstaged changes are excluded without modifying the index", async t => {
  const w = await workspace(t, true);
  await w.put("a.txt", "original\n"); git(w.cwd, "add", "a.txt");
  await w.put("a.txt", "pre-existing\n");
  const index = await readFile(join(w.cwd, ".git/index"));
  const tracker = await w.start(); await w.put("a.txt", "pre-existing\nnew\n");
  assert.deepEqual((await tracker.finish()).files, [{ path: "a.txt", status: "M", added: 1, removed: 0 }]);
  assert.deepEqual(await readFile(join(w.cwd, ".git/index")), index);
});

test("same-size replacements are detected even when Git numstat totals would be identical", async t => {
  const w = await workspace(t, true); await w.put("a.txt", "old\n"); git(w.cwd, "add", ".");
  await w.put("a.txt", "one\n"); const tracker = await w.start(); await w.put("a.txt", "two\n");
  assert.deepEqual((await tracker.finish()).files, [{ path: "a.txt", status: "M", added: 1, removed: 1 }]);
});

for (const repo of [false, true]) test(`shell additions, deletions and renames are captured (git=${repo})`, async t => {
  const w = await workspace(t, repo); await w.put("old.txt", "old\n");
  const h = harness(w.cwd); await h.start();
  await rename(join(w.cwd, "old.txt"), join(w.cwd, "renamed.txt"));
  await w.put("added.txt", "first\nsecond"); // Missing final newline still counts.
  await h.settle();
  assert.deepEqual(h.entries[0].data.files, [
    { path: "added.txt", status: "A", added: 2, removed: 0 },
    { path: "old.txt", status: "D", added: 0, removed: 1 },
    { path: "renamed.txt", status: "A", added: 1, removed: 0 },
  ]);
});

test("shell-created files subsequently edited keep their missing-at-start baseline", async t => {
  const w = await workspace(t, true); const h = harness(w.cwd); await h.start();
  await w.put("new.txt", "created\n"); await h.track("new.txt"); await w.put("new.txt", "edited\nmore\n");
  await h.settle();
  assert.deepEqual(h.entries[0].data.files, [{ path: "new.txt", status: "A", added: 2, removed: 0 }]);
});

test("ignored files stay out of shell scans but explicit writes are included", async t => {
  const w = await workspace(t, true); await w.put(".gitignore", "ignored/\n");
  await w.put("ignored/a.txt", "before\n"); const h = harness(w.cwd); await h.start();
  await h.track("ignored/a.txt"); await w.put("ignored/a.txt", "after\n");
  await w.put("ignored/noise.txt", "noise\n"); await h.settle();
  assert.deepEqual(h.entries[0].data.files, [{ path: "ignored/a.txt", status: "M", added: 1, removed: 1 }]);
});

test("newly ignored existing files are not mistaken for deletions", async t => {
  const w = await workspace(t, true); await w.put("untracked.txt", "keep\n");
  const tracker = await w.start(); await w.put(".gitignore", "untracked.txt\n");
  assert.deepEqual((await tracker.finish()).files, [{ path: ".gitignore", status: "A", added: 1, removed: 0 }]);
});

test("unignoring pre-existing files does not invent additions", async t => {
  const w = await workspace(t, true); await w.put(".gitignore", "ignored/\nignored.txt\n");
  await w.put("ignored/existing.txt", "existing\n"); await w.put("ignored.txt", "existing\n");
  const tracker = await w.start(); await w.put(".gitignore", "");
  assert.deepEqual((await tracker.finish()).files, [{ path: ".gitignore", status: "M", added: 0, removed: 2 }]);
});

test("explicit edits in submodules use the file's actual prior contents", async t => {
  const w = await workspace(t, true); await w.put("module/a.txt", "before\n");
  // A gitlink entry without network access or a real submodule checkout.
  const tree = git(w.cwd, "mktree").trim();
  const commit = execFileSync("git", ["-C", w.cwd, "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
    "commit-tree", tree, "-m", "fixture"], { encoding: "utf8" }).trim();
  git(w.cwd, "update-index", "--add", "--cacheinfo", `160000,${commit},module`);
  const h = harness(w.cwd); await h.start(); await h.track("module/a.txt"); await w.put("module/a.txt", "after\n");
  await h.settle();
  assert.deepEqual(h.entries[0].data.files, [{ path: "module/a.txt", status: "M", added: 1, removed: 1 }]);
});

test("explicit paths outside cwd and symlink aliases are snapshotted before mutation", async t => {
  const w = await workspace(t); const external = await workspace(t);
  await external.put("a.txt", "before\n"); await symlink(external.cwd, join(w.cwd, "link"));
  const h = harness(w.cwd); await h.start(); await h.track("@link/a.txt");
  await external.put("a.txt", "after\n"); await h.track(join(external.cwd, "a.txt")); await h.settle();
  assert.equal(h.entries[0].data.files.length, 1);
  assert.match(h.entries[0].data.files[0].path, /^\.\.\//);
  assert.equal(h.entries[0].data.files[0].added, 1);
});

test("new files under a symlinked external parent are additions", async t => {
  const w = await workspace(t); const external = await workspace(t);
  await symlink(external.cwd, join(w.cwd, "link")); const h = harness(w.cwd); await h.start();
  await h.track("link/deep/new.txt"); await external.put("deep/new.txt", "new\n"); await h.settle();
  assert.equal(h.entries[0].data.files[0].status, "A");
});

test("retries and tool batches accumulate until the full agent settles", async t => {
  const w = await workspace(t); const h = harness(w.cwd); await h.start();
  await w.put("a.txt", "first\n"); await h.emit("agent_end"); await h.emit("agent_start");
  await h.emit("agent_settled"); // Not idle: ignore a premature notification.
  await w.put("a.txt", "first\nsecond\n"); assert.deepEqual(h.entries, []);
  await h.settle(); assert.equal(h.entries[0].data.files[0].added, 2);
  await h.start(); await h.settle(); assert.equal(h.entries.length, 1); // Fresh next-turn baseline.
});

test("aborted/failed tools still report actual filesystem changes", async t => {
  const w = await workspace(t); const h = harness(w.cwd); await h.start();
  await h.track("a.txt"); await w.put("a.txt", "partial write\n");
  await h.emit("tool_result", { isError: true }); await h.emit("agent_end", { messages: [{ stopReason: "aborted" }] });
  await h.settle(); assert.equal(h.entries[0].data.files[0].added, 1);
});

test("failed or blocked writes without changes remain silent", async t => {
  const w = await workspace(t); const h = harness(w.cwd); await h.start(); await h.track("missing.txt");
  await h.settle(); assert.deepEqual(h.entries, []);
});

for (const event of ["session_start", "session_shutdown", "session_tree"]) test(`${event} clears transient tracking`, async t => {
  const w = await workspace(t); const h = harness(w.cwd); await h.start(); await w.put("a.txt", "new\n");
  await h.emit(event); await h.settle(); assert.deepEqual(h.entries, []);
});

test("binary and mode-only changes count as changed files without fabricated line counts", async t => {
  const w = await workspace(t); await w.put("binary", Buffer.from([0, 1, 2])); await w.put("script", "exit\n");
  const tracker = await w.start(); await w.put("binary", Buffer.from([0, 3, 4])); await chmod(join(w.cwd, "script"), 0o755);
  assert.deepEqual((await tracker.finish()).files, [
    { path: "binary", status: "M", note: "binary" },
    { path: "script", status: "M", added: 0, removed: 0, note: "mode" },
  ]);
});

test("large-file changes remain visible without retaining their contents", async t => {
  const w = await workspace(t); await w.put("large", "a".repeat(2 * 1024 * 1024 + 1));
  const tracker = await w.start(); await w.put("large", "b".repeat(2 * 1024 * 1024 + 1));
  assert.deepEqual((await tracker.finish()).files, [{ path: "large", status: "M", note: "large file; line counts unavailable" }]);
});

test("Pi runtime files and dependency directories do not create noise", async t => {
  const w = await workspace(t); await w.put("agent/sessions/log", "old\n");
  const tracker = new TurnDiff(w.cwd, join(w.cwd, "agent")); await tracker.start();
  await w.put("agent/sessions/log", "new\n"); await w.put("node_modules/noise", "new\n");
  assert.deepEqual((await tracker.finish()).files, []);
});

test("a custom session file inside the workspace is not counted as a change", async t => {
  const w = await workspace(t); await w.put("session.jsonl", "before\n");
  const tracker = new TurnDiff(w.cwd, join(w.cwd, "agent"), join(w.cwd, "session.jsonl")); await tracker.start();
  await w.put("session.jsonl", "after\n"); assert.deepEqual((await tracker.finish()).files, []);
});

test("filenames with whitespace and terminal escapes are safely rendered at narrow widths", async t => {
  const w = await workspace(t); const h = harness(w.cwd); await h.start();
  await w.put("space\tline\n\x1b[31m.txt", "new\n"); await h.settle();
  assert.equal(h.entries.length, 1);
  const entry = JSON.parse(JSON.stringify(h.entries[0])); // Same shape after session restoration.
  for (const theme of ["dark", "light"]) {
    const component = h.render(entry, theme);
    for (const width of [12, 30, 80]) {
      component.invalidate();
      const lines = component.render(width);
      assert.ok(lines.every(line => visibleWidth(line) <= width));
      if (width === 80) {
        assert.match(lines.map(plain).join("\n"), /Turn diff · 1 file · \+1 -0/);
        assert.match(lines.map(plain).join("\n"), /space\\tline\\n\\u001b/);
      }
    }
  }
});

for (const mode of ["rpc", "json", "print"]) test(`no filesystem scans or output in ${mode} mode`, async () => {
  const h = harness("/does/not/exist", mode); await h.start(); await h.track("a.txt"); await h.settle();
  assert.deepEqual(h.entries, []); assert.deepEqual(h.warnings, []);
});
