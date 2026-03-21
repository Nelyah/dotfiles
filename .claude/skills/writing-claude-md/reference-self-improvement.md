# Self-Improvement Patterns for CLAUDE.md

Static CLAUDE.md files decay as codebases evolve. Use these patterns to keep instructions current and effective.

## The Auto-Increment Loop

Three complementary practices that compound over time:

### 1. Correction-Driven Updates

After every correction from the user, end with: **"Update your CLAUDE.md so you don't make that mistake again."**

This transforms every mistake into a permanent improvement. Claude is effective at writing rules for itself — the resulting instructions tend to be specific and actionable.

**Process:**
1. User corrects Claude's behavior
2. Claude identifies the general rule behind the correction
3. Claude adds a concise, positive-framed rule to CLAUDE.md
4. Rule prevents the same class of mistake in future sessions

**Example flow:**
```
User: "No, don't use mocks for database tests — use the real database."
→ Add to CLAUDE.md: "Integration tests hit real databases. No mocking the DB layer."
```

### 2. Monthly Pruning

Schedule a monthly review of CLAUDE.md. For each rule, ask:

- Has this rule been relevant in the last 3 weeks?
- Does Claude still need this, or has the underlying code/convention changed?
- Is this still a real risk, or was it a one-time issue?

**If no to any of these → remove the rule.**

Without pruning, correction-driven updates cause unbounded growth. The two practices must pair: add after mistakes, prune on schedule.

### 3. Log-Based Analysis

Parse Claude Code session logs to identify improvement opportunities. Session logs are JSONL files in `~/.claude/projects/`.

**Prompt Claude to analyze its own history:**
```
Search through my session history files and analyze improvements
to the current CLAUDE.md, noting any times I get frustrated or
patterns of asking the same thing between sessions.
```

Look for:
- Repeated corrections across sessions (same mistake, not yet a rule)
- User frustration patterns (rephrasing, explicit "no", capitalized emphasis)
- Questions Claude keeps asking that could be answered by a rule
- Workflows Claude gets wrong that need step-by-step instructions

## Hook-Based Enforcement

CLAUDE.md instructions are advisory — Claude can and does ignore them. For critical rules, use hooks instead.

### Stop Hook for Formatting/Linting

Run formatters automatically after file edits:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "npx prettier --write $CLAUDE_FILE_PATH 2>/dev/null || true"
      }]
    }]
  }
}
```

### Post-Compaction Rule Injection

Re-inject critical rules after compaction to prevent instruction drift:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "compact",
      "hooks": [{
        "type": "command",
        "command": "cat .claude/post-compact-rules.md"
      }]
    }]
  }
}
```

Store your most critical 5–10 rules in `.claude/post-compact-rules.md`. These survive compaction because the hook re-injects them.

## CI/CD Integration for Teams

Use the Claude Code GitHub Action (`anthropics/claude-code-action`) to maintain CLAUDE.md as part of the review process:

- Tag `@claude` in PR comments to request CLAUDE.md updates
- Claude commits the change as part of the PR
- Team members can propose rules through the normal review process

This prevents individual rule drift and ensures the team agrees on conventions.

## Decision Tree: Where to Put a New Rule

```
Is this rule critical enough that ignoring it causes real damage?
├─ Yes → Put it in a hook (enforced, not advisory)
└─ No
   Is this rule relevant to all sessions?
   ├─ Yes → Put it in root CLAUDE.md
   └─ No
      Is it relevant to specific file types?
      ├─ Yes → Put it in .claude/rules/ with paths: glob
      └─ No
         Is it a multi-step workflow?
         ├─ Yes → Make it a skill in .claude/skills/
         └─ No → Put it in a subdirectory CLAUDE.md
```
