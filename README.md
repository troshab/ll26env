# ll26env

PWN lab environment for Linux binary exploitation.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new/troshab/ll26env?quickstart=1)

## Quick Start

1. Fork this repo
2. Open in Codespaces: Code → Codespaces → Create codespace
3. Wait for setup to complete (~5-10 min first time)

## Desktop Access

### Browser (noVNC) - Recommended
Open `https://<codespace-name>-6080.app.github.dev`, password: `pwn`

Right-click on desktop for application menu.

### Native VNC Client
**Note:** VNC port 5901 requires VS Code Desktop (not browser). Codespaces web port forwarding only supports HTTP(S).

1. Open in VS Code Desktop (not browser)
2. Ports tab → 5901 should be forwarded to localhost:5901
3. Connect with any VNC client to `localhost:5901`
4. Password: `pwn`

## Tools

- **Debuggers:** gdb, pwndbg, pwntools (checksec), libc6-dbg
- **Disassemblers:** Ghidra, binutils (objdump, readelf, nm, strings, objcopy)
- **ROP:** one_gadget, ropper, ROPgadget
- **Build:** gcc, make, nasm, cmake
- **Utils:** strace, ltrace, xxd, file, patchelf
- **GUI:** Tilix terminal, Geany editor, Epiphany browser, Nautilus file manager

## Ghidra

Run from terminal: `ghidra`

Or use right-click menu → Ghidra

## Homework

Put your solutions in `hw1/` - `hw10/` folders.
