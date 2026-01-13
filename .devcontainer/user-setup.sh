#!/usr/bin/env bash
# Minimal user setup - runs after image pull and features install
# Heavy stuff (apt, pip, ghidra) is already in the Docker image

set -euo pipefail

REPO_DIR="/workspaces/ll26env"
CONFIG_DIR="$REPO_DIR/.devcontainer"

# =====================================================
# PWNDBG (needs $HOME)
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
# PTRACE (runtime setting)
# =====================================================
echo "=== Configuring ptrace ==="
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null || true

# =====================================================
# FLUXBOX (needs $HOME)
# =====================================================
echo "=== Configuring Fluxbox ==="
mkdir -p "$HOME/.fluxbox/styles"

# Copy Dracula theme from image
if [ -d /opt/themes/fluxbox/dracula ]; then
    cp -r /opt/themes/fluxbox/dracula "$HOME/.fluxbox/styles/"
fi

# Config files
cp "$CONFIG_DIR/fluxbox/init" "$HOME/.fluxbox/init"
cp "$CONFIG_DIR/fluxbox/menu" "$HOME/.fluxbox/menu"
cp "$CONFIG_DIR/fluxbox/apps" "$HOME/.fluxbox/apps"

# Kill vncconfig on startup
if [ -f "$HOME/.fluxbox/startup" ] && ! grep -q "pkill -f vncconfig" "$HOME/.fluxbox/startup"; then
    echo 'pkill -f vncconfig &' >> "$HOME/.fluxbox/startup"
fi

# Restart Fluxbox
pkill fluxbox || true
sleep 1
nohup fluxbox > /dev/null 2>&1 &

# =====================================================
# URXVT (needs $HOME)
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
# GHIDRA CONFIG (needs $HOME)
# =====================================================
echo "=== Configuring Ghidra ==="
GHIDRA_USER_DIR="$HOME/.ghidra/.ghidra_12.0_PUBLIC"
mkdir -p "$GHIDRA_USER_DIR/themes"

# Symlinks for libc import
mkdir -p "$HOME/ghidra-libs"
ln -sf /lib/x86_64-linux-gnu/libc.so.6 "$HOME/ghidra-libs/"
ln -sf /lib64/ld-linux-x86-64.so.2 "$HOME/ghidra-libs/"

cp "$CONFIG_DIR/ghidra/Dracula.theme" "$GHIDRA_USER_DIR/themes/"
cat > "$GHIDRA_USER_DIR/preferences" << 'EOF'
Theme=Dracula
SHOW_TIPS=false
EOF

# =====================================================
# NOVNC PATCHES (installed by feature, must patch after)
# =====================================================
echo "=== Patching noVNC ==="
NOVNC_DIR="/usr/local/novnc/noVNC-1.6.0"
if [ -d "$NOVNC_DIR" ]; then
    sudo sed -i "s|UI.initSetting('resize', 'off')|UI.initSetting('resize', 'remote')|" "$NOVNC_DIR/app/ui.js" 2>/dev/null || true
    sudo sed -i 's|input:not(\[type=checkbox\]):not(\[type=radio\])|input:not([type=checkbox]):not([type=radio]):not([type=image])|g' "$NOVNC_DIR/app/styles/base.css" 2>/dev/null || true
fi

# =====================================================
# BASHRC (needs $HOME)
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
# EXAMPLES (needs $HOME)
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
