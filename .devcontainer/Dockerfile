FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set JAVA_HOME for Ghidra
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# GTK theme environment variable
ENV GTK_THEME=Dracula

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
    wmctrl \
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

# Install Ghidra (no symlink - wrapper created in postCreate.sh)
ARG GHIDRA_VERSION=11.2.1
ARG GHIDRA_DATE=20241105
RUN wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" -O /tmp/ghidra.zip && \
    unzip -q /tmp/ghidra.zip -d /opt/ && \
    mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra && \
    rm /tmp/ghidra.zip

# =====================================================
# FLUXBOX CONFIGURATION (must be before desktop-lite)
# =====================================================

# Install Fluxbox Dracula style
RUN mkdir -p /home/vscode/.fluxbox/styles && \
    git clone --depth=1 https://github.com/dracula/fluxbox.git /tmp/dracula-fluxbox && \
    cp -r /tmp/dracula-fluxbox/dracula /home/vscode/.fluxbox/styles/ && \
    rm -rf /tmp/dracula-fluxbox

# Complete Fluxbox init (based on desktop-lite defaults, but with Dracula style)
RUN echo 'session.configVersion: 13' > /home/vscode/.fluxbox/init && \
    echo 'session.menuFile: ~/.fluxbox/menu' >> /home/vscode/.fluxbox/init && \
    echo 'session.keyFile: ~/.fluxbox/keys' >> /home/vscode/.fluxbox/init && \
    echo 'session.styleFile: /home/vscode/.fluxbox/styles/dracula' >> /home/vscode/.fluxbox/init && \
    echo 'session.screen0.workspaces: 1' >> /home/vscode/.fluxbox/init && \
    echo 'session.screen0.workspacewarping: false' >> /home/vscode/.fluxbox/init && \
    echo 'session.screen0.toolbar.widthPercent: 100' >> /home/vscode/.fluxbox/init && \
    echo 'session.screen0.strftimeFormat: %a %l:%M %p' >> /home/vscode/.fluxbox/init && \
    echo 'session.screen0.toolbar.tools: RootMenu, clock, iconbar, systemtray' >> /home/vscode/.fluxbox/init && \
    echo 'session.screen0.workspaceNames: One,' >> /home/vscode/.fluxbox/init

# Fluxbox menu with our apps
RUN echo '[begin] (ll26env)' > /home/vscode/.fluxbox/menu && \
    echo '  [exec] (File Manager) {nautilus}' >> /home/vscode/.fluxbox/menu && \
    echo '  [exec] (Text Editor) {geany}' >> /home/vscode/.fluxbox/menu && \
    echo '  [exec] (Terminal) {tilix}' >> /home/vscode/.fluxbox/menu && \
    echo '  [exec] (Web Browser) {epiphany}' >> /home/vscode/.fluxbox/menu && \
    echo '  [separator]' >> /home/vscode/.fluxbox/menu && \
    echo '  [exec] (Ghidra) {/opt/ghidra/ghidraRun}' >> /home/vscode/.fluxbox/menu && \
    echo '  [exec] (GDB) {tilix -e gdb}' >> /home/vscode/.fluxbox/menu && \
    echo '  [separator]' >> /home/vscode/.fluxbox/menu && \
    echo '  [submenu] (System)' >> /home/vscode/.fluxbox/menu && \
    echo '    [exec] (Edit Menu) {geany ~/.fluxbox/menu}' >> /home/vscode/.fluxbox/menu && \
    echo '    [exec] (Reload Config) {fluxbox-remote restart}' >> /home/vscode/.fluxbox/menu && \
    echo '    [exec] (htop) {tilix -e htop}' >> /home/vscode/.fluxbox/menu && \
    echo '  [end]' >> /home/vscode/.fluxbox/menu && \
    echo '[end]' >> /home/vscode/.fluxbox/menu

# Fluxbox apps - hide vncconfig window
RUN echo '[app] (name=vncconfig)' > /home/vscode/.fluxbox/apps && \
    echo '  [Minimized] {yes}' >> /home/vscode/.fluxbox/apps && \
    echo '  [IconHidden] {yes}' >> /home/vscode/.fluxbox/apps && \
    echo '[end]' >> /home/vscode/.fluxbox/apps && \
    echo '' >> /home/vscode/.fluxbox/apps && \
    echo '[transient]' >> /home/vscode/.fluxbox/apps && \
    echo '  [Dimensions] {70% 70%}' >> /home/vscode/.fluxbox/apps && \
    echo '  [Position] (CENTER) {0 0}' >> /home/vscode/.fluxbox/apps && \
    echo '[end]' >> /home/vscode/.fluxbox/apps

# =====================================================
# GTK THEME CONFIGURATION
# =====================================================

# GTK Dracula theme
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
# APPLICATION CONFIGURATION
# =====================================================

# Geany Dracula colorscheme
RUN mkdir -p /home/vscode/.config/geany/colorschemes && \
    curl -fsSL -o /home/vscode/.config/geany/colorschemes/Dracula-Theme.conf \
    https://raw.githubusercontent.com/dracula/geany/master/Dracula-Theme.conf && \
    echo '[geany]' > /home/vscode/.config/geany/geany.conf && \
    echo 'color_scheme=Dracula-Theme.conf' >> /home/vscode/.config/geany/geany.conf

# Tilix Dracula scheme
RUN mkdir -p /home/vscode/.config/tilix/schemes && \
    curl -fsSL -o /home/vscode/.config/tilix/schemes/Dracula.json \
    https://raw.githubusercontent.com/dracula/tilix/master/Dracula.json

# Default applications via mimeapps.list
RUN mkdir -p /home/vscode/.config && \
    echo '[Default Applications]' > /home/vscode/.config/mimeapps.list && \
    echo 'text/html=org.gnome.Epiphany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'x-scheme-handler/http=org.gnome.Epiphany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'x-scheme-handler/https=org.gnome.Epiphany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'text/plain=geany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'text/x-csrc=geany.desktop' >> /home/vscode/.config/mimeapps.list && \
    echo 'text/x-python=geany.desktop' >> /home/vscode/.config/mimeapps.list

# Fix ownership of all user config
RUN chown -R vscode:vscode /home/vscode
