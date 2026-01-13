#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing system packages ==="
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  git curl wget ca-certificates \
  build-essential gcc g++ make cmake \
  python3 python3-pip python3-venv python3-dev \
  gdb gdbserver \
  file binutils \
  xz-utils unzip \
  patchelf \
  socat \
  netcat-openbsd \
  ruby ruby-dev \
  openjdk-17-jdk \
  nasm \
  ltrace strace \
  libc6-dbg

echo "=== Installing Python tools ==="
python3 -m pip install --break-system-packages --upgrade pip
python3 -m pip install --break-system-packages --upgrade \
  pwntools \
  ropper \
  capstone \
  unicorn \
  keystone-engine

echo "=== Installing pwndbg ==="
if [ ! -d "$HOME/pwndbg" ]; then
  git clone --depth=1 https://github.com/pwndbg/pwndbg.git "$HOME/pwndbg"
fi
cd "$HOME/pwndbg"
./setup.sh

echo "=== Installing one_gadget ==="
sudo gem install one_gadget

echo "=== Installing seccomp-tools ==="
sudo gem install seccomp-tools

echo "=== Installing radare2 ==="
if [ ! -d "$HOME/radare2" ]; then
  git clone --depth=1 https://github.com/radareorg/radare2.git "$HOME/radare2"
fi
cd "$HOME/radare2"
sys/install.sh

echo "=== Installing Ghidra ==="
GHIDRA_VERSION="11.2.1"
GHIDRA_DATE="20241105"
GHIDRA_URL="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip"
if [ ! -d "/opt/ghidra" ]; then
  wget -q "$GHIDRA_URL" -O /tmp/ghidra.zip
  sudo unzip -q /tmp/ghidra.zip -d /opt/
  sudo mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra
  rm /tmp/ghidra.zip
  sudo ln -sf /opt/ghidra/ghidraRun /usr/local/bin/ghidra
fi

echo "=== Configuring ptrace ==="
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null || true

echo "=== Smoke test ==="
gdb --version | head -1
python3 -c "from pwn import *; print('pwntools OK')"
which one_gadget && echo "one_gadget OK"
which seccomp-tools && echo "seccomp-tools OK"
which r2 && echo "radare2 OK"
[ -f /opt/ghidra/ghidraRun ] && echo "Ghidra OK"

echo "=== Setup complete ==="
echo "Desktop: open localhost:6080 in browser (password: pwn)"
echo "Ghidra: run 'ghidra' command"
