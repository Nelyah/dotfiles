#!/usr/bin/env python3
"""Installer for Claude Code task-tracking hooks and skills."""

import argparse
import json
import os
import shutil
import stat
import sys
from dataclasses import dataclass
from enum import Enum
from pathlib import Path

CLAUDE_DIR = Path.home() / ".claude"
HOOKS_DIR = CLAUDE_DIR / "hooks"
SKILLS_DIR = CLAUDE_DIR / "skills" / "tracking-tasks"
SETTINGS = CLAUDE_DIR / "settings.json"
CLAUDE_MD = CLAUDE_DIR / "CLAUDE.md"
TEMPLATE_DIR = SKILLS_DIR / "templates"


def log(msg: str) -> None:
    print(f"  {msg}")


def header(msg: str) -> None:
    print(f"\n\033[1m{msg}\033[0m")


class HookEvent(Enum):
    USER_PROMPT_SUBMIT = "UserPromptSubmit"
    PRE_COMPACT = "PreCompact"
    STOP = "Stop"


@dataclass(frozen=True)
class HookEntry:
    matcher: str
    type: str
    command: str
    timeout: int


@dataclass
class HookRegistration:
    event: HookEvent
    command: str
    pattern: str
    timeout: int

    def to_entry(self) -> HookEntry:
        return HookEntry(
            matcher="*",
            type="command",
            command=self.command,
            timeout=self.timeout,
        )

    def to_dict(self) -> dict:
        entry = self.to_entry()
        return {
            "matcher": entry.matcher,
            "hooks": [
                {"type": entry.type, "command": entry.command, "timeout": entry.timeout}
            ],
        }

    def is_registered_in(self, entries: list) -> bool:
        return any(
            self.pattern in h.get("command", "")
            for e in entries
            for h in e.get("hooks", [])
        )


class Settings:
    def __init__(self, path: Path):
        self.path = path
        self.data = json.loads(path.read_text()) if path.exists() else {}

    def backup(self) -> None:
        if self.path.exists():
            shutil.copy2(self.path, self.path.with_suffix(".json.bak"))
            log(f"Backed up to {self.path.with_suffix('.json.bak')}")

    def save(self) -> None:
        self.path.write_text(json.dumps(self.data, indent=2) + "\n")

    def add_hook(self, reg: HookRegistration) -> None:
        hooks = self.data.setdefault("hooks", {})
        entries = hooks.setdefault(reg.event.value, [])
        if not reg.is_registered_in(entries):
            entries.append(reg.to_dict())

    def remove_hook(self, reg: HookRegistration) -> None:
        hooks = self.data.get("hooks", {})
        if reg.event.value not in hooks:
            return
        filtered = []
        for entry in hooks[reg.event.value]:
            entry["hooks"] = [
                h
                for h in entry.get("hooks", [])
                if reg.pattern not in h.get("command", "")
            ]
            if entry["hooks"]:
                filtered.append(entry)
        if filtered:
            hooks[reg.event.value] = filtered
        else:
            hooks.pop(reg.event.value, None)
        if not hooks:
            self.data.pop("hooks", None)


class ClaudeMd:
    MARKER = "# Task tracking"

    def __init__(self, path: Path):
        self.path = path

    def backup(self) -> None:
        if self.path.exists():
            shutil.copy2(self.path, self.path.with_suffix(".md.bak"))
            log(f"Backed up to {self.path.with_suffix('.md.bak')}")

    def append_section(self, template_path: Path) -> None:
        text = self.path.read_text() if self.path.exists() else ""
        if self.MARKER in text:
            log("Task tracking section already present, skipping")
            return
        section = template_path.read_text()
        with open(self.path, "a") as f:
            f.write("\n" + section)
        log("Appended task tracking section")

    def strip_section(self) -> None:
        if not self.path.exists():
            return
        text = self.path.read_text()
        if self.MARKER not in text:
            log("No task tracking section found, skipping")
            return
        self.backup()
        lines = text.splitlines()
        result, skip = [], False
        for line in lines:
            if line.rstrip() == self.MARKER:
                skip = True
                continue
            if skip and line.startswith("# "):
                skip = False
            if not skip:
                result.append(line)
        while result and not result[-1].strip():
            result.pop()
        self.path.write_text("\n".join(result) + "\n")
        log("Removed task tracking section")


class Installer:
    def __init__(self):
        self.settings = Settings(SETTINGS)
        self.claude_md = ClaudeMd(CLAUDE_MD)
        self.registrations = [
            HookRegistration(
                HookEvent.USER_PROMPT_SUBMIT,
                "bash ~/.claude/hooks/user-prompt-task.sh",
                "user-prompt-task",
                10,
            ),
            HookRegistration(
                HookEvent.PRE_COMPACT,
                "bash ~/.claude/hooks/pre-compact-task.sh",
                "pre-compact-task",
                5,
            ),
            HookRegistration(
                HookEvent.STOP,
                "bash ~/.claude/hooks/stop-task.sh",
                "stop-task",
                10,
            ),
        ]

    @staticmethod
    def install_file(src: Path, dst: Path, executable: bool = False) -> bool:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        if executable:
            dst.chmod(dst.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        log(f"Installed {dst.name}")
        return True

    def install(self) -> None:
        # 1. Create directories
        header("Creating directories")
        HOOKS_DIR.mkdir(parents=True, exist_ok=True)
        SKILLS_DIR.mkdir(parents=True, exist_ok=True)
        log(f"{HOOKS_DIR}")
        log(f"{SKILLS_DIR}")

        # 2. Copy hook templates → ~/.claude/hooks/
        header("Installing hook scripts")
        hook_src = TEMPLATE_DIR / "hooks"
        for name in ("user-prompt-task.sh", "pre-compact-task.sh", "stop-task.sh"):
            self.install_file(hook_src / name, HOOKS_DIR / name, executable=True)

        # 3. Merge hook registrations into settings.json
        header("Updating settings.json")
        self.settings.backup()
        for reg in self.registrations:
            self.settings.add_hook(reg)
        self.settings.save()
        log(f"Merged hooks into {SETTINGS}")

        # 4. Append CLAUDE.md section
        header("Updating CLAUDE.md")
        self.claude_md.append_section(TEMPLATE_DIR / "claude-md-section.md")

        # Summary
        header("Installation complete")
        print()
        print("  Files installed:")
        print(f"    {HOOKS_DIR}/user-prompt-task.sh")
        print(f"    {HOOKS_DIR}/pre-compact-task.sh")
        print(f"    {HOOKS_DIR}/stop-task.sh")
        print()
        print("  Files updated:")
        print(f"    {SETTINGS}")
        print(f"    {CLAUDE_MD}")
        print()

    def uninstall(self) -> None:
        header("Uninstalling task tracking")

        # 1. Remove hook files
        header("Removing hook files")
        for name in ("user-prompt-task.sh", "pre-compact-task.sh", "stop-task.sh"):
            path = HOOKS_DIR / name
            if path.exists():
                path.unlink()
                log(f"Removed {path}")
            else:
                log(f"{path} not found, skipping")

        # 2. Strip hooks from settings.json
        header("Cleaning settings.json")
        if SETTINGS.exists():
            self.settings.backup()
            for reg in self.registrations:
                self.settings.remove_hook(reg)
            self.settings.save()
            log(f"Cleaned task hooks from {SETTINGS}")
        else:
            log(f"{SETTINGS} not found, skipping")

        # 3. Strip CLAUDE.md section
        header("Cleaning CLAUDE.md")
        self.claude_md.strip_section()

        # Summary
        header("Uninstall complete")
        print()
        print("  Removed:")
        print(f"    Hook files in {HOOKS_DIR}/")
        print(f"    Hook entries in {SETTINGS}")
        print(f"    Task tracking section in {CLAUDE_MD}")
        print()
        print("  Not touched:")
        print(f"    {SKILLS_DIR}/ (installer, templates, skill files)")
        print("    .claude/tasklog/ directories in your projects (your task data)")
        print()


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="install.py",
        description="Manage Claude Code task tracking hooks and skills.",
        epilog=(
            "Components:\n"
            "  ~/.claude/hooks/user-prompt-task.sh    UserPromptSubmit hook\n"
            "  ~/.claude/hooks/pre-compact-task.sh    PreCompact hook\n"
            "  ~/.claude/hooks/stop-task.sh           Stop hook\n"
            "  ~/.claude/skills/tracking-tasks/       Skill files\n"
            "  ~/.claude/settings.json                Hook registrations\n"
            "  ~/.claude/CLAUDE.md                    Task tracking instructions"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command")
    sub.add_parser("install", help="Install or update all components")
    sub.add_parser("uninstall", help="Remove all components (keeps task data)")

    args = parser.parse_args()
    match args.command:
        case None:
            parser.print_help()
            sys.exit(1)
        case "install":
            Installer().install()
        case "uninstall":
            Installer().uninstall()


if __name__ == "__main__":
    main()
