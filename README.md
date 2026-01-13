# ll26env

PWN lab environment for Linux binary exploitation.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new/troshab/ll26env?quickstart=1)

## Quick Start

1. Fork this repo
2. Open in Codespaces: Code → Codespaces → Create codespace
3. Wait for setup to complete (~5-10 min first time)

## Desktop Access

### Browser (noVNC)
Open `https://<codespace-name>-6080.app.github.dev`, password: `pwn`

### Native VNC Client (recommended)
For full keyboard support (Ctrl+W, etc.):
1. Ports tab → 5901 → Make Public
2. Connect with any VNC client:
   - **TigerVNC:** `vncviewer <codespace-name>-5901.app.github.dev`
   - **RealVNC, Remmina, etc.**
3. Password: `pwn`

## Tools

- gdb, pwndbg, pwntools (checksec), libc6-dbg
- Ghidra, Epiphany browser
- one_gadget, ropper, ROPgadget
- gcc, make, nasm, binutils (objdump, readelf, nm, strings, objcopy)
- strace, ltrace, xxd, file, tilix

## Homework

Put your solutions in `hw1/` - `hw10/` folders.
