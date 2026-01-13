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
    epiphany-browser \
    tilix \
    dconf-cli \
    autocutsel \
    geany \
    && rm -rf /var/lib/apt/lists/*

# Install Python tools
RUN python3 -m pip install --break-system-packages \
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

# Pre-configure Fluxbox with Dracula theme (before desktop-lite starts)
RUN mkdir -p /home/vscode/.fluxbox/styles && \
    git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox && \
    cp -r /tmp/dracula-fluxbox/dracula /home/vscode/.fluxbox/styles/ && \
    rm -rf /tmp/dracula-fluxbox && \
    echo "session.styleFile: /home/vscode/.fluxbox/styles/dracula" > /home/vscode/.fluxbox/init && \
    echo "session.screen0.toolbar.visible: true" >> /home/vscode/.fluxbox/init && \
    echo "session.screen0.workspaces: 1" >> /home/vscode/.fluxbox/init

# Configure Fluxbox apps to hide vncconfig window
RUN echo "[startup] {vncconfig -nowin &}" > /home/vscode/.fluxbox/apps

# Pre-configure GTK Dracula theme
RUN mkdir -p /home/vscode/.themes && \
    git clone --depth=1 https://github.com/dracula/gtk.git /home/vscode/.themes/Dracula && \
    mkdir -p /home/vscode/.config/gtk-3.0 && \
    echo "[Settings]" > /home/vscode/.config/gtk-3.0/settings.ini && \
    echo "gtk-theme-name=Dracula" >> /home/vscode/.config/gtk-3.0/settings.ini && \
    echo "gtk-icon-theme-name=Dracula" >> /home/vscode/.config/gtk-3.0/settings.ini && \
    echo "gtk-application-prefer-dark-theme=1" >> /home/vscode/.config/gtk-3.0/settings.ini

# Pre-configure Geany with Dracula theme
RUN mkdir -p /home/vscode/.config/geany/colorschemes && \
    curl -fsSL -o /home/vscode/.config/geany/colorschemes/Dracula-Theme.conf \
    https://raw.githubusercontent.com/dracula/geany/master/Dracula-Theme.conf && \
    mkdir -p /home/vscode/.config/geany && \
    echo "[geany]" > /home/vscode/.config/geany/geany.conf && \
    echo "color_scheme=Dracula-Theme.conf" >> /home/vscode/.config/geany/geany.conf

# Pre-configure Tilix with Dracula scheme
RUN mkdir -p /home/vscode/.config/tilix/schemes && \
    curl -fsSL -o /home/vscode/.config/tilix/schemes/Dracula.json \
    https://raw.githubusercontent.com/dracula/tilix/master/Dracula.json

# Set default applications (browser, editor)
RUN mkdir -p /home/vscode/.config && \
    echo "[Default Applications]" > /home/vscode/.config/mimeapps.list && \
    echo "text/html=org.gnome.Epiphany.desktop" >> /home/vscode/.config/mimeapps.list && \
    echo "x-scheme-handler/http=org.gnome.Epiphany.desktop" >> /home/vscode/.config/mimeapps.list && \
    echo "x-scheme-handler/https=org.gnome.Epiphany.desktop" >> /home/vscode/.config/mimeapps.list && \
    echo "text/plain=geany.desktop" >> /home/vscode/.config/mimeapps.list && \
    echo "text/x-csrc=geany.desktop" >> /home/vscode/.config/mimeapps.list && \
    echo "text/x-python=geany.desktop" >> /home/vscode/.config/mimeapps.list

# Fix ownership
RUN chown -R vscode:vscode /home/vscode/.fluxbox /home/vscode/.themes /home/vscode/.config
