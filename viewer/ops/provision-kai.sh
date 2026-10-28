#!/bin/bash
set -eu

test "$(hostname)" = kai
sudo -n true
backup="/opt/3d-backups/$(date -u +%Y%m%dT%H%M%SZ)"
sudo install -d -m 700 "$backup"
if test -d /opt/3d-viewer; then
    sudo tar -C /opt -czf "$backup/viewer-before.tar.gz" 3d-viewer
fi
sudo install -d -o ilia -g ilia -m 755 /opt/3d-viewer
tar -xzf /home/ilia/3d-viewer-source.tar.gz -C /opt/3d-viewer

if ! id stl-publisher >/dev/null 2>&1; then
    sudo useradd --system --no-create-home --home-dir /models --shell /usr/sbin/nologin stl-publisher
fi
sudo install -d -o root -g root -m 755 /srv/3d-sync
sudo install -d -o stl-publisher -g stl-publisher -m 755 /srv/3d-sync/models
sudo install -d -o root -g root -m 755 /etc/ssh/authorized_keys
sudo install -o root -g root -m 644 /home/ilia/3d-publisher.pub /etc/ssh/authorized_keys/stl-publisher
if test -f /etc/ssh/sshd_config.d/70-stl-publisher.conf; then
    sudo cp /etc/ssh/sshd_config.d/70-stl-publisher.conf "$backup/sshd-before.conf"
fi
sudo tee /etc/ssh/sshd_config.d/70-stl-publisher.conf >/dev/null <<'SSHCONFIG'
Match User stl-publisher
    ChrootDirectory /srv/3d-sync
    ForceCommand internal-sftp -d /models -u 022 -P symlink,hardlink,remove,rmdir
    AuthorizedKeysFile /etc/ssh/authorized_keys/stl-publisher
    AuthenticationMethods publickey
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    DisableForwarding yes
    PermitTTY no
    X11Forwarding no
    PermitTunnel no
Match all
SSHCONFIG
sudo /usr/sbin/sshd -t
sudo systemctl reload ssh

cd /opt/3d-viewer
docker compose config --quiet
docker compose build --memory 512m
docker compose up -d
python3 - <<'PY'
import subprocess,time
for attempt in range(30):
    result=subprocess.run(['docker','exec','model-gallery','python','-c',"import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8080/healthz',timeout=2).read().decode())"],capture_output=True,text=True)
    if result.returncode==0:
        print(result.stdout)
        break
    if attempt==29:raise SystemExit('Viewer health check failed')
    time.sleep(2)
PY
docker inspect --format '{{.Name}} readonly={{.HostConfig.ReadonlyRootfs}} user={{.Config.User}} ports={{json .HostConfig.PortBindings}}' model-gallery
echo "Backup directory: $backup"
