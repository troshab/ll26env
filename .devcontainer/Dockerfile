# Base image for ll26env PWN lab
# Built by GitHub Actions, pushed to ghcr.io/troshab/ll26env

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ make cmake \
    python3 python3-pip python3-venv python3-dev \
    gdb gdbserver \
    file binutils xxd checksec \
    xz-utils unzip \
    patchelf socat netcat-openbsd \
    ruby ruby-dev \
    openjdk-21-jdk \
    nasm ltrace strace \
    libc6-dbg mailcap \
    rxvt-unicode wmctrl xclip \
    && rm -rf /var/lib/apt/lists/*

# Python tools
RUN python3 -m pip install --break-system-packages \
    pwntools ropper ROPgadget capstone unicorn keystone-engine protobuf

# Ruby tools
RUN gem install one_gadget

# Ghidra 12.0
ARG GHIDRA_VERSION=12.0
ARG GHIDRA_DATE=20251205
RUN wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" -O /tmp/ghidra.zip && \
    unzip -q /tmp/ghidra.zip -d /opt/ && \
    mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra && \
    rm /tmp/ghidra.zip

# gdb-vanilla for Ghidra debugger
RUN echo '#!/bin/bash\nexec /usr/bin/gdb --nx "$@"' > /usr/local/bin/gdb-vanilla && \
    chmod +x /usr/local/bin/gdb-vanilla

# Ghidra launcher
RUN echo '#!/bin/bash\nexport JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64\nexport PATH="$JAVA_HOME/bin:$PATH"\nexec /opt/ghidra/ghidraRun "$@"' > /usr/local/bin/ghidra && \
    chmod +x /usr/local/bin/ghidra

# Fluxbox Dracula theme (to /opt, will be copied to $HOME in user-setup)
RUN git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox && \
    mkdir -p /opt/themes/fluxbox && \
    cp -r /tmp/dracula-fluxbox/dracula /opt/themes/fluxbox/ && \
    rm -rf /tmp/dracula-fluxbox

# pwndbg
RUN git clone --depth=1 https://github.com/pwndbg/pwndbg.git /opt/pwndbg && \
    cd /opt/pwndbg && \
    ./setup.sh && \
    pip install --break-system-packages uv && \
    uv sync
