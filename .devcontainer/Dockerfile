FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV GTK_THEME=Dracula

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

# Python tools
RUN python3 -m pip install --break-system-packages \
    pwntools ropper ROPgadget capstone unicorn keystone-engine

# Ruby gems
RUN gem install one_gadget

# Ghidra
ARG GHIDRA_VERSION=11.2.1
ARG GHIDRA_DATE=20241105
RUN wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" -O /tmp/ghidra.zip && \
    unzip -q /tmp/ghidra.zip -d /opt/ && \
    mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra && \
    rm /tmp/ghidra.zip

# Fluxbox Dracula style (must be before desktop-lite starts Fluxbox)
RUN mkdir -p /home/vscode/.fluxbox/styles && \
    git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox && \
    cp -r /tmp/dracula-fluxbox/dracula /home/vscode/.fluxbox/styles/ && \
    rm -rf /tmp/dracula-fluxbox && \
    chown -R 1000:1000 /home/vscode/.fluxbox
