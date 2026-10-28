#!/usr/bin/env python3
"""Publish the fixed domain without widening the Hermes namespace or DMZ rules."""
from pathlib import Path
from audit_remote import run

root = Path(__file__).resolve().parent
inner = "python3 - <<'PYAKITA'\n" + (root / 'configure_akita.py').read_text() + '\nPYAKITA\n'
code = run('akita', ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10', 'akita', 'bash -s'], 'set -eu\n' + inner)
if code:
    raise SystemExit(code)
# Verify DNS and TLS independently before considering publication done.
caddy = (root / '3d.caddy').read_text()
script = '''set -eu
test "$(hostname)" = kai
backup="/opt/3d-backups/$(date -u +%Y%m%dT%H%M%SZ)-caddy"
sudo install -d -m 700 "$backup"
if test -f /opt/kai-public/registry/3d.caddy; then
    sudo cp /opt/kai-public/registry/3d.caddy "$backup/3d.caddy"
fi
sudo tee /opt/kai-public/registry/3d.caddy >/dev/null <<'CADDY'
''' + caddy + '''CADDY
sudo chmod 644 /opt/kai-public/registry/3d.caddy
docker exec kai-public-caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
docker exec kai-public-caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
docker exec kai-public-caddy wget -qO- http://model-gallery:8080/healthz
echo
'''
raise SystemExit(run('kai', ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10', 'kai', 'bash -s'], script))
