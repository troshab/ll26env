#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing pwndbg ==="
if [ ! -d "$HOME/pwndbg" ]; then
  git clone --depth=1 https://github.com/pwndbg/pwndbg.git "$HOME/pwndbg"
fi
cd "$HOME/pwndbg"
./setup.sh

echo "=== Configuring ptrace ==="
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null || true

echo "=== Configuring Fluxbox startup (clipboard sync) ==="
cat >> "$HOME/.fluxbox/startup" << 'EOF'
# Clipboard sync for VNC
autocutsel -fork
autocutsel -selection PRIMARY -fork
EOF

echo "=== Patching noVNC for remote resize ==="
NOVNC_HTML=$(find /usr -name "vnc.html" 2>/dev/null | head -1)
if [ -f "$NOVNC_HTML" ]; then
  sudo sed -i "s/resize: 'off'/resize: 'remote'/g" "$NOVNC_HTML" || true
fi

echo "=== Creating Ghidra launcher ==="
cat << 'EOF' | sudo tee /usr/local/bin/ghidra > /dev/null
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
exec /opt/ghidra/ghidraRun "$@"
EOF
sudo chmod +x /usr/local/bin/ghidra

echo "=== Setting environment variables ==="
cat >> "$HOME/.bashrc" << 'EOF'
export BROWSER=epiphany
export EDITOR=geany

# Desktop URL
if [ -n "$CODESPACE_NAME" ]; then
  echo "Desktop: https://${CODESPACE_NAME}-6080.app.github.dev (password: pwn)"
fi
EOF

echo "=== Building test binary ==="
mkdir -p "$HOME/test"
gcc -fno-stack-protector -no-pie -g -o "$HOME/test/vuln" /workspaces/*/test/vuln.c
chmod +x "$HOME/test/vuln"
echo "Test binary: ~/test/vuln (buffer overflow, use with gdb/ghidra)"

echo "=== Smoke test ==="
gdb --version | head -1
python3 -c "from pwn import *; print('pwntools OK')"
which one_gadget && echo "one_gadget OK"
which ropper && echo "ropper OK"
which ROPgadget && echo "ROPgadget OK"
[ -f /opt/ghidra/ghidraRun ] && echo "Ghidra OK"

echo "=== Setup complete ==="
echo "Desktop: open the 6080 port in browser (password: pwn)"
echo "Ghidra: run 'ghidra' or use right-click menu"
