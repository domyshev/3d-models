#!/usr/bin/env python3
"""Verify publication, uploaded bytes and the existing external DMZ boundary."""
import hashlib
import json
from pathlib import Path
import urllib.request
import urllib.error
from audit_remote import run

base = 'https://3d.iliago.com'
with urllib.request.urlopen(base + '/api/models', timeout=20) as response:
    entries = json.load(response)['models']
assert entries and entries == sorted(entries, key=lambda e: (-e['modified'], e['id']))
latest = entries[0]
local = Path('/Volumes/code/domyshev/3d-workshop/stl_exports') / latest['id']
with urllib.request.urlopen(base + latest['url'], timeout=30) as response:
    digest = hashlib.sha256(response.read()).hexdigest()
assert digest == hashlib.sha256(local.read_bytes()).hexdigest()
print('Public HTTPS catalog:', len(entries), 'STL files; newest-first order and downloaded model SHA-256 verified')
for path in ['/.git/config', '/models/../server.py', '/models/.partial.stl', '/models/private.json']:
    try:
        urllib.request.urlopen(base + path, timeout=10)
        raise AssertionError('Unexpected public file: ' + path)
    except urllib.error.HTTPError as error:
        assert error.code == 404, (path, error.code)
for host in ['https://iliago.com/', 'https://public.iliago.com/']:
    with urllib.request.urlopen(host, timeout=15) as response:
        assert 'https://3d.iliago.com/' in response.read().decode()
    print('Directory link verified:', host)

state = json.loads((Path.home() / 'Library/Application Support/iliago-3d-sync/state/published.json').read_text())
expected = {name: data['sha256'] for name, data in state.items()}
script = '''set -eu
docker inspect --format '{{.State.Health.Status}} readonly={{.HostConfig.ReadonlyRootfs}} user={{.Config.User}} ports={{json .HostConfig.PortBindings}}' model-gallery
sudo /usr/sbin/sshd -T -C user=stl-publisher,host=kai,addr=192.168.1.100 | awk '/^(forcecommand|chrootdirectory|disableforwarding|permittty|passwordauthentication|authenticationmethods) /'
python3 - <<'PYVERIFY'
import hashlib,json,socket
from pathlib import Path
expected=json.loads(EXPECTED)
for name,digest in expected.items():
    path=Path('/srv/3d-sync/models')/name
    assert path.is_file() and hashlib.sha256(path.read_bytes()).hexdigest()==digest, name
print('Verified all',len(expected),'published STL hashes against Mac state')
for host,port in [('192.168.1.105',22),('192.168.1.100',8006)]:
    try:
        connection=socket.create_connection((host,port),timeout=3)
    except OSError:
        print('DMZ egress blocked:',host,port)
    else:
        connection.close()
        raise SystemExit('Unexpected LAN management access from Kai')
PYVERIFY
'''.replace('EXPECTED', repr(json.dumps(expected)))
code = run('kai', ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10', 'kai', 'bash -s'], script)
if code:
    raise SystemExit(code)
script = '''set -eu
python3 - <<'PYEXTERNAL'
import json,urllib.request
with urllib.request.urlopen('https://3d.iliago.com/healthz',timeout=15) as response:
    assert json.load(response)['status']=='ok'
with urllib.request.urlopen('https://3d.iliago.com/api/models',timeout=15) as response:
    entries=json.load(response)['models']
    assert entries
    print('External Raven HTTPS verified; STL count:',len(entries))
PYEXTERNAL
'''
raise SystemExit(run('raven', ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10', 'raven', 'bash -s'], script))
