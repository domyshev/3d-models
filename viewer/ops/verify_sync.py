#!/usr/bin/env python3
"""Check the running Mac watcher against a disposable STL, including replacement."""
import hashlib
import fcntl
import json
from pathlib import Path
import struct
import time
import urllib.request
import uuid
from audit_remote import run

directory = 'sync-validation-' + uuid.uuid4().hex
source = Path('/Volumes/code/domyshev/3d-workshop/stl_exports') / directory
source.mkdir()
file = source / 'watcher-check.stl'
name = directory + '/' + file.name
url = 'https://3d.iliago.com/models/' + name

def triangle(size):
    return b'Watcher validation'.ljust(80, b'\0') + struct.pack('<I12fH', 1, 0, 0, 1, 0, 0, 0, size, 0, 0, 0, size, 0, 0)

def wait_for_contents(expected):
    deadline = time.monotonic() + 50
    while time.monotonic() < deadline:
        try:
            request = urllib.request.Request(url, headers={'Cache-Control': 'no-cache'})
            with urllib.request.urlopen(request, timeout=5) as response:
                if response.read() == expected:
                    return
        except OSError:
            pass
        time.sleep(2)
    raise RuntimeError('Watcher publication timed out')

try:
    initial = triangle(1)
    file.write_bytes(initial)
    wait_for_contents(initial)
    print('Running launch agent published a new STL automatically', flush=True)
    replacement = triangle(2)
    file.write_bytes(replacement)
    wait_for_contents(replacement)
    print('Running launch agent replaced the existing STL automatically; downloaded bytes match', flush=True)
    file.unlink()
    time.sleep(6)
    with urllib.request.urlopen(url, timeout=10) as response:
        assert response.read() == replacement
    print('Source deletion did not remove the published STL', flush=True)
finally:
    if file.exists():
        file.unlink()
    source.rmdir()
    # Remove only the disposable server-side validation artifact made above.
    script = "set -eu\nsudo -n python3 - <<'PYCLEAN'\nfrom pathlib import Path\np=Path('/srv/3d-sync/models')/" + repr(name) + "\nif p.exists():p.unlink()\nif p.parent.exists():p.parent.rmdir()\nprint('Disposable synchronization check removed')\nPYCLEAN\n"
    code = run('kai', ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10', 'kai', 'bash -s'], script)
    if code:
        raise SystemExit(code)
    state_dir = Path.home() / 'Library/Application Support/iliago-3d-sync/state'
    with (state_dir / 'lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state_file = state_dir / 'published.json'
        state = json.loads(state_file.read_text())
        state.pop(name, None)
        temporary = state_file.with_suffix('.validation-tmp')
        temporary.write_text(json.dumps(state, indent=2) + '\n')
        temporary.replace(state_file)
