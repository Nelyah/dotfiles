// Offline provider for turn-diff-terminal.py. Never load in a normal session.
import { createAssistantMessageEventStream } from "@earendil-works/pi-ai";
import { writeFileSync } from "node:fs";
import { join } from "node:path";

export default function (pi) {
  pi.registerProvider("diff-fixture", {
    api: "diff-fixture-api", baseUrl: "http://127.0.0.1:1", apiKey: "offline-only",
    models: [{ id: "demo", name: "Offline diff fixture", reasoning: false, input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 128000, maxTokens: 4096 }],
    streamSimple(model, context) {
      const stream = createAssistantMessageEventStream();
      const start = context.messages.findLastIndex(message => message.role === "user");
      const user = context.messages[start];
      const prompt = typeof user.content === "string" ? user.content : user.content.map(block => block.text ?? "").join("");
      const called = context.messages.slice(start).some(message => message.role === "toolResult");
      const change = prompt.trim() === "change" && !called;
      const output = {
        role: "assistant", content: [], api: model.api, provider: model.provider, model: model.id,
        usage: { input: 10, output: 10, cacheRead: 0, cacheWrite: 0, totalTokens: 20,
          cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 } },
        stopReason: change ? "toolUse" : "stop", timestamp: Date.now(),
      };
      queueMicrotask(() => {
        stream.push({ type: "start", partial: structuredClone(output) });
        if (change) {
          const toolCall = { type: "toolCall", id: `write-${Date.now()}`, name: "write",
            arguments: { path: "changed.txt", content: "original\nadded\n" } };
          output.content.push(toolCall);
          stream.push({ type: "toolcall_start", contentIndex: 0, partial: structuredClone(output) });
          stream.push({ type: "toolcall_delta", contentIndex: 0, delta: JSON.stringify(toolCall.arguments), partial: structuredClone(output) });
          stream.push({ type: "toolcall_end", contentIndex: 0, toolCall, partial: structuredClone(output) });
        } else {
          const text = `FINAL_${prompt.trim()}`;
          output.content.push({ type: "text", text });
          stream.push({ type: "text_start", contentIndex: 0, partial: structuredClone(output) });
          stream.push({ type: "text_delta", contentIndex: 0, delta: text, partial: structuredClone(output) });
          stream.push({ type: "text_end", contentIndex: 0, content: text, partial: structuredClone(output) });
          writeFileSync(join(process.env.PI_CODING_AGENT_DIR!, "context.json"), JSON.stringify(context.messages));
        }
        stream.push({ type: "done", reason: output.stopReason, message: output });
        stream.end();
      });
      return stream;
    },
  });
}
