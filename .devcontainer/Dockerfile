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

# gdb-vanilla for Ghidra debugger (without pwndbg)
RUN echo '#!/bin/bash' > /usr/local/bin/gdb-vanilla && \
    echo 'exec /usr/bin/gdb --nx "$@"' >> /usr/local/bin/gdb-vanilla && \
    chmod +x /usr/local/bin/gdb-vanilla

# =====================================================
# FLUXBOX CONFIG (must be before desktop-lite)
# =====================================================
RUN mkdir -p /home/vscode/.fluxbox/styles && \
    git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox && \
    cp -r /tmp/dracula-fluxbox/dracula /home/vscode/.fluxbox/styles/ && \
    rm -rf /tmp/dracula-fluxbox

# Copy fluxbox config from repo
COPY fluxbox/init /home/vscode/.fluxbox/init
COPY fluxbox/menu /home/vscode/.fluxbox/menu
COPY fluxbox/apps /home/vscode/.fluxbox/apps

# =====================================================
# GTK DRACULA THEME
# =====================================================
RUN mkdir -p /home/vscode/.themes && \
    git clone --depth=1 https://github.com/dracula/gtk.git /home/vscode/.themes/Dracula

# GTK2 settings
RUN echo 'gtk-theme-name="Dracula"' > /home/vscode/.gtkrc-2.0 && \
    echo 'gtk-icon-theme-name="Dracula"' >> /home/vscode/.gtkrc-2.0

# GTK3 settings
RUN mkdir -p /home/vscode/.config/gtk-3.0 && \
    echo '[Settings]' > /home/vscode/.config/gtk-3.0/settings.ini && \
    echo 'gtk-theme-name=Dracula' >> /home/vscode/.config/gtk-3.0/settings.ini && \
    echo 'gtk-icon-theme-name=Dracula' >> /home/vscode/.config/gtk-3.0/settings.ini && \
    echo 'gtk-application-prefer-dark-theme=1' >> /home/vscode/.config/gtk-3.0/settings.ini

# GTK4 settings
RUN mkdir -p /home/vscode/.config/gtk-4.0 && \
    echo '[Settings]' > /home/vscode/.config/gtk-4.0/settings.ini && \
    echo 'gtk-theme-name=Dracula' >> /home/vscode/.config/gtk-4.0/settings.ini && \
    echo 'gtk-icon-theme-name=Dracula' >> /home/vscode/.config/gtk-4.0/settings.ini && \
    echo 'gtk-application-prefer-dark-theme=1' >> /home/vscode/.config/gtk-4.0/settings.ini

# =====================================================
# GHIDRA DRACULA THEME
# =====================================================
COPY ghidra/Dracula.theme /tmp/Dracula.theme
RUN mkdir -p /home/vscode/.ghidra/.ghidra_11.2.1_PUBLIC/themes && \
    cp /tmp/Dracula.theme /home/vscode/.ghidra/.ghidra_11.2.1_PUBLIC/themes/ && \
    echo 'Theme=Dracula' > /home/vscode/.ghidra/.ghidra_11.2.1_PUBLIC/preferences && \
    rm /tmp/Dracula.theme

# =====================================================
# APPLICATION CONFIG
# =====================================================
# Geany Dracula
RUN mkdir -p /home/vscode/.config/geany/colorschemes && \
    curl -fsSL -o /home/vscode/.config/geany/colorschemes/Dracula-Theme.conf \
    https://raw.githubusercontent.com/dracula/geany/master/Dracula-Theme.conf && \
    echo '[geany]' > /home/vscode/.config/geany/geany.conf && \
    echo 'color_scheme=Dracula-Theme.conf' >> /home/vscode/.config/geany/geany.conf

# Tilix Dracula
RUN mkdir -p /home/vscode/.config/tilix/schemes && \
    curl -fsSL -o /home/vscode/.config/tilix/schemes/Dracula.json \
    https://raw.githubusercontent.com/dracula/tilix/master/Dracula.json

# Default applications
RUN mkdir -p /home/vscode/.config && \
    echo '[Default Applications]' > /home/vscode/.config/mimeapps.list && \
    echo 'text/html=org.gnome.Epiphany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'x-scheme-handler/http=org.gnome.Epiphany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'x-scheme-handler/https=org.gnome.Epiphany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'text/plain=geany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'text/x-csrc=geany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'text/x-python=geany.desktop' >> /home/vscode/.config/mimeapps.list

# Fix ownership
RUN chown -R 1000:1000 /home/vscode
