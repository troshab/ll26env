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

echo "=== Configuring ptrace ==="
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null || true

echo "=== Installing Dracula themes ==="
# Fluxbox Dracula style
mkdir -p "$HOME/.fluxbox/styles"
git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox
cp -r /tmp/dracula-fluxbox/dracula "$HOME/.fluxbox/styles/"
rm -rf /tmp/dracula-fluxbox

# GTK Dracula theme
mkdir -p "$HOME/.themes"
git clone --depth=1 https://github.com/dracula/gtk.git "$HOME/.themes/Dracula"

# Geany Dracula
mkdir -p "$HOME/.config/geany/colorschemes"
curl -fsSL -o "$HOME/.config/geany/colorschemes/Dracula-Theme.conf" \
  https://raw.githubusercontent.com/dracula/geany/master/Dracula-Theme.conf
echo -e "[geany]\ncolor_scheme=Dracula-Theme.conf" > "$HOME/.config/geany/geany.conf"

# Tilix Dracula
mkdir -p "$HOME/.config/tilix/schemes"
curl -fsSL -o "$HOME/.config/tilix/schemes/Dracula.json" \
  https://raw.githubusercontent.com/dracula/tilix/master/Dracula.json

echo "=== Copying Fluxbox config ==="
cp "$CONFIG_DIR/fluxbox/init" "$HOME/.fluxbox/init"
cp "$CONFIG_DIR/fluxbox/menu" "$HOME/.fluxbox/menu"
cp "$CONFIG_DIR/fluxbox/apps" "$HOME/.fluxbox/apps"

echo "=== Copying GTK config ==="
cp "$CONFIG_DIR/gtk/gtkrc-2.0" "$HOME/.gtkrc-2.0"
mkdir -p "$HOME/.config/gtk-3.0"
cp "$CONFIG_DIR/gtk/gtk-3.0-settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
mkdir -p "$HOME/.config/gtk-4.0"
cp "$CONFIG_DIR/gtk/gtk-4.0-settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

echo "=== Setting default applications ==="
mkdir -p "$HOME/.config"
cat > "$HOME/.config/mimeapps.list" << 'EOF'
[Default Applications]
text/html=org.gnome.Epiphany.desktop
x-scheme-handler/http=org.gnome.Epiphany.desktop
x-scheme-handler/https=org.gnome.Epiphany.desktop
text/plain=geany.desktop
text/x-csrc=geany.desktop
text/x-python=geany.desktop
EOF

echo "=== Configuring Fluxbox startup ==="
cat >> "$HOME/.fluxbox/startup" << 'EOF'
# Clipboard sync for VNC
autocutsel -fork
autocutsel -selection PRIMARY -fork
EOF

echo "=== Restarting Fluxbox to apply config ==="
fluxbox-remote restart || true

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
gcc -fno-stack-protector -no-pie -g -o "$HOME/test/vuln" "$REPO_DIR/test/vuln.c"
chmod +x "$HOME/test/vuln"

echo "=== Smoke test ==="
gdb --version | head -1
python3 -c "from pwn import *; print('pwntools OK')"
which one_gadget && echo "one_gadget OK"
which ropper && echo "ropper OK"
which ROPgadget && echo "ROPgadget OK"
[ -f /opt/ghidra/ghidraRun ] && echo "Ghidra OK"

echo "=== Setup complete ==="
echo "Desktop: open the 6080 port in browser (password: pwn)"
echo "Right-click for menu. Ghidra: 'ghidra' command or menu."
