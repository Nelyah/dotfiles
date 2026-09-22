// Offline real-terminal fixture. Load only in an isolated PI_CODING_AGENT_DIR.
import { createAssistantMessageEventStream } from "@earendil-works/pi-ai";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { writeFileSync } from "node:fs";
import { setTimeout as sleep } from "node:timers/promises";

export default function (pi) {
  pi.registerProvider("turn-fixture", {
    api: "turn-fixture-api", baseUrl: "http://127.0.0.1:1", apiKey: "offline-only",
    models: [{ id: "demo", name: "Offline fixture", reasoning: false, input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 128000, maxTokens: 4096 }],
    streamSimple(model, context, options) {
      const stream = createAssistantMessageEventStream();
      (async () => {
        const output = { role: "assistant", content: [], api: model.api, provider: model.provider, model: model.id,
          usage: { input: 100, output: 30, cacheRead: 0, cacheWrite: 0, totalTokens: 130,
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 } },
          stopReason: "pending", timestamp: Date.now() };
        const snapshot = () => structuredClone(output);
        const start = context.messages.findLastIndex(m => m.role === "user");
        const user = context.messages[start];
        const tag = (typeof user.content === "string" ? user.content : user.content.map(c => c.text ?? "").join("" )).trim();
        const batch = context.messages.slice(start).filter(m => m.role === "assistant" && m.stopReason === "toolUse").length;
        try {
          stream.push({ type: "start", partial: snapshot() });
          const text = batch < 2 ? `WORKING_${tag}_${batch}` : `FINAL_${tag}`;
          output.content.push({ type: "text", text });
          stream.push({ type: "text_start", contentIndex: 0, partial: snapshot() });
          stream.push({ type: "text_delta", contentIndex: 0, delta: text, partial: snapshot() });
          stream.push({ type: "text_end", contentIndex: 0, content: text, partial: snapshot() });
          writeFileSync("phase.json", JSON.stringify({ tag, batch }));
          if (batch < 2) {
            const calls = batch === 0 ? [
              ["read", { path: "sample.txt" }],
              ["bash", { command: `printf 'BASH_${tag}\\n'` }],
              ["turn_probe", { tag, batch, error: true }],
              ["turn_probe", { tag, batch, error: false }],
            ] : [["turn_probe", { tag, batch, error: false }]];
            for (const [name, args] of calls) {
              const toolCall = { type: "toolCall", id: `${tag}-${Date.now()}-${output.content.length}`, name, arguments: args };
              output.content.push(toolCall);
              const contentIndex = output.content.length - 1;
              stream.push({ type: "toolcall_start", contentIndex, partial: snapshot() });
              stream.push({ type: "toolcall_delta", contentIndex, delta: JSON.stringify(args), partial: snapshot() });
              stream.push({ type: "toolcall_end", contentIndex, toolCall, partial: snapshot() });
            }
          } else {
            writeFileSync("provider-context.json", JSON.stringify(context.messages));
            await sleep(1800, undefined, { signal: options?.signal });
          }
          output.stopReason = batch < 2 ? "toolUse" : "stop";
          stream.push({ type: "done", reason: output.stopReason, message: output });
        } catch (error) {
          output.stopReason = options?.signal?.aborted ? "aborted" : "error";
          output.errorMessage = String(error);
          stream.push({ type: "error", reason: output.stopReason, error: output });
        }
        stream.end();
      })();
      return stream;
    },
  });
  pi.registerTool({
    name: "turn_probe", label: "Turn probe", description: "Offline progress fixture",
    parameters: Type.Object({ tag: Type.String(), batch: Type.Number(), error: Type.Boolean() }),
    async execute(_id, args, signal, onUpdate) {
      if (args.error) throw new Error(`ERROR_${args.tag}`);
      for (let i = 0; i < 12; i++) {
        onUpdate?.({ content: [{ type: "text", text: `PROGRESS_${args.tag}_${args.batch}_${i}` }] });
        await sleep(250, undefined, { signal });
      }
      return { content: [{ type: "text", text: `RESULT_${args.tag}_${args.batch}` }], details: {} };
    },
    renderCall(args) { return new Text(`CALL_${args.tag}_${args.batch}`, 0, 0); },
    renderResult(result) { return new Text(result.content.map(c => c.text ?? "").join("\n"), 0, 0); },
  });
  pi.on("agent_settled", () => writeFileSync("settled.txt", String(Date.now())));
  pi.registerCommand("fixture-dialog", {
    handler: async (_args, ctx) => { await ctx.ui.select("DIALOG_TEST", ["Accept", "Cancel"]); },
  });
}
