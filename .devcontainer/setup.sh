#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/workspaces/ll26env"
CONFIG_DIR="$REPO_DIR/.devcontainer"

# =====================================================
# SYSTEM PACKAGES (need sudo)
# =====================================================
echo "=== Installing system packages ==="
sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    build-essential gcc g++ make cmake \
    python3-pip python3-dev \
    gdb gdbserver \
    file binutils xxd \
    xz-utils unzip \
    patchelf socat netcat-openbsd \
    ruby ruby-dev \
    openjdk-21-jdk \
    nasm ltrace strace \
    libc6-dbg mailcap \
    rxvt-unicode wmctrl xclip

sudo rm -rf /var/lib/apt/lists/*

# =====================================================
# PYTHON TOOLS
# =====================================================
echo "=== Installing Python tools ==="
python3 -m pip install --break-system-packages \
    pwntools ropper ROPgadget capstone unicorn keystone-engine protobuf

# =====================================================
# RUBY TOOLS
# =====================================================
echo "=== Installing Ruby tools ==="
sudo gem install one_gadget

# =====================================================
# GHIDRA
# =====================================================
echo "=== Installing Ghidra ==="
GHIDRA_VERSION="12.0"
GHIDRA_DATE="20251205"
if [ ! -d /opt/ghidra ]; then
    sudo wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" -O /tmp/ghidra.zip
    sudo unzip -q /tmp/ghidra.zip -d /opt/
    sudo mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra
    sudo rm /tmp/ghidra.zip
fi

# gdb-vanilla for Ghidra debugger
sudo tee /usr/local/bin/gdb-vanilla > /dev/null << 'EOF'
#!/bin/bash
exec /usr/bin/gdb --nx "$@"
EOF
sudo chmod +x /usr/local/bin/gdb-vanilla

# Ghidra launcher
sudo tee /usr/local/bin/ghidra > /dev/null << 'EOF'
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
exec /opt/ghidra/ghidraRun "$@"
EOF
sudo chmod +x /usr/local/bin/ghidra

# =====================================================
# PWNDBG
# =====================================================
echo "=== Installing pwndbg ==="
if [ ! -d "$HOME/pwndbg" ]; then
    git clone --depth=1 https://github.com/pwndbg/pwndbg.git "$HOME/pwndbg"
fi
cd "$HOME/pwndbg" && ./setup.sh

# GDB config with MI detection
cat > "$HOME/.gdbinit" << 'EOF'
python
import sys, os
if sys.stdin.isatty() and not any('mi' in a.lower() for a in sys.argv):
    p = os.path.expanduser("~/pwndbg/gdbinit.py")
    if os.path.exists(p): gdb.execute(f"source {p}")
end
EOF

# =====================================================
# PTRACE
# =====================================================
echo "=== Configuring ptrace ==="
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null || true

# =====================================================
# FLUXBOX
# =====================================================
echo "=== Configuring Fluxbox ==="
mkdir -p "$HOME/.fluxbox/styles"

# Dracula theme
git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox
cp -r /tmp/dracula-fluxbox/dracula "$HOME/.fluxbox/styles/"
rm -rf /tmp/dracula-fluxbox

# Config files
cp "$CONFIG_DIR/fluxbox/init" "$HOME/.fluxbox/init"
cp "$CONFIG_DIR/fluxbox/menu" "$HOME/.fluxbox/menu"
cp "$CONFIG_DIR/fluxbox/apps" "$HOME/.fluxbox/apps"

# Kill vncconfig on startup (idempotent)
if [ -f "$HOME/.fluxbox/startup" ] && ! grep -q "pkill -f vncconfig" "$HOME/.fluxbox/startup"; then
    echo 'pkill -f vncconfig &' >> "$HOME/.fluxbox/startup"
fi

# Restart Fluxbox
pkill fluxbox || true
sleep 1
nohup fluxbox > /dev/null 2>&1 &

# =====================================================
# URXVT (Dracula)
# =====================================================
echo "=== Configuring urxvt ==="
cat > "$HOME/.Xresources" << 'EOF'
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

# System libraries for Ghidra import (symlinks)
mkdir -p "$HOME/ghidra-libs"
ln -sf /lib/x86_64-linux-gnu/libc.so.6 "$HOME/ghidra-libs/"
ln -sf /lib64/ld-linux-x86-64.so.2 "$HOME/ghidra-libs/"
cp "$CONFIG_DIR/ghidra/Dracula.theme" "$GHIDRA_USER_DIR/themes/"
cat > "$GHIDRA_USER_DIR/preferences" << 'EOF'
Theme=Dracula
SHOW_TIPS=false
EOF

# =====================================================
# NOVNC PATCHES
# =====================================================
echo "=== Patching noVNC ==="
NOVNC_DIR="/usr/local/novnc/noVNC-1.6.0"
if [ -d "$NOVNC_DIR" ]; then
    sudo sed -i "s|UI.initSetting('resize', 'off')|UI.initSetting('resize', 'remote')|" "$NOVNC_DIR/app/ui.js" 2>/dev/null || true
    sudo sed -i 's|input:not(\[type=checkbox\]):not(\[type=radio\])|input:not([type=checkbox]):not([type=radio]):not([type=image])|g' "$NOVNC_DIR/app/styles/base.css" 2>/dev/null || true
fi

# =====================================================
# BASHRC
# =====================================================
echo "=== Configuring environment ==="
if ! grep -q "JAVA_HOME=/usr/lib/jvm/java-21" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" << 'EOF'

export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

if [ -n "$CODESPACE_NAME" ]; then
    echo "Desktop: https://${CODESPACE_NAME}-6080.app.github.dev (password: pwn)"
fi
EOF
fi

# =====================================================
# EXAMPLES
# =====================================================
echo "=== Copying examples ==="
cp -r "$REPO_DIR/example_c" "$HOME/"
cp -r "$REPO_DIR/example_asm" "$HOME/"
cp -r "$REPO_DIR/example_shellcode" "$HOME/"
chmod +x "$HOME"/example_*/build.sh

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

echo "=== Setup complete ==="
echo "Desktop: port 6080 (password: pwn)"
