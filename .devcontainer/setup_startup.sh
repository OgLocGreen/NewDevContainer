#!/bin/bash
set -e

# Activate the virtual environment
export VIRTUAL_ENV=/app/venv
export PATH="$VIRTUAL_ENV/bin:$PATH"
source "$VIRTUAL_ENV/bin/activate"

# Install / update Python dependencies
python -m pip install --no-cache-dir -r /app/new_dev_container/.devcontainer/requirements.txt

# Allow GUI apps from the container on the host X server (best-effort; no-op without X)
xhost +local:docker >/dev/null 2>&1 || true

# Probe GitHub SSH (non-fatal – just informational)
ssh -o StrictHostKeyChecking=accept-new -T git@github.com || true

echo "Setup complete. Container ready."
echo "Reminder: set your git identity once per host (mounted into the container):"
echo "  git config --global user.name  \"Your Name\""
echo "  git config --global user.email \"you@example.com\""
