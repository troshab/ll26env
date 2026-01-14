# ll26env

PWN lab environment for Linux binary exploitation.

> **Tip:** Extend idle timeout to 4 hours in [GitHub Settings → Codespaces](https://github.com/settings/codespaces) to prevent auto-sleep.

## How To Run Environment

1. Click the button below:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new/troshab/ll26env?quickstart=1)

2. Wait for setup (~2 min with prebuilds)

3. Wait for **"ENVIRONMENT IS READY"** message in terminal

## How To Work In Environment

### Local (recommended)

Better performance with local software:

**VS Code Desktop:**
1. Install [VS Code](https://code.visualstudio.com/) + [GitHub Codespaces extension](https://marketplace.visualstudio.com/items?itemName=GitHub.codespaces)
2. `Ctrl+Shift+P` → **"Codespaces: Connect to Codespace"**

**SSH tunnel (alternative):**
```bash
gh codespace ssh -- -L 5901:localhost:5901
```

Both methods forward ports to localhost. Then connect VNC client to `localhost:5901`:
- [TigerVNC](https://tigervnc.org/) or [RealVNC](https://www.realvnc.com/en/connect/download/viewer/)

> **RealVNC color fix:** Properties → Expert → ColorLevel = `full`

### Remote (browser only)

Zero setup - everything in browser:

1. Copy the desktop link from terminal output (it auto-connects)
2. Or open **Ports** tab in VS Code (bottom panel) → click globe icon on port **6080** → click **Connect**

## Tools

- **Debuggers:** gdb, pwndbg, pwntools, libc6-dbg
- **Disassemblers:** Ghidra, binutils (objdump, readelf, nm, strings)
- **ROP:** one_gadget, ropper, ROPgadget
- **Build:** gcc, g++, make, nasm, cmake
- **Utils:** strace, ltrace, xxd, file, patchelf, checksec, socat, netcat
