# ll26env

PWN lab environment for Linux binary exploitation.

> **Tip:** Extend idle timeout to 4 hours in [GitHub Settings → Codespaces](https://github.com/settings/codespaces) to prevent auto-sleep.

## Quick Start

1. Click the button below:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new/troshab/ll26env?quickstart=1)

2. Wait for setup (~2 min with prebuilds)

3. VNC Desktop: Ports tab → click globe icon on port 6080

4. Right-click on desktop for application menu (Ghidra, terminal, etc.)

## Desktop Access

### VS Code Desktop (recommended)

Best experience - local IDE with Codespaces compute:

1. Install [VS Code](https://code.visualstudio.com/) + [GitHub Codespaces extension](https://marketplace.visualstudio.com/items?itemName=GitHub.codespaces)
2. `Ctrl+Shift+P` → **"Codespaces: Connect to Codespace"**
3. Ports automatically forwarded to localhost
4. Open VNC: Ports tab → 🌐 on port **6080**

### Browser (noVNC)

Zero setup - works directly in browser without local VS Code:

1. Open **Ports** tab in VS Code (web)
2. Click 🌐 on port **6080**
3. Click **Connect**

### SSH + Native VNC

Full SSH access + smoother graphics for Ghidra:

```bash
# Local terminal (requires GitHub CLI)
gh codespace ssh -- -L 5901:localhost:5901
```

This gives you:
- **SSH shell** in the terminal
- **Port 5901** forwarded to localhost

Connect VNC client ([TigerVNC](https://tigervnc.org/) / [RealVNC](https://www.realvnc.com/en/connect/download/viewer/)) to `localhost:5901`

> **RealVNC color fix:** Properties → Expert → ColorLevel = `full`

## Tools

- **Debuggers:** gdb, pwndbg, pwntools, libc6-dbg
- **Disassemblers:** Ghidra, binutils (objdump, readelf, nm, strings)
- **ROP:** one_gadget, ropper, ROPgadget
- **Build:** gcc, make, nasm, cmake
- **Utils:** strace, ltrace, xxd, file, patchelf
