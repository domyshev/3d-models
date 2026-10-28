#!/usr/bin/env python3
"""Install a per-user launch agent that reconciles changed STL exports."""
import json
from pathlib import Path
import plistlib
import shutil
import subprocess
import os

def main():
    home = Path.home()
    root = home / 'Library/Application Support/iliago-3d-sync'
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    shutil.copyfile(Path(__file__).with_name('sync_models.py'), root / 'sync_models.py')
    config = dict(source='/Volumes/code/domyshev/3d-workshop/stl_exports',
                  state_dir=str(root / 'state'), identity=str(home / '.ssh/iliago-3d-sync'),
                  infra_root='/Volumes/code/domyshev-labs/infra', host='kai', settle_seconds=4)
    (root / 'config.json').write_text(json.dumps(config, indent=2) + '\n')
    label = 'com.iliago.3d-model-sync'
    plist = home / f'Library/LaunchAgents/{label}.plist'
    plist.parent.mkdir(exist_ok=True)
    # Use a stable Python installation outside developer-tool shims.
    python = '/usr/bin/python3'
    data = dict(Label=label, ProgramArguments=[python, str(root / 'sync_models.py'), '--config', str(root / 'config.json'), '--watch'],
                RunAtLoad=True, KeepAlive=True, ThrottleInterval=30, ProcessType='Background',
                StandardOutPath=str(root / 'sync.log'), StandardErrorPath=str(root / 'sync.log'),
                EnvironmentVariables=dict(PATH='/usr/bin:/bin:/usr/sbin:/sbin'), LimitLoadToSessionType='Aqua')
    if plist.exists():
        subprocess.run(['launchctl', 'bootout', f'gui/{os.getuid()}', str(plist)], check=False, capture_output=True)
    with plist.open('wb') as stream:
        plistlib.dump(data, stream)
    subprocess.run(['launchctl', 'bootstrap', f'gui/{os.getuid()}', str(plist)], check=True)
    print('Installed', plist)

if __name__ == '__main__':
    main()
