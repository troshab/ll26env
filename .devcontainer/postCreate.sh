#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/workspaces/ll26env"
CONFIG_DIR="$REPO_DIR/.devcontainer"

echo "=== Installing pwndbg ==="
if [ ! -d "$HOME/pwndbg" ]; then
  git clone --depth=1 https://github.com/pwndbg/pwndbg.git "$HOME/pwndbg"
fi
cd "$HOME/pwndbg"
./setup.sh

echo "=== Configuring GDB with MI/tty detection ==="
# Create .gdbinit that loads pwndbg only for interactive sessions
# Ghidra debugger uses MI interface - both stdin and stdout are pipes
cat > "$HOME/.gdbinit" << 'EOF'
python
import sys, os
# Load pwndbg only for interactive terminal (not MI mode for Ghidra/IDEs)
if sys.stdin.isatty() and not any('mi' in a.lower() for a in sys.argv):
    p = os.path.expanduser("~/pwndbg/gdbinit.py")
    if os.path.exists(p): gdb.execute(f"source {p}")
end
EOF

echo "=== Configuring ptrace ==="
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null || true

# =====================================================
# FLUXBOX CONFIG
# =====================================================
echo "=== Configuring Fluxbox ==="
mkdir -p "$HOME/.fluxbox/styles"

# Copy Dracula theme
if [ -d /opt/themes/fluxbox/dracula ]; then
  cp -r /opt/themes/fluxbox/dracula "$HOME/.fluxbox/styles/"
fi

# Copy config files from repo
cp "$CONFIG_DIR/fluxbox/init" "$HOME/.fluxbox/init"
cp "$CONFIG_DIR/fluxbox/menu" "$HOME/.fluxbox/menu"
cp "$CONFIG_DIR/fluxbox/apps" "$HOME/.fluxbox/apps"

# Kill vncconfig on startup
cat >> "$HOME/.fluxbox/startup" << 'EOF'
pkill -f vncconfig &
EOF

# Restart Fluxbox completely to apply theme (fluxbox-remote restart doesn't reload config)
pkill fluxbox || true
sleep 1
nohup fluxbox > /dev/null 2>&1 &

# =====================================================
# URXVT CONFIG (Dracula theme)
# =====================================================
echo "=== Configuring urxvt ==="
cat > "$HOME/.Xresources" << 'EOF'
! Dracula theme
URxvt*background: #282a36
URxvt*foreground: #f8f8f2
URxvt*cursorColor: #f8f8f2
URxvt*color0:  #000000
URxvt*color1:  #ff5555
URxvt*color2:  #50fa7b
URxvt*color3:  #f1fa8c
URxvt*color4:  #bd93f9
URxvt*color5:  #ff79c6
URxvt*color6:  #8be9fd
URxvt*color7:  #bfbfbf
URxvt*color8:  #4d4d4d
URxvt*color9:  #ff6e67
URxvt*color10: #5af78e
URxvt*color11: #f4f99d
URxvt*color12: #caa9fa
URxvt*color13: #ff92d0
URxvt*color14: #9aedfe
URxvt*color15: #e6e6e6
! Settings
URxvt*font: xft:DejaVu Sans Mono:size=11
URxvt*scrollBar: false
URxvt*saveLines: 10000
EOF
xrdb -merge "$HOME/.Xresources" 2>/dev/null || true

# =====================================================
# GHIDRA CONFIG
# =====================================================
echo "=== Configuring Ghidra ==="
GHIDRA_USER_DIR="$HOME/.ghidra/.ghidra_12.0_PUBLIC"
mkdir -p "$GHIDRA_USER_DIR/themes"

# Copy Dracula theme
cp "$CONFIG_DIR/ghidra/Dracula.theme" "$GHIDRA_USER_DIR/themes/"

# Set as active theme
cat > "$GHIDRA_USER_DIR/preferences" << 'EOF'
Theme=Dracula
EOF

# Create Ghidra launcher
cat << 'EOF' | sudo tee /usr/local/bin/ghidra > /dev/null
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
exec /opt/ghidra/ghidraRun "$@"
EOF
sudo chmod +x /usr/local/bin/ghidra

# =====================================================
# NOVNC CONFIG
# =====================================================
echo "=== Configuring noVNC ==="
pkill -f "vncconfig" 2>/dev/null || true
pkill -f "tigervncconfig" 2>/dev/null || true

# Patch noVNC
NOVNC_DIR="/usr/local/novnc/noVNC-1.6.0"
if [ -d "$NOVNC_DIR" ]; then
  # Set default resize mode to 'remote'
  sudo sed -i "s|UI.initSetting('resize', 'off')|UI.initSetting('resize', 'remote')|" "$NOVNC_DIR/app/ui.js" 2>/dev/null || true

  # Fix icon buttons visibility (bug fixed in noVNC 1.7.0, we have 1.6.0)
  sudo sed -i 's|input:not(\[type=checkbox\]):not(\[type=radio\])|input:not([type=checkbox]):not([type=radio]):not([type=image])|g' "$NOVNC_DIR/app/styles/base.css" 2>/dev/null || true

  echo "noVNC patched: Remote Resizing default, icon buttons fix"
fi

# =====================================================
# ENVIRONMENT
# =====================================================
echo "=== Setting environment ==="
cat >> "$HOME/.bashrc" << 'EOF'
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

# Desktop URL
if [ -n "$CODESPACE_NAME" ]; then
  echo "Desktop: https://${CODESPACE_NAME}-6080.app.github.dev (password: pwn)"
fi
EOF

# =====================================================
# COPY EXAMPLES
# =====================================================
echo "=== Copying examples ==="

# Copy example folders to home directory
cp -r "$REPO_DIR/example_c" "$HOME/"
cp -r "$REPO_DIR/example_asm" "$HOME/"
cp -r "$REPO_DIR/example_shellcode" "$HOME/"

# Make build scripts executable
chmod +x "$HOME"/example_*/build.sh

echo "Examples copied to ~/"
echo "  ~/example_c/         - C buffer overflow (run ./build.sh)"
echo "  ~/example_asm/       - Assembly hello world (run ./build.sh)"
echo "  ~/example_shellcode/ - Shellcode tester (run ./build.sh)"

# =====================================================
# SMOKE TEST
# =====================================================
echo "=== Smoke test ==="
gdb --version | head -1
python3 -c "from pwn import *; print('pwntools OK')"
which one_gadget && echo "one_gadget OK"
which ropper && echo "ropper OK"
which ROPgadget && echo "ROPgadget OK"
[ -f /opt/ghidra/ghidraRun ] && echo "Ghidra OK"
[ -f /usr/local/bin/gdb-vanilla ] && echo "gdb-vanilla OK"
[ -d "$HOME/.fluxbox/styles/dracula" ] && echo "Fluxbox Dracula OK"
[ -f "$GHIDRA_USER_DIR/themes/Dracula.theme" ] && echo "Ghidra Dracula OK"
[ -f "$HOME/.Xresources" ] && echo "urxvt Dracula OK"

echo "=== Setup complete ==="
echo "Desktop: port 6080 (password: pwn)"
echo "Ghidra: 'ghidra' command or menu"
echo "GDB: pwndbg in terminal, vanilla in Ghidra debugger (use gdb-vanilla)"
