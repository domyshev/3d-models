#!/bin/sh
# Run the shared chat gallery on loopback only.
set -eu
viewer_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
model_root="$viewer_dir/local-models"
mkdir -p "$model_root"
export MODEL_ROOT="$model_root" BIND_HOST=127.0.0.1 PORT=18795
exec python3 -B "$viewer_dir/server.py"
