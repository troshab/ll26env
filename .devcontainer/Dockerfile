FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV GTK_THEME=Dracula
ENV GDK_SCALE=1
ENV GDK_DPI_SCALE=1

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget ca-certificates \
    build-essential gcc g++ make cmake \
    python3 python3-pip python3-venv python3-dev \
    gdb gdbserver \
    file binutils \
    xz-utils unzip \
    patchelf socat netcat-openbsd \
    ruby ruby-dev \
    openjdk-21-jdk \
    nasm ltrace strace \
    libc6-dbg xxd mailcap \
    epiphany-browser tilix dconf-cli autocutsel geany wmctrl \
    && rm -rf /var/lib/apt/lists/*

# Python tools (latest versions as of Jan 2026)
# pwntools 4.15.0, ropper 1.13.13, ROPgadget 7.7
RUN python3 -m pip install --break-system-packages \
    pwntools ropper ROPgadget capstone unicorn keystone-engine protobuf

# Ruby gems (one_gadget 1.10.0)
RUN gem install one_gadget

# Ghidra 12.0 (released Dec 5, 2025)
ARG GHIDRA_VERSION=12.0
ARG GHIDRA_DATE=20251205
RUN wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" -O /tmp/ghidra.zip && \
    unzip -q /tmp/ghidra.zip -d /opt/ && \
    mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra && \
    rm /tmp/ghidra.zip

# gdb-vanilla for Ghidra debugger (without pwndbg)
RUN echo '#!/bin/bash' > /usr/local/bin/gdb-vanilla && \
    echo 'exec /usr/bin/gdb --nx "$@"' >> /usr/local/bin/gdb-vanilla && \
    chmod +x /usr/local/bin/gdb-vanilla

# =====================================================
# DOWNLOAD THEMES TO /opt (survives feature installation)
# postCreate.sh will copy to /home/vscode
# =====================================================

# Fluxbox Dracula theme
RUN mkdir -p /opt/themes/fluxbox && \
    git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox && \
    cp -r /tmp/dracula-fluxbox/dracula /opt/themes/fluxbox/ && \
    rm -rf /tmp/dracula-fluxbox

# GTK Dracula theme
RUN git clone --depth=1 https://github.com/dracula/gtk.git /opt/themes/Dracula

# Geany Dracula colorscheme
RUN mkdir -p /opt/themes/geany && \
    curl -fsSL -o /opt/themes/geany/Dracula-Theme.conf \
    https://raw.githubusercontent.com/dracula/geany/master/Dracula-Theme.conf

# Tilix Dracula scheme
RUN mkdir -p /opt/themes/tilix && \
    curl -fsSL -o /opt/themes/tilix/Dracula.json \
    https://raw.githubusercontent.com/dracula/tilix/master/Dracula.json
