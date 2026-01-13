# ll26env

PWN lab environment for Linux binary exploitation.

> **Tip:** Extend idle timeout to 4 hours in [GitHub Settings → Codespaces](https://github.com/settings/codespaces) to prevent auto-sleep.

## Quick Start

1. Click the button below:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new/troshab/ll26env?quickstart=1)

2. Wait for setup (~2 min with prebuilds)

3. VNC Desktop: Ports tab → click globe icon on port 6080. Password: `pwn`

4. Right-click on desktop for application menu (Ghidra, terminal, etc.)

## Tools

- **Debuggers:** gdb, pwndbg, pwntools, libc6-dbg
- **Disassemblers:** Ghidra, binutils (objdump, readelf, nm, strings)
- **ROP:** one_gadget, ropper, ROPgadget
- **Build:** gcc, make, nasm, cmake
- **Utils:** strace, ltrace, xxd, file, patchelf
