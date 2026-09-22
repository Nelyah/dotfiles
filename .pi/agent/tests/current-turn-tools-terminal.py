#!/usr/bin/env python3
"""Offline CLI checks in private tmux servers/config directories; no real models/auth."""
import json, os, pathlib, shlex, subprocess, tempfile, time
HOME = pathlib.Path.home()
TESTS = pathlib.Path(__file__).resolve().parent
EXT = TESTS.parent / 'extensions/current-turn-tools.ts'
PI = HOME / '.local/bin/pi'
BASE = pathlib.Path(tempfile.mkdtemp(prefix='pi-current-turn-tools-'))
checks = []

def run_mode(mode):
    base = BASE / mode
    work = base / 'work'
    config = base / 'config'
    work.mkdir(parents=True)
    config.mkdir()
    (work / 'sample.txt').write_text('READ_FIXTURE_RESULT\n')
    (config / 'settings.json').write_text(json.dumps({
        'lastChangelogVersion': '0.86.1', 'quietStartup': True, 'enableInstallTelemetry': False,
        'defaultProjectTrust': 'never', 'compaction': {'enabled': False}, 'retry': {'enabled': False},
    }))
    socket = 'turn-tools-' + mode + '-' + str(os.getpid())
    def tmux(*args):
        return subprocess.check_output(['tmux', '-L', socket, *args], text=True)
    def key(k):
        tmux('send-keys', '-t', 'proof:0.0', k)
        time.sleep(.12)
    def text(s): tmux('send-keys', '-t', 'proof:0.0', '-l', s)
    def command(s): text(s); key('Enter')
    def capture(name):
        time.sleep(.12)
        s = tmux('capture-pane', '-p', '-S', '-', '-t', 'proof:0.0')
        (base / (name + '.txt')).write_text(s)
        return s
    def check(condition, name):
        if not condition: raise AssertionError(mode + ': ' + name)
        checks.append(mode + ': ' + name)
        print('PASS:', checks[-1], flush=True)
    def wait(predicate, timeout=15):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                if predicate(): return
            except (FileNotFoundError, json.JSONDecodeError): pass
            time.sleep(.08)
        raise AssertionError(mode + ': timed out')
    def phase(tag, batch):
        return json.loads((work / 'phase.json').read_text()) == {'tag': tag, 'batch': batch}
    def clean(s):
        return not any(x in s for x in ['CALL_', 'RESULT_', 'PROGRESS_', 'BASH_', 'ERROR_', 'read sample.txt'])
    args = [str(PI), '--offline', '--tui-mode', mode, '--no-extensions', '--no-skills', '--no-prompt-templates',
        '--no-context-files', '-e', str(EXT), '-e', str(TESTS / 'current-turn-tools-fixture.ts'),
        '-e', str(TESTS.parent / 'extensions/astra-fast.ts'),
        '--provider', 'turn-fixture', '--model', 'demo', '--session', str(work / 'session.jsonl')]
    env = f'PI_CODING_AGENT_DIR={shlex.quote(str(config))} PI_OFFLINE=1 PI_TELEMETRY=0'
    launch = f'cd {shlex.quote(str(work))} && exec env {env} ' + shlex.join(args)
    try:
        tmux('new-session', '-d', '-s', 'proof', '-x', '150', '-y', '65', launch)
        time.sleep(2)
        check('current-turn-tools]' not in capture('00-start'), 'loads without compatibility warnings')
        command('one'); wait(lambda: phase('one', 0)); time.sleep(.35)
        a = capture('01-live')
        check('CALL_one' in a and 'PROGRESS_one' in a, 'current tools visible automatically')
        check('fast n/a' in a, 'Astra footer still active')
        text('DRAFT_STAYS'); key('C-o'); a = capture('02-live-hidden')
        check(clean(a) and 'DRAFT_STAYS' in a, 'Ctrl+O completely hides current tools without losing draft')
        key('C-o'); a = capture('03-live-reveal')
        check('CALL_one' in a and 'DRAFT_STAYS' in a, 'Ctrl+O reveals current tools inline')
        key('C-u')
        wait(lambda: phase('one', 1)); a = capture('04-second-batch')
        check('CALL_one_0' in a and 'CALL_one_1' in a, 'tools remain visible across multiple tool batches')
        wait(lambda: phase('one', 2)); a = capture('05-final-stream')
        check('FINAL_one' in a and 'CALL_one' in a, 'tools remain until final response finishes')
        wait(lambda: (work / 'settled.txt').exists()); a = capture('06-settled')
        check('FINAL_one' in a and clean(a), 'settled response hides all headers/results including scrollback')
        key('C-o'); a = capture('07-history')
        check('CALL_one' in a and 'ERROR_one' in a and 'BASH_one' in a, 'idle Ctrl+O reveals history including errors and built-in tools')
        key('C-o'); check(clean(capture('08-history-hidden')), 'idle Ctrl+O hides history again')
        tmux('resize-window', '-t', 'proof:0', '-x', '100', '-y', '18')
        key('C-o'); capture('08b-small-revealed')
        key('C-o'); check(clean(capture('08c-small-hidden')), 'hiding a transcript taller than the terminal leaves no stale tool rows')
        tmux('resize-window', '-t', 'proof:0', '-x', '150', '-y', '65')
        key('C-o')
        command('two'); wait(lambda: phase('two', 0)); a = capture('09-next-turn')
        check('CALL_two' in a and 'CALL_one' not in a and 'BASH_one' not in a, 'new response resets revealed history and shows only current tools')
        old_settled = (work / 'settled.txt').read_text()
        key('Escape'); wait(lambda: (work / 'settled.txt').read_text() != old_settled)
        check(clean(capture('10-cancelled')), 'cancellation also hides tools')
        key('C-o'); check('CALL_two' in capture('11-cancelled-reveal'), 'cancelled calls remain recoverable')
        command('/reload'); time.sleep(1)
        check(clean(capture('12-reload')), '/reload starts with historical tools hidden')
        key('C-o'); check('CALL_one' in capture('13-reload-reveal'), 'Ctrl+O still works after reload')
        command('/fixture-dialog'); a = capture('14-dialog')
        check('DIALOG_TEST' in a, 'extension selector opens normally')
        key('C-o'); a = capture('15-dialog-key')
        check('DIALOG_TEST' in a and 'CALL_one' in a, 'Ctrl+O inside a dialog does not toggle transcript')
        key('Escape'); key('C-o'); check(clean(capture('16-dialog-closed')), 'returning to editor restores toggle')
        # Native session/context is unaffected by rendering.
        context = json.loads((work / 'provider-context.json').read_text())
        results = [m for m in context if m['role'] == 'toolResult']
        check(len(results) == 5, 'all tool results still reach the model')
        entries = [json.loads(line) for line in (work / 'session.jsonl').read_text().splitlines()]
        check(sum(e.get('message', {}).get('role') == 'toolResult' for e in entries) >= 5, 'tool history remains in session JSONL')
        key('C-d'); time.sleep(.4)
        # Resume with the same stored session.
        tmux('new-session', '-d', '-s', 'resume', '-x', '150', '-y', '65', launch)
        # Give the restarted process a fresh proof target for the helpers.
        tmux('rename-session', '-t', 'resume', 'proof')
        time.sleep(2)
        check(clean(capture('17-resume-hidden')), 'resumed sessions initially hide past tools')
        key('C-o'); check('CALL_one' in capture('18-resume-reveal'), 'resumed tool history can be revealed')
        command('/turn-tools off'); a = capture('19-disabled')
        check('CALL_one' in a and 'stock tool display restored' in a, 'explicit disable restores native inline display')
    finally:
        subprocess.run(['tmux', '-L', socket, 'kill-server'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

try:
    for mode in ['regular', 'fullscreen']: run_mode(mode)
finally:
    (BASE / 'results.json').write_text(json.dumps(checks, indent=2))
    print('Evidence:', BASE, flush=True)
print(f'{len(checks)} terminal checks passed.')
