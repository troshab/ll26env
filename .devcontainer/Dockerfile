FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set JAVA_HOME for Ghidra
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    libc6-dbg \
    xxd \
    mailcap \
    midori \
    && rm -rf /var/lib/apt/lists/*

# Install Python tools
RUN python3 -m pip install --break-system-packages --upgrade pip && \
    python3 -m pip install --break-system-packages --upgrade \
    pwntools \
    ropper \
    ROPgadget \
    capstone \
    unicorn \
    keystone-engine

# Install Ruby gems
RUN gem install one_gadget

# Install Ghidra
ARG GHIDRA_VERSION=11.2.1
ARG GHIDRA_DATE=20241105
RUN wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" -O /tmp/ghidra.zip && \
    unzip -q /tmp/ghidra.zip -d /opt/ && \
    mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra && \
    rm /tmp/ghidra.zip && \
    ln -sf /opt/ghidra/ghidraRun /usr/local/bin/ghidra
