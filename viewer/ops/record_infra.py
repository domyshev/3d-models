#!/usr/bin/env python3
"""Record the viewer deployment without staging unrelated infrastructure work."""
from pathlib import Path
import importlib.util
import shutil

source = Path(__file__).resolve().parents[1]
infra = Path('/Volumes/code/domyshev-labs/infra')
deployment = infra / 'deployments/kai/3d-viewer'
deployment.mkdir(parents=True, exist_ok=True)
for original, destination in [(source / 'compose.yaml', 'compose.yaml'),
                              (source / 'ops/3d.caddy', '3d.caddy'),
                              (source / 'ops/provision-kai.sh', 'provision-kai.sh')]:
    shutil.copyfile(original, deployment / destination)

spec = importlib.util.spec_from_file_location('akita_config', source / 'ops/configure_akita.py')
config = importlib.util.module_from_spec(spec)
spec.loader.exec_module(config)
for portal in ['public-portal', 'internal-portal']:
    path = infra / 'deployments/akita' / portal / 'index.html'
    text = path.read_text()
    if 'href="https://3d.iliago.com/"' not in text:
        marker = '<!-- BEGIN KAI APPS -->'
        assert text.count(marker) == 1
        path.write_text(text.replace(marker, config.CARD + marker))

(deployment / 'README.md').write_text('''# Public STL gallery on Kai

Deployed 2026-10-27; verified and finalized 2026-10-28.
Public URL: **https://3d.iliago.com/**.
Application source: `domyshev/3d-models`, directory `viewer/`.

## Placement and routing

- Kai VM106, isolated DMZ `10.77.0.2`, application directory `/opt/3d-viewer`.
- Independent container `model-gallery`, image `iliago-3d:1.0.0`, internal port
  8080 with **no published host ports**. There is no additional host-port allocation.
- Existing `kai-public_edge` network provides Caddy-to-container access;
  a separate internal `3d-viewer_viewer` Docker network is also attached.
- UID 10001, read-only root, all capabilities dropped, no-new-privileges,
  64-process and 256 MiB memory limits. No Docker socket or other app data mount.
- `/srv/3d-sync/models` is mounted read-only at `/models`. STL parsing and
  rendering happen in the browser using a locally bundled Three.js dependency.
- Exact DNS-only CNAME `3d.iliago.com -> home-ingress.iliago.com` uses the existing
  DDNS-managed home ingress. DNS credentials remain on Akita and were used there
  in place, without copying or printing their contents.
- Administrator-owned `/opt/kai-public/registry/3d.caddy` serves HTTPS and HTTP
  redirection through existing router/Proxmox NAT and Kai 80/443. Caddy validates
  before reload. This route is independent of the generated TLS frontend file;
  no Hermes publisher namespace or privilege was widened.
- Both portal implementations retain their source in this infra repository.
  Their 3D cards sit outside the generated Kai app sections and are deployed on
  Akita under `/home/ilia/docker/caddy/sandbox/{public,internal}-portal/index.html`.

## Mac-initiated synchronization

The source is `/Volumes/code/domyshev/3d-workshop/stl_exports`, including nested
date folders. Every nonempty regular STL there is public, including development
experiments. Source code, Git data, other extensions, symlinks and hidden files
are not published. No modeling-task change or Git push is required.

Launch agent: `com.iliago.3d-model-sync`, installed for the Mac user in
`~/Library/LaunchAgents`. Script, configuration, hash state and log reside in
`~/Library/Application Support/iliago-3d-sync/`. It checks file metadata every
3 seconds, waits for 4 seconds of observed stability, stages a snapshot and sends
only changed STLs. The catalog refreshes every 15 seconds while visible.
Initial publication transferred 99 STL files (approximately 650 MB).

The Mac initiates SFTP using the existing `kai` SSH alias through Proxmox, with
the dedicated `~/.ssh/iliago-3d-sync` identity. Private key contents are never
read, printed, transferred or committed by the installer. The server-side public
key is `/etc/ssh/authorized_keys/stl-publisher`.

`stl-publisher` is a system account with nologin shell, public-key-only auth,
`ChrootDirectory /srv/3d-sync`, and `ForceCommand internal-sftp -d /models -u 022
-P symlink,hardlink,remove,rmdir`. It cannot use a shell, TTY, forwarding,
password login, file deletion or link creation. The chroot is root-owned; only
its models directory is publisher-writable. SSH configuration is
`/etc/ssh/sshd_config.d/70-stl-publisher.conf`; validate with `sshd -t` before reload.

Temporary uploads are hidden and renamed atomically after completion. Original
source modification dates are retained. Deletions on Mac never remove server
models. Failed transfers retry; sleep/network recovery does not require manual
republication. The site serves already-published models while the Mac is off.
No Kai-to-LAN/VPN connection or firewall exception was added.

## Checks and audit

- Frontend build and four catalog/synchronization tests pass, covering timestamp
  ordering, symlink/traversal exclusion, atomic batch commands, failure retry
  state and non-propagation of deletions.
- HTTPS health, catalog order and a downloaded model hash verified from Mac;
  external Raven verified trusted HTTPS and the 99-file catalog.
- All 99 server STL SHA-256 values matched the Mac publication state.
- Container health, no host ports and read-only UID 10001 runtime verified.
- Live SSH policy confirmed chroot, forced SFTP, no passwords/TTY/forwarding.
- Kai attempts to Akita SSH and Proxmox management remain blocked by the DMZ.
- Both live directory pages contain the canonical 3D link.
- The running Mac launch agent published and replaced a disposable STL without
  a manual sync command, and retained its server copy after local deletion. The
  temporary validation artifact and its local state entry were removed afterward.
- Browser verification renders the actual Sarepta STL with model dimensions.

Exact SSH scripts/transfers and completion statuses are mirrored in
`agent-logs/` and `agents-logs/`, under `2026-10-27-3d-viewer*` and
`2026-10-28-3d-viewer*`. Automated sync appends its own daily audit files.
Secret values and environment contents are never logged.

## Maintenance and recovery

Application operators and detailed instructions are in the application repo's
`viewer/README.md` and `viewer/ops/`. Deploy uses an explicit application-only
archive, never the modeling or infrastructure repository root. It retains
source backups under `/opt/3d-backups/`. The initial source/SSH provision run used
`/opt/3d-backups/20261027T184046Z`; the final interface update used
`/opt/3d-backups/20261028T014119Z`. Caddy route backups use the same root with a
`-caddy` suffix. Published model storage is independent of image replacement.

Akita's pre-publication DNS/card backup is
`/home/ilia/docker/caddy/backups/20261027T184225Z-3d-viewer`.
The guest-agent attempt timed out without making changes; actual DNS and portal
updates completed through the existing Akita SSH user, with no sudo change.

For rollback, stop only `model-gallery` and remove only its exact Caddy route
after backing it up, then validate/reload Caddy. Remove its two directory cards
and, if desired, the exact DNS record. Disable the Mac launch agent with
`launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.iliago.3d-model-sync.plist`.
Keep `/srv/3d-sync/models`, the dedicated key and application backups until the
owner explicitly requests their deletion. Remove the SFTP account/config only
after disabling synchronization. Preserve all other sites, containers, DNS and
the external Proxmox DMZ boundary.
''')

path = infra / 'README.md'
text = path.read_text()
section = '''
## Public 3D model gallery, 2026-10-28

https://3d.iliago.com/ serves the STL collection from an independent Kai Docker
container. The Mac pushes changed files from the workshop export directory over
chrooted SFTP; no new Kai-to-LAN access or host application port is exposed.
Both directories link to it. See [deployment, synchronization and recovery](deployments/kai/3d-viewer/README.md).
'''
if '## Public 3D model gallery, 2026-10-28' not in text:
    path.write_text(text + section)
print('Recorded viewer deployment and both portal source cards')
