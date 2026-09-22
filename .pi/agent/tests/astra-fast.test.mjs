// Offline tests only: no model requests, credentials, real session files or TUI needed.
// Run: node --test ~/.pi/agent/tests/astra-fast.test.mjs
import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { homedir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";
import { stripVTControlCharacters as plain } from "node:util";

const packageDir = process.env.PI_PACKAGE_DIR ?? join(homedir(), ".local/lib/node_modules/@earendil-works/pi-coding-agent");
const require = createRequire(join(packageDir, "package.json"));
const { createJiti } = require("jiti");
const jiti = createJiti(import.meta.url, {
  moduleCache: false,
  alias: { "@earendil-works/pi-tui": require.resolve("@earendil-works/pi-tui") },
});
const factory = await jiti.import(fileURLToPath(new URL("../extensions/astra-fast.ts", import.meta.url)), { default: true });
const { visibleWidth } = await jiti.import(require.resolve("@earendil-works/pi-tui"));
const saved = (enabled) => ({ type: "custom", customType: "astra-fast-mode", data: { enabled } });

function harness(entries = []) {
  const handlers = new Map();
  const commands = new Map();
  const state = {
    entries: [...entries], branch: [...entries], model: { id: "gpt-6-astra", provider: "openai-codex", reasoning: true, contextWindow: 272_000 },
    effort: "xhigh", mode: "tui", idle: true, footer: undefined, notifications: [],
    renders: 0, subscriptions: 0, disposed: 0, statuses: new Map(), percent: 20,
  };
  const ctx = {
    get mode() { return state.mode; },
    get hasUI() { return state.mode === "tui" || state.mode === "rpc"; },
    get model() { return state.model; },
    get thinkingLevel() { return state.effort; },
    isIdle: () => state.idle,
    sessionManager: {
      getEntries: () => state.entries,
      getBranch: () => state.branch,
      getCwd: () => "/test/project",
      getSessionName: () => "test session",
    },
    modelRegistry: {
      isUsingOAuth: () => true,
      getProvider: () => ({ auth: { oauth: { isSubscription: true } } }),
    },
    getContextUsage: () => ({ percent: state.percent, contextWindow: 272_000 }),
    ui: {
      notify: (text, type) => state.notifications.push({ text, type }),
      setFooter: (create) => {
        state.footer?.dispose();
        state.footer = create?.(
          { requestRender: () => { state.renders++; } },
          { fg: (color, text) => `\x1b[${color === "success" ? "32" : "90"}m${text}\x1b[39m` },
          {
            getGitBranch: () => "main",
            getAvailableProviderCount: () => 2,
            getExtensionStatuses: () => state.statuses,
            onBranchChange: (fn) => {
              state.subscriptions++;
              state.branchChanged = fn;
              return () => { state.disposed++; };
            },
          },
        );
      },
    },
  };
  factory({
    on: (event, callback) => {
      if (!handlers.has(event)) handlers.set(event, []);
      handlers.get(event).push(callback);
    },
    registerCommand: (name, definition) => commands.set(name, definition),
    appendEntry: (customType, data) => {
      const entry = { type: "custom", customType, data };
      state.entries.push(entry);
      state.branch.push(entry);
    },
  });
  return {
    state, ctx,
    async emit(event, payload = {}) {
      let result;
      for (const callback of handlers.get(event) ?? []) {
        const next = await callback(payload, ctx);
        if (next !== undefined) result = next;
      }
      return result;
    },
    command: (args = "") => commands.get("fast").handler(args, ctx),
    complete: (prefix) => commands.get("fast").getArgumentCompletions(prefix),
    render: (width = 160) => state.footer.render(width).map(plain),
  };
}
const payload = () => ({ model: "gpt-6-astra", reasoning: { effort: "xhigh" }, input: [] });

async function start(entries) {
  const h = harness(entries);
  await h.emit("session_start", { reason: "startup" });
  return h;
}

test("defaults to standard with mode immediately to the right of effort", async () => {
  const h = await start();
  assert.match(h.render()[1], /gpt-6-astra • xhigh • fast off$/);
  const original = Object.freeze(payload());
  const result = await h.emit("before_provider_request", { payload: original });
  assert.equal(result.service_tier, "default");
  assert.equal(result.reasoning, original.reasoning);
  assert.equal(original.service_tier, undefined);
  assert.equal(h.state.entries.length, 0);
});

test("/fast toggles on and off, preserving reasoning and original payload", async () => {
  const h = await start();
  await h.command();
  assert.match(h.render()[1], /xhigh • fast on$/);
  assert.match(h.state.notifications.at(-1).text, /2\.5x/);
  assert.equal((await h.emit("before_provider_request", { payload: payload() })).service_tier, "priority");
  await h.command();
  assert.match(h.render()[1], /xhigh • fast off$/);
  const result = await h.emit("before_provider_request", { payload: { ...payload(), service_tier: "priority" } });
  assert.equal(result.service_tier, "default");
  assert.deepEqual(h.state.entries.map((e) => e.data.enabled), [true, false]);
  assert.ok(h.state.renders >= 2);
});

test("explicit on/off/status and invalid arguments do not accidentally toggle", async () => {
  const h = await start();
  await h.command("on");
  await h.command("ON");
  await h.command("status");
  await h.command("banana");
  assert.equal(h.state.entries.length, 1);
  assert.match(h.state.notifications.at(-1).text, /Usage:/);
  assert.match(h.render()[1], /fast on$/);
  await h.command("off");
  assert.match(h.render()[1], /fast off$/);
  assert.deepEqual(h.complete("o").map((x) => x.value), ["on", "off"]);
});

test("mode survives reload/resume and follows branch navigation; new sessions start off", async () => {
  const first = await start();
  await first.command();
  const resumed = await start(first.state.entries);
  assert.match(resumed.render()[1], /fast on$/);
  resumed.state.branch = [];
  await resumed.emit("session_tree");
  assert.match(resumed.render()[1], /fast off$/);
  resumed.state.branch = [saved(true), saved(false), saved(true)];
  await resumed.emit("session_tree");
  assert.match(resumed.render()[1], /fast on$/);
  assert.match((await start()).render()[1], /fast off$/);
});

test("invalid saved state is ignored", async () => {
  const h = await start([saved(true), saved("false"), { type: "custom", customType: "other", data: { enabled: false } }]);
  assert.match(h.render()[1], /fast on$/);
});

test("other providers/models are untouched and switching back restores the preference", async () => {
  const h = await start();
  await h.command("on");
  h.state.model = { ...h.state.model, provider: "openai" };
  await h.emit("model_select");
  assert.match(h.render()[1], /fast n\/a$/);
  assert.equal(await h.emit("before_provider_request", { payload: payload() }), undefined);
  h.state.model = { ...h.state.model, provider: "openai-codex", id: "gpt-5.5" };
  assert.equal(await h.emit("before_provider_request", { payload: { model: "gpt-5.5" } }), undefined);
  h.state.model.id = "gpt-6-astra";
  await h.emit("model_select");
  assert.match(h.render()[1], /fast on$/);
  assert.equal(await h.emit("before_provider_request", { payload: { model: "different" } }), undefined);
});

test("cannot enable on an unsupported model; can still disable a saved preference", async () => {
  const h = await start();
  h.state.model.id = "other";
  await h.command();
  assert.equal(h.state.entries.length, 0);
  assert.equal(h.state.notifications.at(-1).type, "warning");
  h.state.branch = [saved(true)];
  await h.emit("session_tree");
  await h.command("off");
  assert.equal(h.state.entries.at(-1).data.enabled, false);
});

test("malformed payloads are untouched", async () => {
  const h = await start();
  await h.command();
  for (const value of [null, undefined, [], 1, "payload", {}]) {
    assert.equal(await h.emit("before_provider_request", { payload: value }), undefined);
  }
});

test("footer respects terminal widths and keeps the badge visible when possible", async () => {
  const h = await start();
  await h.command();
  h.state.statuses.set("other", "\x1b[32mother extension 🌸\x1b[0m");
  for (let width = 1; width <= 240; width++) {
    for (const line of h.state.footer.render(width)) assert.ok(visibleWidth(line) <= width, `width ${width}: ${plain(line)}`);
    if (width >= 7) assert.match(h.render(width)[1], /fast on$/);
  }
  assert.deepEqual(h.state.footer.render(0), []);
  assert.match(h.render(200)[2], /other extension 🌸/);
  h.state.effort = "low";
  await h.emit("thinking_level_select");
  assert.match(h.render()[1], /gpt-6-astra • low • fast on$/);
});

test("footer retains all usage types, context, cwd, branch and session name", async () => {
  const usage = { input: 1_000, output: 100, cacheRead: 2_000, cacheWrite: 0, cost: { total: 0.01 } };
  const entries = [
    { type: "message", message: { role: "assistant", usage } },
    { type: "message", message: { role: "toolResult", usage } },
    { type: "compaction", usage },
    { type: "branch_summary", usage },
  ];
  const h = await start(entries);
  const lines = h.render(240);
  assert.match(lines[0], /\/test\/project \(main\) • test session/);
  for (const text of ["↑4.0k", "↓400", "R8.0k", "CH66.7%", "$0.040 (sub)", "20.0%/272k"]) assert.ok(lines[1].includes(text), text);
  h.state.percent = null;
  assert.ok(h.render(240)[1].includes("?%/272k"));
});

test("toggling during a request explains that the next request is affected", async () => {
  const h = await start();
  h.state.idle = false;
  await h.command();
  assert.match(h.state.notifications.at(-1).text, /next request/);
});

test("non-TUI modes skip the custom footer but still support the toggle", async () => {
  const h = harness();
  h.state.mode = "print";
  await h.emit("session_start");
  await h.command();
  assert.equal(h.state.footer, undefined);
  assert.equal(h.state.notifications.length, 0);
  assert.equal((await h.emit("before_provider_request", { payload: payload() })).service_tier, "priority");
});

test("shutdown releases footer resources and restores the default footer", async () => {
  const h = await start();
  assert.equal(h.state.subscriptions, 1);
  h.state.branchChanged();
  assert.equal(h.state.renders, 1);
  await h.emit("session_shutdown");
  assert.equal(h.state.disposed, 1);
  assert.equal(h.state.footer, undefined);
});
