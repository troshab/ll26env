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
cat > "$HOME/.gdbinit" << 'GDBINIT'
python
import sys
import os

def should_load_pwndbg():
    # Skip if stdin OR stdout is not a tty (MI mode, IDE integration)
    if not sys.stdin.isatty() or not sys.stdout.isatty():
        return False
    # Skip if running with -i mi flag (explicit MI mode)
    if any('mi' in arg for arg in sys.argv):
        return False
    return True

if should_load_pwndbg():
    pwndbg_path = os.path.expanduser("~/pwndbg/gdbinit.py")
    if os.path.exists(pwndbg_path):
        gdb.execute(f"source {pwndbg_path}")
end
GDBINIT

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

# Add clipboard sync to startup
cat >> "$HOME/.fluxbox/startup" << 'EOF'
# Clipboard sync for VNC
autocutsel -fork
autocutsel -selection PRIMARY -fork
EOF

# Restart Fluxbox to apply theme
fluxbox-remote restart 2>/dev/null || true

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
GHIDRA_USER_DIR="$HOME/.ghidra/.ghidra_11.2.1_PUBLIC"
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

# Patch noVNC for remote resize default
NOVNC_DIR="/usr/local/novnc/noVNC-1.6.0"
if [ -d "$NOVNC_DIR" ]; then
  # Debug: show current value
  echo "Current resize option:"
  grep -o 'value="remote"[^>]*>' "$NOVNC_DIR/vnc.html" | head -1 || true

  # More robust sed - match any variation
  sudo sed -i 's|value="remote"|value="remote" selected|g' "$NOVNC_DIR/vnc.html" 2>/dev/null || true

  # Remove duplicate selected if any
  sudo sed -i 's|selected selected|selected|g' "$NOVNC_DIR/vnc.html" 2>/dev/null || true

  echo "After patch:"
  grep -o 'value="remote"[^>]*>' "$NOVNC_DIR/vnc.html" | head -1 || true
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
# BUILD EXAMPLES
# =====================================================
echo "=== Building examples ==="
mkdir -p "$HOME/examples"

# C example
if [ -f "$REPO_DIR/example_c/vuln.c" ]; then
  gcc -fno-stack-protector -no-pie -g -o "$HOME/examples/vuln" "$REPO_DIR/example_c/vuln.c"
  echo "C example: ~/examples/vuln"
fi

# ASM example
if [ -f "$REPO_DIR/example_asm/hello.asm" ]; then
  nasm -f elf64 -o /tmp/hello.o "$REPO_DIR/example_asm/hello.asm"
  ld -o "$HOME/examples/hello" /tmp/hello.o
  echo "ASM example: ~/examples/hello"
fi

# Shellcode tester
if [ -f "$REPO_DIR/example_shellcode/test_shellcode.c" ]; then
  gcc -z execstack -fno-stack-protector -o "$HOME/examples/test_shellcode" "$REPO_DIR/example_shellcode/test_shellcode.c"
  echo "Shellcode tester: ~/examples/test_shellcode"
fi

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
