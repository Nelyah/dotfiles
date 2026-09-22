#!/usr/bin/env python3
"""Offline real Pi CLI checks in isolated tmux servers. Requires tmux."""
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import time

TESTS = Path(__file__).resolve().parent
PI = Path.home() / '.local/bin/pi'


def run(mode, base):
    work, config = base / 'work', base / 'config'
    work.mkdir(parents=True)
    config.mkdir()
    (work / 'changed.txt').write_text('original\n')
    (config / 'settings.json').write_text(json.dumps({
        'lastChangelogVersion': '0.87.0', 'quietStartup': True,
        'enableInstallTelemetry': False, 'defaultProjectTrust': 'never',
        'compaction': {'enabled': False}, 'retry': {'enabled': False},
    }))
    session = config / 'session.jsonl'  # Keep test runtime files outside the workspace.
    socket = f'pi-turn-diff-{os.getpid()}-{mode}'

    def tmux(*args):
        return subprocess.check_output(['tmux', '-L', socket, *args], text=True)

    def screen():
        return tmux('capture-pane', '-p', '-S', '-', '-t', 'proof:0.0')

    def command(text):
        tmux('send-keys', '-t', 'proof:0.0', '-l', text)
        tmux('send-keys', '-t', 'proof:0.0', 'Enter')

    def wait(predicate):
        deadline = time.monotonic() + 15
        while time.monotonic() < deadline:
            if predicate():
                time.sleep(.2)
                return
            time.sleep(.1)
        raise AssertionError(f'{mode}: timeout\n{screen()}')

    def entries():
        return [json.loads(line) for line in session.read_text().splitlines()]

    def summaries():
        return [entry for entry in entries() if entry.get('customType') == 'turn-diff']

    args = [str(PI), '--offline', '--tui-mode', mode, '--no-extensions', '--no-skills',
            '--no-prompt-templates', '--no-context-files',
            '-e', str(TESTS.parent / 'extensions/current-turn-tools.ts'),
            '-e', str(TESTS.parent / 'extensions/turn-diff.ts'),
            '-e', str(TESTS / 'turn-diff-fixture.ts'),
            '--provider', 'diff-fixture', '--model', 'demo', '--session', str(session)]
    launch = f'cd {shlex.quote(str(work))} && exec env PI_CODING_AGENT_DIR={shlex.quote(str(config))} PI_OFFLINE=1 PI_TELEMETRY=0 ' + shlex.join(args)
    try:
        tmux('new-session', '-d', '-s', 'proof', '-x', '120', '-y', '40', launch)
        time.sleep(2)
        command('change')
        wait(lambda: 'Turn diff' in screen())
        first = screen()
        assert first.index('FINAL_change') < first.index('Turn diff'), first
        assert 'changed.txt' in first and '+1 -0' in first, first
        assert len(summaries()) == 1
        assert summaries()[0]['type'] == 'custom'
        assert summaries()[0]['data']['files'] == [dict(path='changed.txt', status='M', added=1, removed=0)]
        last_answer = next(i for i, e in enumerate(entries()) if any(c.get('text') == 'FINAL_change' for c in e.get('message', {}).get('content', []) if isinstance(c, dict)))
        summary_index = next(i for i, e in enumerate(entries()) if e.get('customType') == 'turn-diff')
        assert last_answer < summary_index
        command('noop')
        wait(lambda: 'FINAL_noop' in screen())
        assert len(summaries()) == 1, 'zero-change response must not append a summary'
        context = json.loads((config / 'context.json').read_text())
        assert not any(m.get('customType') == 'turn-diff' for m in context), 'summary leaked into model context'
        command('/reload')
        time.sleep(1)
        assert 'Turn diff' in screen(), 'summary must survive reload'
        command('again')
        wait(lambda: 'FINAL_again' in screen())
        assert len(summaries()) == 1
        assert '[turn-diff]' not in screen(), screen()
        print(f'PASS {mode}: final placement, exact stats, zero suppression, display-only persistence, reload, tool-hiding compatibility')
    finally:
        subprocess.run(['tmux', '-L', socket, 'kill-server'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


with tempfile.TemporaryDirectory(prefix='pi-turn-diff-terminal-') as temporary:
    for mode in ['regular', 'fullscreen']:
        run(mode, Path(temporary) / mode)
