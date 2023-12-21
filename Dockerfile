FROM ubuntu:22.04

# system deps
ARG USER_UID=1000
ARG USER_GID=1000
ARG DOCKER_GID=999
ARG WHEEL_GID=980
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository ppa:fish-shell/release-3 \
  && add-apt-repository ppa:neovim-ppa/unstable \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    doas \
    exa \
    fish \
    g++ \
    gcc \
    gfortran \
    git \
    gosu \
    gpg \
    gpg-agent \
    groff \
    jq \
    less \
    libbz2-1.0 \
    libbz2-dev \
    libc6-dev \
    libcurl3-dev \
    libffi-dev \
    liblzma-dev \
    liblzma5 \
    libncurses-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libodbc1 \
    libpcre2-dev \
    libreadline-dev \
    libsctp-dev \
    libsctp1 \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libwxgtk3.0-gtk3-0v5 \
    libwxgtk3.0-gtk3-dev \
    libxslt-dev \
    libyaml-dev \
    llvm \
    locales \
    make \
    neovim \
    net-tools \
    openssh-client \
    openssl \
    parallel \
    pkg-config \
    python3-openssl \
    sudo \
    tk-dev \
    tmux \
    tmuxp \
    unixodbc-dev \
    unzip \
    uuid-dev \
    wget \
    xorg-dev \
    xz-utils \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && echo 'setup unprivileged user' \
  && groupadd --gid ${WHEEL_GID} wheel \
  && groupadd --gid ${DOCKER_GID} docker \
  && groupadd --gid ${USER_GID} coder \
  && useradd \
    --uid ${USER_UID} \
    --gid coder \
    --groups docker,wheel \
    --shell $(which fish) \
    --home-dir /home/coder \
    --create-home \
    coder \
  && echo 'coder:coder' | chpasswd \
  && echo 'permit persist :wheel as root' > /etc/doas.conf

# command line utilities
ENV BAT_VERSION 0.23.0
ENV BAT_FILE bat_${BAT_VERSION}_amd64.deb
ENV BAT_URL https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/${BAT_FILE}
ENV RG_VERSION 13.0.0
ENV RG_FILE ripgrep_${RG_VERSION}_amd64.deb
ENV RG_URL https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${RG_FILE}
ENV DO_VERSION 24.0.6
ENV DO_URL https://download.docker.com/linux/static/stable/x86_64/docker-${DO_VERSION}.tgz
ENV DC_VERSION v2.21.0
ENV DC_URL https://github.com/docker/compose/releases/download/${DC_VERSION}/docker-compose-linux-x86_64
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes \
  && curl -LO ${BAT_URL} \
  && dpkg -i ${BAT_FILE} \
  && rm ${BAT_FILE} \
  && curl -LO ${RG_URL} \
  && dpkg -i ${RG_FILE} \
  && rm ${RG_FILE} \
  && mkdir /tmp/download \
  && curl -L ${DO_URL} | tar -zx -C /tmp/download \
  && chgrp --recursive docker /tmp/download \
  && mv /tmp/download/docker/* /usr/local/bin \
  && rm -rf /tmp/download \
  && mkdir -p /usr/local/lib/docker/cli-plugins \
  && curl -L ${DC_URL} -o /usr/local/lib/docker/cli-plugins/docker-compose \
  && chmod 750 /usr/local/lib/docker/cli-plugins/docker-compose \
  && chgrp --recursive docker /usr/local/lib/docker

USER coder
WORKDIR /home/coder

ENV LANGUAGE en_US.UTF-8
ENV LANG ${LANGAGUE}
ENV LC_ALL ${LANGUAGE}
ENV HOME /home/coder
ENV LOCAL_BIN_HOME ${HOME}/.local/bin
ENV LOCAL_SRC_HOME ${HOME}/.local/src
ENV XDG_CONFIG_HOME ${HOME}/.config
ENV XDG_DATA_HOME ${HOME}/.local/share
ENV XDG_CACHE_HOME ${HOME}/.cache
ENV STARSHIP_CONFIG ${XDG_CONFIG_HOME}/starship/config.toml
ENV PATH ${LOCAL_BIN_HOME}:$PATH

# command line utilities
RUN curl https://rtx.pub/install.sh | sh \
  && curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash \
  && git clone https://github.com/tmux-plugins/tpm.git ${XDG_CONFIG_HOME}/tmux/plugins/tpm

# git configuration
COPY ./patch/kickstart.nvim/updates.patch /tmp
COPY ./config/nvim/lua/custom/plugins/init.lua /tmp
RUN git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME}"/nvim \
  && cd ${XDG_CONFIG_HOME}/nvim \
  && git reset --hard 1915cea32e13fcb4191904de8f5e0252ad050a6e \
  && git apply /tmp/updates.patch \
  && cp /tmp/init.lua ${XDG_CONFIG_HOME}/nvim/lua/custom/plugins \
  && nvim --headless "+Lazy! sync" +qa

# configure fish and bash
RUN fish -c true \
  && echo 'starship init fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo '{$XDG_DATA_HOME}/rtx/bin/rtx activate fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'zoxide init fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'alias cat="bat"' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'alias l="exa --time-style long-iso --color=auto -F"' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'alias ll="l -Fahl"' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'alias la="l -a"' >> ${XDG_CONFIG_HOME}/fish/config.fish

# configure git
ARG GIT_USER_EMAIL
ARG GIT_USER_NAME
RUN git config --global user.email "${GIT_USER_EMAIL}" \
  && git config --global user.name "${GIT_USER_NAME}" \
  && git config --global core.editor nvim

# install rtx plugins
RUN ${XDG_DATA_HOME}/rtx/bin/rtx plugins install \
    awscli \
    elixir \
    erlang \
    helm \
    kubectl \
    lefthook \
    poetry \
    terraform \
    tilt

# NOTE (jpd): the section below exists mainly to handle a project running elixir 1.11.
# It allows the usage of openssl 1.1 and a compatible elixir-ls.

# configure openssl 1.1
# this is needed to compile older erlang versions
# example: KERL_CONFIGURE_OPTIONS="-with-ssl=${HOME}/.local/lib/ssl" asdf install
RUN mkdir -p ${HOME}/.local/src \
  && cd ${HOME}/.local/src \
  && wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz \
  && tar -xzf openssl-1.1.1m.tar.gz \
  && cd openssl-1.1.1m \
  && ./config --prefix=${HOME}/.local/lib/ssl --openssldir=${HOME}/.local/lib/ssl shared zlib \
  && make \
  # && make test \
  && make install

# fetch elixir-ls compatible with elixir 1.11.x and 1.12.x
# to setup this project run the following commands:
# mix do local.rebar --force, local.hex --force
# mix do deps.get, deps.compile
# MIX_ENV=prod mix compile
# MIX_ENV=prod mix elixir_ls.release
RUN git clone https://github.com/elixir-lsp/elixir-ls.git ${LOCAL_SRC_HOME}/elixir-ls/v0.12.0 \
  && cd ${LOCAL_SRC_HOME}/elixir-ls/v0.12.0 \
  && git checkout tags/v0.12.0 \
  && cp .release-tool-versions .tool-versions \
  && git clone https://github.com/elixir-lsp/elixir-ls.git ${LOCAL_SRC_HOME}/elixir-ls/v0.14.6 \
  && cd ${LOCAL_SRC_HOME}/elixir-ls/v0.14.6 \
  && git checkout tags/v0.14.6 \
  && cp .release-tool-versions .tool-versions
