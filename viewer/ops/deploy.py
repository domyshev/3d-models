#!/usr/bin/env python3
"""Package only the gallery and deploy it through audited SSH calls."""
from pathlib import Path
import subprocess
import tarfile
from audit_remote import run

root = Path(__file__).resolve().parents[1]
identity = Path.home() / '.ssh/iliago-3d-sync'
if not identity.exists():
    subprocess.run(['ssh-keygen', '-q', '-t', 'ed25519', '-N', '', '-C', 'iliago-3d-stl-publisher', '-f', str(identity)], check=True)
if not identity.with_suffix('.pub').is_file():
    raise SystemExit('Publisher public key missing; private keys are never read by this installer')
archive = Path('/private/tmp/3d-viewer-source.tar.gz')
with tarfile.open(archive, 'w:gz') as output:
    for name in ('server.py', 'Dockerfile', 'compose.yaml', 'package.json', 'package-lock.json', 'web'):
        output.add(root / name, arcname=name)
for local, destination in [(archive, '/home/ilia/3d-viewer-source.tar.gz'), (identity.with_suffix('.pub'), '/home/ilia/3d-publisher.pub')]:
    code = run('kai', ['scp', '-q', str(local), 'kai:' + destination])
    if code:
        raise SystemExit(code)
script = (root / 'ops/provision-kai.sh').read_text()
raise SystemExit(run('kai', ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10', 'kai', 'bash -s'], script))
