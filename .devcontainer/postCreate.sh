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
# Set Dracula as default style (replace, not append)
sed -i '/session.styleFile/d' "$HOME/.fluxbox/init" 2>/dev/null || true
echo "session.styleFile: $HOME/.fluxbox/styles/dracula" >> "$HOME/.fluxbox/init"

echo "=== Configuring Fluxbox startup ==="
mkdir -p "$HOME/.fluxbox"
cat >> "$HOME/.fluxbox/startup" << 'EOF'
# Clipboard sync for VNC
autocutsel -fork
autocutsel -selection PRIMARY -fork
# Hide VNC config window
pkill vncconfig 2>/dev/null || true
EOF

echo "=== Patching noVNC for remote resize ==="
NOVNC_HTML=$(find /usr -name "vnc.html" 2>/dev/null | head -1)
if [ -f "$NOVNC_HTML" ]; then
  sudo sed -i "s/resize: 'off'/resize: 'remote'/g" "$NOVNC_HTML" || true
fi

echo "=== Installing Dracula GTK theme ==="
mkdir -p "$HOME/.themes"
git clone --depth=1 https://github.com/dracula/gtk.git "$HOME/.themes/Dracula"
mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Dracula
gtk-icon-theme-name=Dracula
gtk-application-prefer-dark-theme=1
EOF

echo "=== Installing Dracula theme for Tilix ==="
mkdir -p "$HOME/.config/tilix/schemes"
curl -fsSL -o "$HOME/.config/tilix/schemes/Dracula.json" \
  https://raw.githubusercontent.com/dracula/tilix/master/Dracula.json

echo "=== Creating Ghidra wrapper (JDK fix) ==="
cat << 'EOF' | sudo tee /usr/local/bin/ghidra > /dev/null
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
/opt/ghidra/ghidraRun "$@"
EOF
sudo chmod +x /usr/local/bin/ghidra

echo "=== Adding desktop URL to bashrc ==="
cat >> "$HOME/.bashrc" << 'BASHRC'

# Desktop URL
if [ -n "$CODESPACE_NAME" ]; then
  echo "🖥️  Desktop: https://${CODESPACE_NAME}-6080.app.github.dev (password: pwn)"
fi
BASHRC

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
