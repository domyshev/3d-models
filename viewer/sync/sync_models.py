#!/usr/bin/env python3
"""Publish stable STL exports over chrooted SFTP; never propagate deletions."""
import argparse
from contextlib import contextmanager
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import uuid
from zoneinfo import ZoneInfo

def scan(source):
    result = {}
    for directory, directories, files in os.walk(source, followlinks=False):
        directories[:] = [d for d in directories if not d.startswith('.') and not (Path(directory) / d).is_symlink()]
        for name in files:
            path = Path(directory) / name
            if path.is_symlink() or path.suffix.lower() != '.stl' or name.startswith('.') or not path.is_file():
                continue
            relative = path.relative_to(source).as_posix()
            # SFTP batch commands cannot safely represent control characters.
            if any(ord(c) < 32 or ord(c) == 127 for c in relative):
                continue
            info = path.stat()
            if info.st_size > 0:
                result[relative] = dict(size=info.st_size, mtime_ns=info.st_mtime_ns)
    return result

def quoted(value):
    return '"' + str(value).replace('\\', '\\\\').replace('"', '\\"') + '"'

def audit(root, event, run_id, **fields):
    timestamp = datetime.datetime.now(ZoneInfo('Europe/Madrid')).isoformat()
    entry = dict(timestamp=timestamp, event=event, run_id=run_id, task='3d-viewer-sync',
                 objective='Push changed STL exports from Mac to isolated Kai', target='kai', **fields)
    for directory in ('agent-logs', 'agents-logs'):
        output = root / directory / f'{timestamp[:10]}-3d-viewer-sync.jsonl'
        output.parent.mkdir(parents=True, exist_ok=True)
        with output.open('a') as stream:
            stream.write(json.dumps(entry) + '\n')

def synchronize(config):
    source, state_dir = Path(config['source']), Path(config['state_dir'])
    if not source.is_dir():
        raise RuntimeError('STL export directory is unavailable')
    state_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (state_dir / 'lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        state_file = state_dir / 'published.json'
        state = json.loads(state_file.read_text()) if state_file.exists() else {}
        first = scan(source)
        candidates = {n: info for n, info in first.items() if state.get(n, {}).get('signature') != info}
        if not candidates:
            return
        # Two observations plus staging prevent uploading an in-progress export.
        time.sleep(config.get('settle_seconds', 4))
        second = scan(source)
        commands, published = [], {}
        with tempfile.TemporaryDirectory(prefix='3d-publish-') as temporary:
            spool = Path(temporary)
            directories = set()
            for index, (name, signature) in enumerate(candidates.items()):
                if second.get(name) != signature:
                    continue
                original = source / name
                staged = spool / f'{index}.stl'
                shutil.copyfile(original, staged)
                info = original.stat()
                if dict(size=info.st_size, mtime_ns=info.st_mtime_ns) != signature:
                    continue
                digest = hashlib.sha256(staged.read_bytes()).hexdigest()
                # Revalidate after reading; completed files retain source timestamps.
                os.utime(staged, ns=(info.st_atime_ns, info.st_mtime_ns))
                os.chmod(staged, 0o644)
                if state.get(name, {}).get('sha256') == digest and state.get(name, {}).get('signature', {}).get('mtime_ns') == signature['mtime_ns']:
                    state[name] = dict(signature=signature, sha256=digest)
                    continue
                remote = '/models/' + name
                for parent in reversed(Path(remote).parent.parents):
                    if str(parent) not in ('/', '/models'):
                        directories.add(str(parent))
                if str(Path(remote).parent) != '/models':
                    directories.add(str(Path(remote).parent))
                remote_tmp = str(Path(remote).parent / ('.upload-' + uuid.uuid4().hex + '.part'))
                commands.extend([f'put -p {quoted(staged)} {quoted(remote_tmp)}', f'rename {quoted(remote_tmp)} {quoted(remote)}'])
                published[name] = dict(signature=signature, sha256=digest)
            if commands:
                batch = '\n'.join([f'-mkdir {quoted(d)}' for d in sorted(directories, key=lambda d: (d.count('/'), d))] + commands) + '\n'
                command = ['sftp', '-q', '-b', '-', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10',
                           '-o', 'IdentitiesOnly=yes', '-i', config['identity'], '-o', 'User=stl-publisher', config.get('host', 'kai')]
                run_id = str(uuid.uuid4())
                infra = Path(config['infra_root'])
                audit(infra, 'started', run_id, argv=command, stdin_script=batch,
                      files={n: dict(sha256=d['sha256'], **d['signature']) for n, d in published.items()})
                try:
                    completed = subprocess.run(command, input=batch, text=True, capture_output=True, timeout=600)
                except BaseException as error:
                    audit(infra, 'exception', run_id, exception=type(error).__name__)
                    raise
                audit(infra, 'finished', run_id, exit_code=completed.returncode)
                if completed.returncode:
                    raise RuntimeError(f'SFTP failed ({completed.returncode}): {completed.stderr[-1000:]}')
                state.update(published)
                print(f'{datetime.datetime.now().isoformat()}: published {len(published)} STL files', flush=True)
            temporary_state = state_file.with_suffix('.tmp')
            temporary_state.write_text(json.dumps(state, indent=2) + '\n')
            os.replace(temporary_state, state_file)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=Path, required=True)
    parser.add_argument('--watch', action='store_true')
    args = parser.parse_args()
    config = json.loads(args.config.read_text())
    while True:
        try:
            synchronize(config)
        except Exception as error:
            print(f'{datetime.datetime.now().isoformat()}: {error}', flush=True)
            if not args.watch:
                raise SystemExit(1)
            time.sleep(25)
        if not args.watch:
            return
        time.sleep(3)

if __name__ == '__main__':
    main()
