// Offline tests with real stock pi components. No model calls or credentials.
// Run: node --test ~/.pi/agent/tests/current-turn-tools.test.mjs
import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { homedir } from "node:os";
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
const { default: factory } = await jiti.import(fileURLToPath(new URL("../extensions/current-turn-tools.ts", import.meta.url)));
const { Container, Text } = await jiti.import(require.resolve("@earendil-works/pi-tui"));
const { ToolExecutionComponent, BashExecutionComponent } = await jiti.import(join(root, "dist/index.js"));
const { initTheme } = await jiti.import(join(root, "dist/modes/interactive/theme/theme.js"));
initTheme("dark", false);

function harness(mode = "tui") {
  const handlers = new Map(), commands = new Map(), shortcuts = new Map();
  const state = { idle: true, renders: 0, warnings: [], focused: null, overlay: false, expanded: false, input: undefined, widget: undefined };
  const chat = new Container(), doc = new Container(), editor = new Container();
  doc.children = [new Container(), new Container(), chat];
  editor.children = [{ render: () => ["draft"], invalidate() {}, getText: () => "draft" }];
  state.focused = editor.children[0];
  const tui = {
    children: [doc, new Container(), new Container(), new Container(), editor, new Container(), new Container()],
    requestRender: () => { state.renders++; },
    getFocusedComponent: () => state.focused,
    hasOverlay: () => state.overlay,
  };
  const ctx = { mode, hasUI: mode === "tui" || mode === "rpc", isIdle: () => state.idle, ui: {
    notify: message => state.warnings.push(message),
    setWidget: (_key, build) => { state.widget?.dispose(); state.widget = build?.(tui); },
    onTerminalInput: handler => { state.input = handler; return () => { state.input = undefined; }; },
    getToolsExpanded: () => state.expanded,
    setToolsExpanded: value => { state.expanded = value; },
  } };
  factory({
    on(name, fn) { const list = handlers.get(name) ?? []; list.push(fn); handlers.set(name, list); },
    registerCommand: (name, definition) => commands.set(name, definition),
    registerShortcut: (key, definition) => shortcuts.set(key, definition),
  });
  const emit = async (name, event = {}) => {
    for (const fn of handlers.get(name) ?? []) assert.equal(await fn(event, ctx), undefined, `${name} must not replace messages/results`);
  };
  const render = () => chat.render(100).map(line => plain(line).trimEnd()).join("\n");
  const tool = (id, options = {}) => {
    const definition = options.self ? {
      renderShell: "self", renderCall: () => new Text(`SELF_CALL_${id}`, 0, 0),
      renderResult: () => new Text(`SELF_RESULT_${id}`, 0, 0),
    } : undefined;
    const t = new ToolExecutionComponent("fixture_tool", id, { id }, { showImages: false }, definition, tui, "/tmp");
    t.updateResult({ content: [{ type: "text", text: `RESULT_${id}` }], isError: !!options.error });
    chat.addChild(t);
    return t;
  };
  const call = async id => {
    await emit("tool_execution_start", { toolCallId: id });
    return tool(id);
  };
  const start = async () => { state.idle = false; await emit("agent_start"); await emit("message_start", { message: { role: "user", content: "prompt" } }); };
  const end = async () => { state.idle = true; await emit("agent_settled"); };
  return { state, chat, doc, editor, tui, ctx, emit, tool, call, render, start, end,
    toggle: () => state.input?.("\x0f"),
    command: args => commands.get("turn-tools").handler(args, ctx),
    expand: () => shortcuts.get("ctrl+shift+o").handler(ctx),
  };
}
async function setup(mode) { const h = harness(mode); await h.emit("session_start"); return h; }

test("compatible runtime initializes silently without a version gate", async () => {
  const h = await setup();
  assert.ok(h.state.widget); assert.equal(typeof h.state.input, "function");
  await h.start(); await h.call("current"); assert.match(h.render(), /RESULT_current/);
  await h.end(); assert.equal(h.render(), "");
  assert.deepEqual(h.state.warnings, []);
});
test("incompatible startup layout warns and retains stock display", async () => {
  const h = harness(); const t = h.tool("old"); h.tui.children.pop();
  await h.emit("session_start");
  assert.equal(h.state.warnings.length, 1);
  assert.match(h.state.warnings[0], /expected stock transcript\/input containers.*stock tool display retained/);
  assert.equal(h.state.input, undefined); assert.equal(h.state.widget, undefined);
  assert.equal(h.chat.render, Container.prototype.render); assert.equal(Object.hasOwn(t, "render"), false);
  assert.match(h.render(), /RESULT_old/);
});
test("missing focus API warns and retains stock display", async () => {
  const h = harness(); h.tool("old"); delete h.tui.getFocusedComponent;
  await h.emit("session_start");
  assert.equal(h.state.warnings.length, 1);
  assert.match(h.state.warnings[0], /missing TUI focus API.*stock tool display retained/);
  assert.equal(h.state.input, undefined); assert.equal(h.state.widget, undefined);
  assert.match(h.render(), /RESULT_old/);
});
test("restored tools disappear completely, with no headers, output, or spacers", async () => {
  const h = harness(); h.tool("old"); h.chat.addChild(new Text("ANSWER", 0, 0));
  await h.emit("session_start");
  assert.equal(h.render(), "ANSWER");
  h.toggle(); assert.match(h.render(), /RESULT_old/);
  h.toggle(); assert.equal(h.render(), "ANSWER");
});
test("current response automatically shows tools, but not older ones", async () => {
  const h = await setup(); h.tool("old"); await h.start(); await h.call("current");
  assert.match(h.render(), /RESULT_current/); assert.doesNotMatch(h.render(), /RESULT_old/);
  await h.end(); assert.equal(h.render(), "");
});
test("Ctrl+O hides running tools, including later parallel calls and updates", async () => {
  const h = await setup(); await h.start(); const t = await h.call("a");
  assert.match(h.render(), /RESULT_a/); assert.deepEqual(h.toggle(), { consume: true });
  await h.call("b"); t.updateResult({ content: [{ type: "text", text: "UPDATED" }], isError: false }, true);
  assert.equal(h.render(), ""); h.toggle();
  assert.match(h.render(), /UPDATED/); assert.match(h.render(), /RESULT_b/);
});
test("settlement hides tools even when manually revealed, keeping assistant text", async () => {
  const h = await setup(); await h.start(); await h.call("a"); h.chat.addChild(new Text("FINAL", 0, 0));
  h.toggle(); h.toggle(); await h.end(); assert.equal(h.render(), "FINAL");
  h.toggle(); assert.match(h.render(), /RESULT_a/); h.toggle(); assert.equal(h.render(), "FINAL");
});
test("idle history toggle is reset at the next response", async () => {
  const h = await setup(); h.tool("old"); h.toggle(); assert.match(h.render(), /RESULT_old/);
  await h.start(); await h.call("next"); assert.match(h.render(), /RESULT_next/); assert.doesNotMatch(h.render(), /RESULT_old/);
});
test("intermediate turn_end/agent_end and retries do not hide or reset the active response", async () => {
  const h = await setup(); await h.start(); await h.call("first");
  await h.emit("turn_end"); await h.emit("agent_end"); await h.emit("agent_start");
  assert.match(h.render(), /RESULT_first/);
  h.toggle(); await h.emit("agent_start"); await h.call("retry"); assert.equal(h.render(), "");
  await h.emit("agent_settled"); // Another extension started a run: isIdle is false.
  h.toggle(); assert.match(h.render(), /RESULT_retry/); assert.match(h.render(), /RESULT_first/);
});
test("delivered steering/follow-up starts a new visible scope", async () => {
  const h = await setup(); await h.start(); await h.call("first"); h.toggle();
  await h.emit("message_start", { message: { role: "user", content: "follow-up" } }); await h.call("second");
  assert.match(h.render(), /RESULT_second/); assert.doesNotMatch(h.render(), /RESULT_first/);
});
test("tool argument streaming appears before execution_start", async () => {
  const h = await setup(); await h.start();
  const message = Object.freeze({ role: "assistant", content: Object.freeze([{ type: "toolCall", id: "partial" }]) });
  await h.emit("message_update", { message }); h.tool("partial"); assert.match(h.render(), /RESULT_partial/);
  await h.emit("message_end", { message }); assert.equal(message.content.length, 1);
});
test("custom self-shell/error tools hide and reveal without losing native rendering", async () => {
  const h = await setup(); await h.start();
  await h.emit("tool_execution_start", { toolCallId: "custom" }); h.tool("custom", { self: true, error: true });
  assert.match(h.render(), /SELF_RESULT_custom/); await h.end(); assert.equal(h.render(), "");
  h.toggle(); assert.match(h.render(), /SELF_CALL_custom/); assert.match(h.render(), /SELF_RESULT_custom/);
});
test("compaction/rebuilt components retain visibility by call ID", async () => {
  const h = await setup(); await h.start(); const old = await h.call("live"); h.render();
  h.chat.clear(); h.tool("historical"); h.tool("live");
  assert.match(h.render(), /RESULT_live/); assert.doesNotMatch(h.render(), /RESULT_historical/);
  assert.equal(Object.hasOwn(old, "render"), false);
});
test("branch navigation resets history visibility", async () => {
  const h = await setup(); h.tool("old"); h.toggle(); await h.emit("session_tree"); assert.equal(h.render(), "");
});
test("native user shell commands are not mistaken for agent tool calls", async () => {
  const h = await setup();
  // Instance identity test without starting any process or loader.
  const shell = Object.create(BashExecutionComponent.prototype);
  shell.render = () => ["USER_SHELL"]; shell.invalidate = () => {};
  h.chat.addChild(shell); h.tool("hidden"); assert.equal(h.render(), "USER_SHELL");
});
test("Ctrl+O is untouched inside selectors or overlays; drafts/focus are preserved", async () => {
  const h = await setup(); const editor = h.state.focused; h.tool("old");
  h.state.focused = new Text("selector"); assert.equal(h.toggle(), undefined);
  h.state.focused = editor; h.state.overlay = true; assert.equal(h.toggle(), undefined);
  h.state.overlay = false; h.toggle(); assert.equal(h.state.focused, editor); assert.equal(editor.getText(), "draft");
  assert.match(h.render(), /RESULT_old/);
});
test("expansion shortcut remains separate from show/hide", async () => {
  const h = await setup(); await h.expand(); assert.equal(h.state.expanded, true);
  h.toggle(); assert.equal(h.state.expanded, true); await h.expand(); assert.equal(h.state.expanded, false);
});
test("shutdown, repeated reload, and explicit disable restore original renderers", async () => {
  const h = await setup(); const t = h.tool("a"); h.render();
  for (let i = 0; i < 3; i++) {
    await h.emit("session_shutdown"); assert.equal(h.chat.render, Container.prototype.render); assert.equal(Object.hasOwn(t, "render"), false);
    await h.emit("session_start", { reason: "reload" }); assert.equal(h.render(), "");
  }
  await h.command("off"); assert.equal(h.state.input, undefined); assert.match(h.render(), /RESULT_a/);
});
test("incompatible mounted layout fails open without losing tools", async () => {
  const h = await setup(); h.tool("old"); h.render(); h.tui.children[0] = new Container();
  assert.match(h.render(), /RESULT_old/); await Promise.resolve(); assert.match(h.state.warnings[0], /disabled.*restored/);
  h.render(); h.toggle(); await h.start(); await h.end();
  assert.equal(h.state.warnings.length, 1); assert.match(h.render(), /RESULT_old/);
});
test("later renderer replacement is preserved on fail-open cleanup", async () => {
  const h = await setup(); const t = h.tool("old"); h.render();
  const replacement = () => ["OTHER_EXTENSION"]; t.render = replacement;
  assert.equal(h.render(), "OTHER_EXTENSION"); assert.equal(t.render, replacement);
});
for (const mode of ["rpc", "json", "print"]) test(`no UI attachment in ${mode} mode`, async () => {
  const h = await setup(mode); assert.equal(h.state.widget, undefined); assert.equal(h.state.input, undefined);
  await h.emit("agent_start"); await h.emit("agent_settled"); assert.equal(h.state.renders, 0);
});
