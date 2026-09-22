/**
 * /fast toggles Astra's Codex priority tier (2.5x standard Codex credits).
 * Off in new sessions; saved in the session branch across reload/resume/fork.
 * The footer shows the requested mode, not a server guarantee of priority service.
 * Uses public extension APIs only; no installed pi files are patched.
 */
import { homedir } from "node:os";
import { sep } from "node:path";
import { stripVTControlCharacters } from "node:util";
import type {
  ExtensionAPI,
  ExtensionContext,
  ReadonlyFooterDataProvider,
  Theme,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const STATE_TYPE = "astra-fast-mode";
const PROVIDER = "openai-codex";
const MODEL = "gpt-6-astra";

function supportsFast(ctx: ExtensionContext): boolean {
  return ctx.model?.provider === PROVIDER && ctx.model.id === MODEL;
}

function record(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function singleLine(text: string): string {
  return stripVTControlCharacters(text).replace(/\s+/g, " ").trim();
}

function tokens(count: number): string {
  if (count < 1_000) return String(count);
  if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
  if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
  return `${(count / 1_000_000).toFixed(1)}M`;
}

// A custom footer is needed: setStatus() puts text on a separate line, not after
// the effort. Keep directory/git/session, usage/context and other extension statuses.
function renderFooter(
  ctx: ExtensionContext,
  theme: Theme,
  footerData: ReadonlyFooterDataProvider,
  enabled: boolean,
  width: number,
): string[] {
  if (width <= 0) return [];
  const totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
  let cacheHit: number | undefined;
  for (const entry of ctx.sessionManager.getEntries()) {
    const usage = entry.type === "message"
      ? ((entry.message.role === "assistant" || entry.message.role === "toolResult")
        ? entry.message.usage : undefined)
      : ((entry.type === "compaction" || entry.type === "branch_summary") ? entry.usage : undefined);
    if (!usage) continue;
    totals.input += usage.input;
    totals.output += usage.output;
    totals.cacheRead += usage.cacheRead;
    totals.cacheWrite += usage.cacheWrite;
    totals.cost += usage.cost.total;
    if (entry.type === "message" && entry.message.role === "assistant") {
      const prompt = usage.input + usage.cacheRead + usage.cacheWrite;
      cacheHit = prompt > 0 ? 100 * usage.cacheRead / prompt : undefined;
    }
  }

  const parts: string[] = [];
  if (totals.input) parts.push(`↑${tokens(totals.input)}`);
  if (totals.output) parts.push(`↓${tokens(totals.output)}`);
  if (totals.cacheRead) parts.push(`R${tokens(totals.cacheRead)}`);
  if (totals.cacheWrite) parts.push(`W${tokens(totals.cacheWrite)}`);
  if ((totals.cacheRead || totals.cacheWrite) && cacheHit !== undefined) parts.push(`CH${cacheHit.toFixed(1)}%`);
  const model = ctx.model;
  const subscription = model && (model.provider === "kimi-coding" || (
    ctx.modelRegistry.isUsingOAuth(model) &&
    ctx.modelRegistry.getProvider(model.provider)?.auth.oauth?.isSubscription
  ));
  if (totals.cost || subscription) parts.push(`$${totals.cost.toFixed(3)}${subscription ? " (sub)" : ""}`);
  const context = ctx.getContextUsage();
  const percent = context?.percent;
  const contextText = `${percent == null ? "?" : percent.toFixed(1)}%/${tokens(context?.contextWindow ?? model?.contextWindow ?? 0)}`;
  parts.push(theme.fg(percent != null && percent > 90 ? "error" : percent != null && percent > 70 ? "warning" : "dim", contextText));
  const stats = theme.fg("dim", parts.join(" "));

  const label = supportsFast(ctx) ? (enabled ? "fast on" : "fast off") : "fast n/a";
  const badge = theme.fg(supportsFast(ctx) && enabled ? "success" : "dim", label);
  const effort = model?.reasoning ? (ctx.thinkingLevel || "off") : undefined;
  const tail = effort ? theme.fg("dim", `${effort} • `) + badge : badge;
  const suffix = theme.fg("dim", " • ") + tail;
  const modelName = singleLine(model?.id || "no-model");
  let right = theme.fg("dim", modelName) + suffix;
  if (model && footerData.getAvailableProviderCount() > 1) {
    const provider = theme.fg("dim", `(${singleLine(model.provider)}) `);
    if (visibleWidth(stats + provider + right) + 2 <= width) right = provider + right;
  }
  if (visibleWidth(right) > width) {
    const modelBudget = width - visibleWidth(suffix);
    right = modelBudget >= 4
      ? theme.fg("dim", truncateToWidth(modelName, modelBudget, "…")) + suffix
      : (visibleWidth(tail) <= width ? tail : truncateToWidth(badge, width, ""));
  }
  // Reserve space for the mode rather than letting token counters hide it.
  const leftBudget = width - visibleWidth(right) - 2;
  const left = leftBudget > 0 ? truncateToWidth(stats, leftBudget, "…") : "";
  const padding = " ".repeat(Math.max(0, width - visibleWidth(left) - visibleWidth(right)));

  const home = homedir();
  const cwd = ctx.sessionManager.getCwd();
  let location = cwd === home ? "~" : cwd.startsWith(home + sep) ? "~" + cwd.slice(home.length) : cwd;
  const branch = footerData.getGitBranch();
  const name = ctx.sessionManager.getSessionName();
  if (branch) location += ` (${branch})`;
  if (name) location += ` • ${name}`;
  const lines = [
    truncateToWidth(theme.fg("dim", singleLine(location)), width, "…"),
    left + padding + right,
  ];
  const statuses = [...footerData.getExtensionStatuses()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([, value]) => value.replace(/[\r\n\t]/g, " "));
  if (statuses.length) lines.push(truncateToWidth(statuses.join(" "), width, "…"));
  return lines;
}

export default function (pi: ExtensionAPI) {
  let enabled = false;
  let requestRender: (() => void) | undefined;

  function restore(ctx: ExtensionContext) {
    enabled = false;
    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type === "custom" && entry.customType === STATE_TYPE &&
          record(entry.data) && typeof entry.data.enabled === "boolean") {
        enabled = entry.data.enabled;
      }
    }
    requestRender?.();
  }

  pi.on("session_start", (_event, ctx) => {
    restore(ctx);
    if (ctx.mode !== "tui") return;
    ctx.ui.setFooter((tui, theme, footerData) => {
      const redraw = () => tui.requestRender();
      requestRender = redraw;
      const unsubscribe = footerData.onBranchChange(redraw);
      return {
        render: (width) => renderFooter(ctx, theme, footerData, enabled, width),
        invalidate() {}, // All text and theme colors are computed at render time.
        dispose() {
          unsubscribe();
          if (requestRender === redraw) requestRender = undefined;
        },
      };
    });
  });
  pi.on("session_tree", (_event, ctx) => restore(ctx));
  pi.on("model_select", () => requestRender?.());
  pi.on("thinking_level_select", () => requestRender?.());
  pi.on("session_shutdown", (_event, ctx) => {
    if (ctx.mode === "tui") ctx.ui.setFooter(undefined);
    requestRender = undefined;
  });

  pi.on("before_provider_request", (event, ctx) => {
    if (!supportsFast(ctx) || !record(event.payload) || event.payload.model !== MODEL) return;
    // Explicit default makes /fast off select standard service, even if the
    // incoming payload had a tier set. Never alter reasoning or another model.
    return { ...event.payload, service_tier: enabled ? "priority" : "default" };
  });

  pi.registerCommand("fast", {
    description: "Toggle Astra fast mode (2.5x Codex credits); /fast [on|off|status]",
    getArgumentCompletions(prefix) {
      return ["on", "off", "status"].filter((value) => value.startsWith(prefix))
        .map((value) => ({ value, label: value }));
    },
    handler: async (args, ctx) => {
      const arg = args.trim().toLowerCase();
      const notify = (text: string, type: "info" | "warning" | "error" = "info") => {
        if (ctx.hasUI) ctx.ui.notify(text, type);
      };
      if (arg === "status") {
        notify(supportsFast(ctx)
          ? `Astra fast mode: ${enabled ? "ON (2.5x Codex credits)" : "OFF"}.`
          : `Fast mode is inactive on this model (Astra preference: ${enabled ? "on" : "off"}).`);
        return;
      }
      if (arg !== "" && arg !== "on" && arg !== "off") {
        notify("Usage: /fast [on|off|status]", "error");
        return;
      }
      const next = arg === "" ? !enabled : arg === "on";
      if (next && !supportsFast(ctx)) {
        notify(`Fast mode is supported here only for ${PROVIDER}/${MODEL}.`, "warning");
        return;
      }
      if (next !== enabled) {
        pi.appendEntry(STATE_TYPE, { enabled: next });
        enabled = next;
      }
      requestRender?.();
      const timing = ctx.isIdle() ? "" : " Applies to the next request; the current request is unchanged.";
      notify((enabled ? "Astra fast mode ON — requests priority service at 2.5x Codex credits."
        : "Astra fast mode OFF — standard service.") + timing, enabled ? "warning" : "info");
    },
  });
}
