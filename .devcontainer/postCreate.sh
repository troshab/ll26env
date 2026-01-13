#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/workspaces/ll26env"

echo "=== Installing pwndbg ==="
if [ ! -d "$HOME/pwndbg" ]; then
  git clone --depth=1 https://github.com/pwndbg/pwndbg.git "$HOME/pwndbg"
fi
cd "$HOME/pwndbg"
./setup.sh

echo "=== Configuring GDB with tty detection ==="
# Create .gdbinit that loads pwndbg only for interactive sessions
# This allows Ghidra debugger to use vanilla gdb
cat > "$HOME/.gdbinit" << 'GDBINIT'
python
import sys
import os

# Only load pwndbg for interactive terminal sessions
# Ghidra uses GDB via MI interface (stdin is not a tty)
if sys.stdin.isatty():
    pwndbg_path = os.path.expanduser("~/pwndbg/gdbinit.py")
    if os.path.exists(pwndbg_path):
        gdb.execute(f"source {pwndbg_path}")
end
GDBINIT

echo "=== Configuring ptrace ==="
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null || true

echo "=== Configuring Fluxbox startup (clipboard) ==="
cat >> "$HOME/.fluxbox/startup" << 'EOF'
# Clipboard sync for VNC
autocutsel -fork
autocutsel -selection PRIMARY -fork
EOF

echo "=== Killing vncconfig window ==="
pkill -f "vncconfig" 2>/dev/null || true
pkill -f "tigervncconfig" 2>/dev/null || true

echo "=== Patching noVNC for remote resize ==="
NOVNC_DIR="/usr/local/novnc/noVNC-1.6.0"
if [ -d "$NOVNC_DIR" ]; then
  # Add 'selected' to remote resize option
  sudo sed -i 's|value="remote">|value="remote" selected>|g' "$NOVNC_DIR/vnc.html" 2>/dev/null || true
fi

echo "=== Creating Ghidra launcher ==="
cat << 'EOF' | sudo tee /usr/local/bin/ghidra > /dev/null
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
exec /opt/ghidra/ghidraRun "$@"
EOF
sudo chmod +x /usr/local/bin/ghidra

echo "=== Setting environment ==="
cat >> "$HOME/.bashrc" << 'EOF'
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
export BROWSER=epiphany
export EDITOR=geany

# Desktop URL
if [ -n "$CODESPACE_NAME" ]; then
  echo "Desktop: https://${CODESPACE_NAME}-6080.app.github.dev (password: pwn)"
fi
EOF

echo "=== Building test binary ==="
mkdir -p "$HOME/test"
if [ -f "$REPO_DIR/test/vuln.c" ]; then
  gcc -fno-stack-protector -no-pie -g -o "$HOME/test/vuln" "$REPO_DIR/test/vuln.c"
  chmod +x "$HOME/test/vuln"
  echo "Test binary: ~/test/vuln"
fi

echo "=== Smoke test ==="
gdb --version | head -1
python3 -c "from pwn import *; print('pwntools OK')"
which one_gadget && echo "one_gadget OK"
which ropper && echo "ropper OK"
which ROPgadget && echo "ROPgadget OK"
[ -f /opt/ghidra/ghidraRun ] && echo "Ghidra OK"
[ -f /usr/local/bin/gdb-vanilla ] && echo "gdb-vanilla OK"

echo "=== Setup complete ==="
echo "Desktop: port 6080 (password: pwn)"
echo "Ghidra: 'ghidra' command or menu"
echo "GDB: pwndbg in terminal, vanilla in Ghidra debugger"
