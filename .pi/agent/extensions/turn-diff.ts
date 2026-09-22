/** Per-response, net filesystem diff. Display-only; never adds model context. */
import { execFile } from "node:child_process";
import { createHash } from "node:crypto";
import { createReadStream } from "node:fs";
import { lstat, mkdtemp, readdir, readFile, readlink, realpath, rm, writeFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { isAbsolute, join, relative, resolve, sep } from "node:path";
import { promisify } from "node:util";
import { getAgentDir, type ExtensionAPI, type Theme } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

const exec = promisify(execFile);
const TYPE = "turn-diff";
const MAX_FILES = 20_000;
const MAX_TEXT_BYTES = 2 * 1024 * 1024;
const MAX_SNAPSHOT_BYTES = 64 * 1024 * 1024;
const SKIP_DIRS = new Set([".git", ".hg", ".svn", "node_modules", ".venv", "venv", "__pycache__", ".cache"]);

type FileState = {
  hash: string;
  kind: "file" | "symlink";
  executable: boolean;
  text?: Buffer;
  binary: boolean;
};
export type FileDiff = {
  path: string;
  status: "A" | "M" | "D";
  added?: number;
  removed?: number;
  note?: string;
};
export type DiffSummary = { files: FileDiff[]; partial: boolean };

async function git(cwd: string, args: string[]) {
  return exec("git", ["-C", cwd, ...args], {
    encoding: "utf8", timeout: 15_000, maxBuffer: 16 * 1024 * 1024,
    env: { ...process.env, GIT_OPTIONAL_LOCKS: "0" },
  });
}

function inside(root: string, path: string) {
  const rel = relative(root, path);
  return rel === "" || (rel !== ".." && !rel.startsWith(`..${sep}`) && !isAbsolute(rel));
}

async function canonical(path: string): Promise<string> {
  try { return await realpath(path); }
  catch (error) {
    if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
    // Resolve symlinked parent directories even when the target does not exist yet.
    const parent = resolve(path, "..");
    return parent === path ? path : join(await canonical(parent), relative(parent, path));
  }
}

function toolPath(path: string, cwd: string) {
  path = path.replace(/^@/, "").replace(/[\u00a0\u2000-\u200a\u202f\u205f\u3000]/g, " ");
  if (path === "~" || path.startsWith("~/")) path = homedir() + path.slice(1);
  return resolve(cwd, path);
}

function lineCount(data: Buffer) {
  let count = 0;
  for (const byte of data) if (byte === 10) count++;
  return count + (data.length > 0 && data[data.length - 1] !== 10 ? 1 : 0);
}

async function lineDiff(before: Buffer, after: Buffer): Promise<{ added: number; removed: number }> {
  if (before.length === 0) return { added: lineCount(after), removed: 0 };
  if (after.length === 0) return { added: 0, removed: lineCount(before) };
  const dir = await mkdtemp(join(tmpdir(), "pi-turn-diff-"));
  try {
    await Promise.all([
      writeFile(join(dir, "before"), before, { mode: 0o600 }),
      writeFile(join(dir, "after"), after, { mode: 0o600 }),
    ]);
    // A private directory avoids repository attributes, filters, and index writes.
    let output: string;
    try {
      output = (await git(dir, ["diff", "--no-index", "--numstat", "--no-ext-diff", "--no-textconv",
        "--no-renames", "--no-color", "--", "before", "after"])).stdout;
    } catch (error) {
      const result = error as { code?: number; stdout?: string };
      if (result.code !== 1 || typeof result.stdout !== "string") throw error;
      output = result.stdout; // git diff exits 1 for a difference.
    }
    const match = /^(\d+)\t(\d+)\t/.exec(output);
    if (!match) throw new Error("No line counts from git diff");
    return { added: Number(match[1]), removed: Number(match[2]) };
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

export class TurnDiff {
  private root: string;
  private repository = false;
  private before = new Map<string, FileState | null>();
  private unreadable = new Set<string>();
  private snapshotBytes = 0;
  private partial = false;
  private readonly runtimeDirs: string[];
  private omitted: string[] = [];

  constructor(private cwd: string, agentDir = getAgentDir(), private sessionFile?: string) {
    this.root = cwd;
    // Do not report Pi's own session/cache writes as user project changes.
    this.runtimeDirs = ["sessions", "npm", "git", "backups"].map(name => resolve(agentDir, name));
  }

  private excluded(path: string) {
    return path === this.sessionFile || this.runtimeDirs.some(dir => inside(dir, path));
  }

  private omittedAtStart(path: string) {
    return this.omitted.some(item => item.endsWith(sep) ? path.startsWith(item) : path === item);
  }

  private async candidates(): Promise<string[]> {
    if (this.repository) {
      const { stdout } = await git(this.root, ["ls-files", "--cached", "--others", "--exclude-standard", "-z"]);
      const files = [...new Set(stdout.split("\0").filter(Boolean))]
        .map(path => resolve(this.root, path)).filter(path => !this.excluded(path) && !this.omittedAtStart(path));
      if (files.length > MAX_FILES) throw new Error(`workspace exceeds ${MAX_FILES} files`);
      return files;
    }
    const files: string[] = [];
    const visit = async (dir: string) => {
      for (const entry of await readdir(dir, { withFileTypes: true })) {
        const path = join(dir, entry.name);
        if (this.excluded(path) || SKIP_DIRS.has(entry.name)) continue;
        if (entry.isDirectory()) await visit(path);
        else if (entry.isFile() || entry.isSymbolicLink()) files.push(path);
        if (files.length > MAX_FILES) throw new Error(`workspace exceeds ${MAX_FILES} files`);
      }
    };
    await visit(this.root);
    return files;
  }

  private async snapshot(path: string, retain: boolean): Promise<FileState | null> {
    try {
      const stat = await lstat(path);
      if (!stat.isFile() && !stat.isSymbolicLink()) {
        // Git lists submodules as directories, not their individual files.
        if (retain && stat.isDirectory()) this.omitted.push(path + sep);
        return null;
      }
      const kind = stat.isSymbolicLink() ? "symlink" : "file";
      let data: Buffer | undefined;
      let hash: string;
      let binary = false;
      if (kind === "symlink") {
        data = Buffer.from(await readlink(path));
        hash = createHash("sha256").update(data).digest("hex");
      } else if (stat.size <= MAX_TEXT_BYTES && (!retain || this.snapshotBytes + stat.size <= MAX_SNAPSHOT_BYTES)) {
        data = await readFile(path);
        hash = createHash("sha256").update(data).digest("hex");
        binary = data.subarray(0, 8192).includes(0);
        if (binary) data = undefined;
      } else {
        const digest = createHash("sha256");
        let first = true;
        for await (const chunk of createReadStream(path)) {
          digest.update(chunk);
          if (first) binary = (chunk as Buffer).subarray(0, 8192).includes(0);
          first = false;
        }
        hash = digest.digest("hex");
      }
      if (retain && data) this.snapshotBytes += data.length;
      return { hash, kind, executable: !!(stat.mode & 0o111), text: data, binary };
    } catch (error) {
      if (["ENOENT", "ENOTDIR"].includes((error as NodeJS.ErrnoException).code ?? "")) return null;
      throw error;
    }
  }

  async start() {
    this.cwd = await canonical(this.cwd);
    if (this.sessionFile) this.sessionFile = await canonical(this.sessionFile);
    this.root = this.cwd;
    try {
      const { stdout } = await git(this.cwd, ["rev-parse", "--show-toplevel"]);
      this.root = await canonical(stdout.trimEnd());
      this.repository = true;
    } catch { /* A non-Git directory is a supported workspace. */ }
    if (this.repository) {
      try {
        // Collapse ignored directories so node_modules does not require enumeration.
        // Remember omissions: changing .gitignore must not turn existing files into additions.
        const { stdout } = await git(this.root, ["ls-files", "--others", "--ignored", "--exclude-standard", "--directory", "-z"]);
        this.omitted = stdout.split("\0").filter(Boolean).map(path =>
          resolve(this.root, path) + (path.endsWith("/") ? sep : ""));
      } catch { this.partial = true; }
    }
    let files: string[];
    try { files = await this.candidates(); }
    catch { this.partial = true; return; } // Direct edit/write tracking still works.
    for (const path of files) {
      try { this.before.set(path, await this.snapshot(path, true)); }
      catch { this.unreadable.add(path); this.partial = true; }
    }
  }

  /** Capture explicit edits to ignored files or paths outside the workspace. */
  async track(path: string) {
    path = await canonical(toolPath(path, this.cwd));
    if (this.before.has(path) || this.unreadable.has(path)) return;
    let covered = inside(this.root, path) && !this.excluded(path) && !this.omittedAtStart(path) && !this.partial;
    if (covered && !this.repository) {
      covered = !relative(this.root, path).split(sep).some(part => SKIP_DIRS.has(part));
    }
    // A covered path absent at start is new, even if a shell created it before edit.
    this.before.set(path, covered ? null : await this.snapshot(path, true));
  }

  async finish(): Promise<DiffSummary> {
    const paths = new Set(this.before.keys());
    try {
      for (const path of await this.candidates()) paths.add(path);
    } catch { this.partial = true; }
    const files: FileDiff[] = [];
    for (const path of [...paths].sort()) {
      if (this.unreadable.has(path)) continue;
      // With an incomplete baseline, unknown paths cannot safely be called new.
      if (this.partial && !this.before.has(path)) continue;
      const before = this.before.get(path) ?? null;
      let after: FileState | null;
      try { after = await this.snapshot(path, false); }
      catch { this.partial = true; continue; }
      if (!before && !after) continue;
      if (before && after && before.hash === after.hash && before.kind === after.kind && before.executable === after.executable) continue;
      const file: FileDiff = {
        path: relative(this.cwd, path) || path,
        status: !before ? "A" : !after ? "D" : "M",
      };
      const notes: string[] = [];
      if (before && after && before.executable !== after.executable) notes.push("mode");
      if (before?.kind === "symlink" || after?.kind === "symlink") notes.push("symlink");
      if (before?.binary || after?.binary) notes.push("binary");
      else if (before && after && before.hash === after.hash) {
        file.added = 0; file.removed = 0;
      } else if ((!before || before.text) && (!after || after.text)) {
        try { Object.assign(file, await lineDiff(before?.text ?? Buffer.alloc(0), after?.text ?? Buffer.alloc(0))); }
        catch { notes.push("line counts unavailable"); }
      } else notes.push("large file; line counts unavailable");
      if (notes.length) file.note = notes.join(", ");
      files.push(file);
    }
    return { files, partial: this.partial };
  }
}

function safePath(path: string) {
  if (!/[\x00-\x1f\x7f-\x9f\u2028-\u202e\u2066-\u2069]/.test(path)) return path;
  return JSON.stringify(path).replace(/[\x7f-\x9f\u2028-\u202e\u2066-\u2069]/g,
    char => `\\u${char.charCodeAt(0).toString(16).padStart(4, "0")}`);
}

export function formatSummary(summary: DiffSummary, theme: Theme): string {
  const added = summary.files.reduce((n, file) => n + (file.added ?? 0), 0);
  const removed = summary.files.reduce((n, file) => n + (file.removed ?? 0), 0);
  const counts = (a: number, d: number) => `${theme.fg("toolDiffAdded", `+${a}`)} ${theme.fg("toolDiffRemoved", `-${d}`)}`;
  const unknown = summary.files.some(file => file.added === undefined);
  const title = `Turn diff · ${summary.files.length} file${summary.files.length === 1 ? "" : "s"}`;
  const lines = [theme.fg("muted", title) + ` · ${counts(added, removed)}` + (unknown ? theme.fg("dim", " (text counts only)") : "")];
  for (const file of summary.files) {
    let line = `${theme.fg("dim", file.status)} ${safePath(file.path)}`;
    if (file.added !== undefined && file.removed !== undefined) line += `  ${counts(file.added, file.removed)}`;
    if (file.note) line += theme.fg("dim", ` (${file.note})`);
    lines.push(line);
  }
  if (summary.partial) lines.push(theme.fg("warning", "Partial summary: some workspace files could not be scanned."));
  return lines.join("\n");
}

export default function turnDiff(pi: ExtensionAPI) {
  let tracker: TurnDiff | undefined;
  pi.registerEntryRenderer<DiffSummary>(TYPE, (entry, { outputPad }, theme) => ({
    render: width => new Text(entry.data ? formatSummary(entry.data, theme) : "", outputPad, 0).render(width),
    invalidate() {}, // Theme colors are recomputed on every render.
  }));
  pi.on("agent_start", async (_event, ctx) => {
    if (ctx.mode !== "tui" || tracker) return; // Retain the baseline through retries.
    tracker = new TurnDiff(ctx.cwd, getAgentDir(), ctx.sessionManager.getSessionFile());
    try { await tracker.start(); }
    catch { tracker = undefined; }
  });
  pi.on("tool_call", async (event, ctx) => {
    if (!tracker || !["edit", "write"].includes(event.toolName)) return;
    if (typeof event.input.path !== "string") return;
    try { await tracker.track(event.input.path); }
    catch {
      // Observability must never block a tool (throwing from tool_call would).
      ctx.ui.notify("Turn diff: could not snapshot a file; its summary may be incomplete.", "warning");
    }
  });
  pi.on("agent_settled", async (_event, ctx) => {
    if (!tracker || !ctx.isIdle()) return;
    const current = tracker;
    tracker = undefined;
    try {
      const summary = await current.finish();
      if (summary.files.length > 0) pi.appendEntry(TYPE, summary);
    } catch {
      ctx.ui.notify("Turn diff: could not calculate this turn's summary.", "warning");
    }
  });
  // Never compare across reload, session replacement, or tree navigation.
  pi.on("session_start", () => { tracker = undefined; });
  pi.on("session_shutdown", () => { tracker = undefined; });
  pi.on("session_tree", () => { tracker = undefined; });
}
