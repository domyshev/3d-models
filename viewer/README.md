# iliago 3D model gallery

Public STL catalog at **https://3d.iliago.com/**, deployed in its own Docker
container on isolated Kai. The browser renders models locally with Three.js.
No external CDN, account, upload form or server-side mesh rendering is required.

## Interface

The light and dark themes share a burgundy palette. The header theme selector
follows the device by default; explicit choices persist in local storage and
update the interface, model material and floor grid together.

- Newest source modification times first, with the newest model selected on entry.
- Recursive catalog, filename/path search and alternative sorting.
- Orbit, zoom, wireframe, optional automatic rotation and reset view.
- Bounding dimensions in millimeters (STL coordinates are assumed to be mm),
  triangle count, download and shareable model URL fragment.
- Catalog refresh every 15 seconds while visible. An updated selected STL reloads
  automatically. Existing selections remain selected when new models arrive.
- Responsive layout, keyboard controls and readable error/empty states.

Only nonempty regular `.stl` files are served. Hidden files, partial uploads,
symlinks, other extensions and parent traversal are excluded. The HTTP service
provides no write endpoint. CPU-heavy parsing and rendering happen in the browser.

## Automatic publication from Mac

Source: `/Volumes/code/domyshev/3d-workshop/stl_exports`, recursively. The sibling
modeling task already exports there; it needs no new export command or Git push.
**Every STL in this source tree is published to the public site**, including
experimental versions. Do not place private models in that tree.

`sync/sync_models.py` checks metadata every 3 seconds and acts only on changed
files. A changed file must remain stable across two observations 4 seconds apart.
It stages the contents, calculates SHA-256, preserves the source timestamp, sends
the file by SFTP to a hidden temporary path, then atomically renames it. Unchanged
files require no connection. Deletions are never propagated. A failed batch is
retried; it never marks unconfirmed transfers as published.

The Mac initiates all connections using the existing `kai` SSH route through
Proxmox and a dedicated key. Kai initiates no connection into the home LAN.
The `stl-publisher` account is chrooted to `/srv/3d-sync`, has no shell, password
authentication, forwarding or TTY, and cannot remove files or create links.
The viewer mounts `/srv/3d-sync/models` read-only.

Install/update the per-user Mac launch agent:

```sh
python3 viewer/sync/install_mac.py
```

The agent starts at login and restarts after failure. Synchronization resumes
after sleep/connectivity recovery. Published models remain available when the
Mac is off. Typical discovery/publication latency is 7–22 seconds plus transfer
time; failed connections retry after 25 seconds.

Local state and log: `~/Library/Application Support/iliago-3d-sync/`.
Launch agent: `~/Library/LaunchAgents/com.iliago.3d-model-sync.plist`.
The dedicated identity is `~/.ssh/iliago-3d-sync`; never print or commit it.
Exact SFTP commands, file hashes and completion statuses are recorded in both
`agent-logs/` and `agents-logs/` of the private infra checkout. No secret contents
are logged. Future sync runs naturally append new audit records after deployment.

## Development and deployment

```sh
cd viewer
npm ci --ignore-scripts
npm run build
python3 -B -m unittest discover -s tests -v
MODEL_ROOT=/path/to/stl_exports PORT=8793 python3 -B server.py
```

Container configuration: `compose.yaml`. Runtime: Python standard library,
unprivileged UID 10001, read-only root and model mount, no capabilities or Docker
socket, 256 MiB memory limit and health check. There are no published host ports.
Caddy reaches the container through the existing `kai-public_edge` Docker network.
The DMZ boundary continues to deny new LAN/VPN connections.

`ops/deploy.py` packages only application files, uploads through audited SSH,
backs up the current source, validates SSH/Compose, builds and starts the viewer.
It provisions the restricted SFTP account. The private key remains on the Mac.
It does not touch source models or another application's volume/container.

`ops/publish.py` creates only the exact approved DNS-only CNAME
`3d.iliago.com -> home-ingress.iliago.com`, refusing conflicting existing records.
DNS credentials stay on Akita. It inserts a card into both live portals without
overwriting their generated app sections, and installs `ops/3d.caddy` on Kai.
This fixed administrative route does not broaden the Hermes `app-*` namespace.
The infrastructure repository contains the corresponding tracked deployment notes,
configuration and portal source changes.

Before running these operators, verify the named live paths and retain backups.
Every SSH operation goes through `ops/audit_remote.py`; its infra checkout path
is intentionally explicit for this installation. Run from the repository root.
No forced Git push is used.

## Shared local viewer for modeling chats

Run `viewer/local-viewer.sh` from any directory and open
`http://127.0.0.1:18795/`. This local instance listens only on the same
computer and is separate from the public gallery. It stays available while the
process is running; start it again after stopping it or restarting the computer.

Each chat can use a separate, descriptive folder under `viewer/local-models/`.
Folders appear as a collapsible hierarchy in the model list; nested paths
can retain the workshop's dated export layout. The directory is
ignored by Git and is not the public sync source. The gallery discovers STL
files recursively and refreshes the catalog automatically. SCAD sources must be
exported to STL first, following the modeling repository's export instructions
and the base path supplied in that chat. Use a unique folder name for each chat
and reuse this one viewer rather than starting a server for each model.
