#!/usr/bin/env python3
"""Provision the exact approved DNS name and add its card to both portals."""
from pathlib import Path
import datetime
import json
import shutil
import urllib.parse
import urllib.request
import urllib.error

NAME = '3d.iliago.com'
TARGET = 'home-ingress.iliago.com'
CARD = '''<a class="card" href="https://3d.iliago.com/">
<div class="top"><span class="icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m12 2 9 5v10l-9 5-9-5V7z M3 7l9 5 9-5 M12 12v10"/></svg></span><span class="arrow" aria-hidden="true">↗</span></div>
<h2>3D Models</h2><p>STL collection: preview and download</p><span class="host">3d.iliago.com</span>
</a>
'''

def main():
    backup = Path('/home/ilia/docker/caddy/backups') / (datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '-3d-viewer')
    backup.mkdir(parents=True, mode=0o700)
    # Use the existing Akita-local credential in place; never transfer or output it.
    credential = Path('/home/ilia/docker/ddns/secrets/cloudflare_api_token.txt').read_text().strip()
    def api(path, method='GET', body=None):
        request = urllib.request.Request('https://api.cloudflare.com/client/v4' + path, method=method,
            data=json.dumps(body).encode() if body else None,
            headers={'Authorization': 'Bearer ' + credential, 'Content-Type': 'application/json'})
        try:
            with urllib.request.urlopen(request, timeout=20) as response:
                result = json.load(response)
        except urllib.error.HTTPError as error:
            raise SystemExit('DNS operation rejected: HTTP ' + str(error.code))
        if not result.get('success'):
            raise SystemExit('DNS operation failed')
        return result['result']
    zones = api('/zones?name=iliago.com')
    if len(zones) != 1 or zones[0]['name'] != 'iliago.com':
        raise SystemExit('Unexpected DNS zone')
    prefix = '/zones/' + zones[0]['id'] + '/dns_records'
    records = api(prefix + '?name=' + urllib.parse.quote(NAME, safe=''))
    (backup / '3d-dns-before.json').write_text(json.dumps(records, indent=2) + '\n')
    if records:
        if len(records) != 1 or records[0]['type'] != 'CNAME' or records[0]['content'] != TARGET or records[0]['proxied']:
            raise SystemExit('Refusing to overwrite an existing conflicting DNS record')
        print('DNS already matches:', NAME)
    else:
        api(prefix, 'POST', dict(type='CNAME', name=NAME, content=TARGET, proxied=False, ttl=120,
                                comment='Administrator-approved STL viewer on isolated Kai'))
        print('Created DNS:', NAME, '->', TARGET)
    for name in ('public-portal', 'internal-portal'):
        path = Path('/home/ilia/docker/caddy/sandbox') / name / 'index.html'
        text = path.read_text()
        shutil.copy2(path, backup / (name + '-index.html'))
        if 'href="https://3d.iliago.com/"' not in text:
            marker = '<!-- BEGIN KAI APPS -->'
            if text.count(marker) != 1:
                raise SystemExit('Unexpected portal structure: ' + name)
            temporary = path.with_suffix('.3d-tmp')
            temporary.write_text(text.replace(marker, CARD + marker))
            shutil.copymode(path, temporary)
            shutil.chown(temporary, user='ilia', group='ilia')
            temporary.replace(path)
        print('Portal link verified:', name)
    print('Backup:', backup)

if __name__ == '__main__':
    main()
