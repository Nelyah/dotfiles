/**
 * Inline tools for the current response only; Ctrl+O hides/reveals them.
 * Idle Ctrl+O reveals history. No tools, messages, or model context are changed.
 *
 * Pi has no public tool-row visibility API. This reversible, instance-local
 * rendering adapter checks runtime compatibility, not the Pi version, and warns
 * only on detected incompatibilities, restoring stock display.
 * It leaves the layout, editor, footer, tool execution, and native renderers alone.
 */
import { ToolExecutionComponent, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Container, isKeyRelease, isKeyRepeat, matchesKey, type Component, type TUI } from "@earendil-works/pi-tui";

const WIDGET = "current-turn-tools";
type RuntimeTui = TUI & { getFocusedComponent(): Component | null };
type SavedRender = { descriptor?: PropertyDescriptor; original: Component["render"]; wrapper: Component["render"] };

function requireShape(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function restore(component: Component, saved: SavedRender) {
  // Do not overwrite a renderer installed later by another extension.
  if (component.render !== saved.wrapper) return;
  if (saved.descriptor) Object.defineProperty(component, "render", saved.descriptor);
  else Reflect.deleteProperty(component, "render");
}

export class CurrentTurnTools {
  running = false;
  currentVisible = true;
  historyVisible = false;
  readonly currentIds = new Set<string>();
  private enabled = true;
  private readonly saved = new Map<Component, SavedRender>();
  private readonly document: Container;
  private readonly chat: Container;
  private readonly editor: Container;
  private readonly chatRender: SavedRender;
  private readonly tui: RuntimeTui;
  private readonly warn: (reason: string) => void;

  constructor(tui: TUI, warn: (reason: string) => void) {
    requireShape(typeof Reflect.get(tui, "getFocusedComponent") === "function", "missing TUI focus API");
    this.tui = tui as RuntimeTui;
    this.warn = warn;
    // Stock pi mounts the same seven containers in regular and fullscreen modes.
    requireShape(tui.children.length === 7, "expected stock transcript/input containers");
    const document = tui.children[0];
    const editor = tui.children[4];
    requireShape(document instanceof Container && document.children.length === 3, "expected header/resources/chat document");
    const chat = document.children[2];
    requireShape(chat instanceof Container && chat.constructor === Container, "expected plain chat container");
    requireShape(chat.render === Container.prototype.render, "chat renderer already customized");
    requireShape(editor instanceof Container, "expected editor container");
    this.document = document;
    this.chat = chat;
    this.editor = editor;
    const original = chat.render;
    const wrapper = (width: number) => {
      this.check(); // Install visibility guards before the very first tool frame.
      return original.call(chat, width);
    };
    this.chatRender = { descriptor: Object.getOwnPropertyDescriptor(chat, "render"), original, wrapper };
    Object.defineProperty(chat, "render", { configurable: true, writable: true, value: wrapper });
    this.check();
    tui.requestRender();
  }

  private sync() {
    const live = new Set(this.chat.children);
    for (const [tool, saved] of this.saved) {
      if (!live.has(tool)) { restore(tool, saved); this.saved.delete(tool); }
    }
    for (const tool of this.chat.children) {
      if (!(tool instanceof ToolExecutionComponent)) {
        requireShape(!/ToolExecution/.test(tool.constructor.name), "unrecognized tool component identity");
        continue;
      }
      const existing = this.saved.get(tool);
      if (existing) {
        requireShape(tool.render === existing.wrapper, "tool renderer changed by another extension");
        continue;
      }
      const id: unknown = Reflect.get(tool, "toolCallId");
      requireShape(typeof id === "string", "tool call ID API changed");
      const original = tool.render;
      const wrapper = (width: number) => {
        const visible = this.running
          ? this.currentVisible && this.currentIds.has(id)
          : this.historyVisible;
        return !this.enabled || visible ? original.call(tool, width) : [];
      };
      const saved = { descriptor: Object.getOwnPropertyDescriptor(tool, "render"), original, wrapper };
      Object.defineProperty(tool, "render", { configurable: true, writable: true, value: wrapper });
      this.saved.set(tool, saved);
    }
  }

  check(): boolean {
    if (!this.enabled) return false;
    try {
      requireShape(this.tui.children[0] === this.document && this.document.children[2] === this.chat &&
        this.tui.children[4] === this.editor, "mounted transcript structure changed");
      requireShape(this.chat.render === this.chatRender.wrapper, "chat renderer changed");
      this.sync();
      return true;
    } catch (error) {
      this.dispose();
      this.warn(`${String(error)}; disabled, stock tool display restored`);
      return false;
    }
  }

  startResponse() {
    this.running = true;
    this.currentVisible = true;
    this.historyVisible = false;
    this.currentIds.clear();
    this.refresh();
  }

  addCall(id: string) {
    this.currentIds.add(id);
  }

  settle() {
    this.running = false;
    this.historyVisible = false;
    this.currentIds.clear();
    this.refresh();
  }

  toggle() {
    if (!this.check()) return;
    if (this.running) this.currentVisible = !this.currentVisible;
    else this.historyVisible = !this.historyVisible;
    this.tui.requestRender();
  }

  input(data: string): { consume: true } | undefined {
    if (!matchesKey(data, "ctrl+o") || !this.check() || this.tui.hasOverlay()) return;
    const focused = this.tui.getFocusedComponent();
    // Leave Ctrl+O in /tree, selectors, overlays and other dialogs untouched.
    // Resolve focus each time: /reload temporarily mounts a loader here.
    if (focused !== this.editor.children[0] || typeof Reflect.get(focused ?? {}, "getText") !== "function") return;
    if (!isKeyRelease(data) && !isKeyRepeat(data)) this.toggle();
    return { consume: true };
  }

  refresh() {
    if (this.check()) this.tui.requestRender();
  }

  dispose() {
    if (!this.enabled) return;
    this.enabled = false;
    for (const [tool, saved] of this.saved) restore(tool, saved);
    this.saved.clear();
    restore(this.chat, this.chatRender);
    this.tui.requestRender();
  }
}

export default function currentTurnTools(pi: ExtensionAPI) {
  let adapter: CurrentTurnTools | undefined;
  let stopInput: (() => void) | undefined;
  const cleanup = () => {
    stopInput?.(); stopInput = undefined;
    adapter?.dispose(); adapter = undefined;
  };
  pi.on("session_start", (_event, ctx) => {
    cleanup();
    if (ctx.mode !== "tui") return;
    const warn = (message: string) => queueMicrotask(() => ctx.ui.notify(`[current-turn-tools] ${message}`, "warning"));
    try {
      ctx.ui.setWidget(WIDGET, tui => {
        adapter = new CurrentTurnTools(tui, warn);
        return { render: () => [], invalidate() {}, dispose: cleanup };
      });
      stopInput = ctx.ui.onTerminalInput(data => adapter?.input(data));
    } catch (error) {
      cleanup();
      warn(`${String(error)}; stock tool display retained`);
    }
  });
  pi.on("agent_start", () => {
    // A retry is still part of the same response; do not reset manually hidden tools.
    if (adapter && !adapter.running) adapter.startResponse();
  });
  pi.on("message_start", (event) => {
    // Actual delivered user messages also delimit steering and queued follow-ups.
    if (event.message.role === "user") adapter?.startResponse();
  });
  const track = (message: { role: string; content?: unknown }) => {
    if (message.role !== "assistant" || !Array.isArray(message.content)) return;
    for (const block of message.content) {
      if (block.type === "toolCall" && typeof block.id === "string") adapter?.addCall(block.id);
    }
  };
  pi.on("message_start", event => track(event.message));
  pi.on("message_update", event => track(event.message));
  pi.on("message_end", event => track(event.message));
  pi.on("tool_execution_start", event => adapter?.addCall(event.toolCallId));
  // turn_end occurs between tool batches; agent_end may precede retries/follow-ups.
  pi.on("agent_settled", (_event, ctx) => { if (ctx.isIdle()) adapter?.settle(); });
  pi.on("session_tree", () => adapter?.settle());
  pi.on("session_shutdown", cleanup);
  pi.registerShortcut("ctrl+shift+o", {
    description: "Expand/collapse visible tool output (Ctrl+O shows/hides tools)",
    handler: async ctx => {
      if (adapter?.check()) ctx.ui.setToolsExpanded(!ctx.ui.getToolsExpanded());
    },
  });
  pi.registerCommand("turn-tools", {
    description: "Toggle inline tool visibility; /turn-tools off restores stock display until reload",
    handler: async (args, ctx) => {
      if (args.trim() === "off") {
        cleanup();
        ctx.ui.setWidget(WIDGET, undefined);
        ctx.ui.notify("Current-turn tools disabled; stock tool display restored.", "info");
      } else if (args.trim() === "") adapter?.toggle();
      else ctx.ui.notify("Usage: /turn-tools [off]", "error");
    },
  });
}
