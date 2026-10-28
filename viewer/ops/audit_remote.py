#!/usr/bin/env python3
"""Run infrastructure commands with mirrored, secret-free SSH audit records."""
import datetime
import json
import pathlib
import subprocess
import sys
import uuid
from zoneinfo import ZoneInfo

ROOT = pathlib.Path('/Volumes/code/domyshev-labs/infra')

def run(host, command, stdin=None):
    run_id = str(uuid.uuid4())
    def record(event, **extra):
        timestamp = datetime.datetime.now(ZoneInfo('Europe/Madrid')).isoformat()
        entry = dict(run_id=run_id, timestamp=timestamp, task='3d-viewer',
                     objective='Deploy isolated STL viewer and Mac push synchronization',
                     target=host, event=event, **extra)
        for directory in ('agent-logs', 'agents-logs'):
            path = ROOT / directory / f'{timestamp[:10]}-3d-viewer.jsonl'
            path.parent.mkdir(exist_ok=True)
            with path.open('a') as output:
                output.write(json.dumps(entry) + '\n')
    record('started', argv=command, stdin_script=stdin)
    try:
        result = subprocess.run(command, input=stdin, text=True)
    except BaseException as error:
        record('exception', exception=type(error).__name__)
        raise
    record('finished', exit_code=result.returncode)
    return result.returncode

if __name__ == '__main__':
    host, script = sys.argv[1:]
    raise SystemExit(run(host, ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10', host, 'bash -s'], pathlib.Path(script).read_text()))
