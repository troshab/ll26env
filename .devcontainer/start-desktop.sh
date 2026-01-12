#!/usr/bin/env bash
# Restart noVNC desktop if needed
# Desktop-lite feature auto-starts, use this only if you need to restart

set -euo pipefail

echo "Starting VNC server..."
/usr/local/share/desktop-init.sh &

echo "Desktop available at: http://localhost:6080"
echo "Password: pwn"
