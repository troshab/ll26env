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

# Add clipboard sync and kill vncconfig to startup
cat >> "$HOME/.fluxbox/startup" << 'EOF'
# Clipboard sync for VNC
autocutsel -fork
autocutsel -selection PRIMARY -fork
# Kill annoying vncconfig window
pkill -f vncconfig &
EOF

# Restart Fluxbox completely to apply theme (fluxbox-remote restart doesn't reload config)
pkill fluxbox || true
sleep 1
nohup fluxbox > /dev/null 2>&1 &

# =====================================================
# GTK THEMES
# =====================================================
echo "=== Configuring GTK themes ==="

# Copy GTK theme
mkdir -p "$HOME/.themes"
if [ -d /opt/themes/Dracula ]; then
  cp -r /opt/themes/Dracula "$HOME/.themes/"
fi

# GTK2
cat > "$HOME/.gtkrc-2.0" << 'EOF'
gtk-theme-name="Dracula"
gtk-icon-theme-name="Dracula"
EOF

# GTK3
mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Dracula
gtk-icon-theme-name=Dracula
gtk-application-prefer-dark-theme=1
EOF

# GTK4
mkdir -p "$HOME/.config/gtk-4.0"
cat > "$HOME/.config/gtk-4.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Dracula
gtk-icon-theme-name=Dracula
gtk-application-prefer-dark-theme=1
EOF

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
# APPLICATION CONFIG
# =====================================================
echo "=== Configuring applications ==="

# Geany
mkdir -p "$HOME/.config/geany/colorschemes"
if [ -f /opt/themes/geany/Dracula-Theme.conf ]; then
  cp /opt/themes/geany/Dracula-Theme.conf "$HOME/.config/geany/colorschemes/"
fi
cat > "$HOME/.config/geany/geany.conf" << 'EOF'
[geany]
color_scheme=Dracula-Theme.conf
EOF

# Tilix
mkdir -p "$HOME/.config/tilix/schemes"
if [ -f /opt/themes/tilix/Dracula.json ]; then
  cp /opt/themes/tilix/Dracula.json "$HOME/.config/tilix/schemes/"
fi

# Default applications
cat > "$HOME/.config/mimeapps.list" << 'EOF'
[Default Applications]
text/html=org.gnome.Epiphany.desktop
x-scheme-handler/http=org.gnome.Epiphany.desktop
x-scheme-handler/https=org.gnome.Epiphany.desktop
text/plain=geany.desktop
text/x-csrc=geany.desktop
text/x-python=geany.desktop
EOF

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
export BROWSER=epiphany
export EDITOR=geany

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
[ -d "$HOME/.themes/Dracula" ] && echo "GTK Dracula OK"

echo "=== Setup complete ==="
echo "Desktop: port 6080 (password: pwn)"
echo "Ghidra: 'ghidra' command or menu"
echo "GDB: pwndbg in terminal, vanilla in Ghidra debugger (use gdb-vanilla)"
