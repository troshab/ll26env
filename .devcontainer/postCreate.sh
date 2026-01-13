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

echo "=== Installing Dracula theme for Fluxbox ==="
mkdir -p "$HOME/.fluxbox/styles"
git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox
cp -r /tmp/dracula-fluxbox/dracula "$HOME/.fluxbox/styles/"
rm -rf /tmp/dracula-fluxbox
# Set Dracula as default style
echo "session.styleFile: $HOME/.fluxbox/styles/dracula" >> "$HOME/.fluxbox/init"

echo "=== Installing Dracula theme for Qt5 (Falkon) ==="
mkdir -p "$HOME/.config/qt5ct/colors"
git clone --depth=1 https://github.com/dracula/qt5.git /tmp/dracula-qt5
cp /tmp/dracula-qt5/Dracula.conf "$HOME/.config/qt5ct/colors/"
rm -rf /tmp/dracula-qt5

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
echo "JAVA_HOME=$JAVA_HOME"

echo "=== Setup complete ==="
echo "Desktop: open localhost:6080 in browser (password: pwn)"
echo "Ghidra: run 'ghidra' command"
