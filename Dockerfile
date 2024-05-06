FROM ubuntu:24.04

# user setup
ARG USER_UID=1000
ARG USER_GID=1000
ARG DOCKER_GID=999
ARG WHEEL_GID=980
RUN echo 'remove existing ubuntu user' \
  && groupdel --force ubuntu \
  && userdel --force ubuntu \
  && echo 'setup extra groups' \
  && groupadd --gid ${WHEEL_GID} wheel \
  && groupadd --gid ${DOCKER_GID} docker

# system deps
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
    fish \
    fop \
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
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    liblzma-dev \
    liblzma5 \
    libncurses-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libodbc2 \
    libpcre2-dev \
    libpng-dev \
    libreadline-dev \
    libsctp-dev \
    libsctp1 \
    libsqlite3-dev \
    libssh-dev \
    libssl-dev \
    libtool \
    libwxgtk-webview3.2-dev \
    libwxgtk3.2-dev \
    libxml2-utils \
    libxslt-dev \
    libyaml-dev \
    llvm \
    locales \
    m4 \
    make \
    neovim \
    net-tools \
    openjdk-17-jdk \
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
    xsltproc \
    xz-utils \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && echo 'setup unprivileged user' \
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
ENV DO_VERSION 24.0.7
ENV DO_URL https://download.docker.com/linux/static/stable/x86_64/docker-${DO_VERSION}.tgz
ENV DC_VERSION v2.23.3
ENV DC_URL https://github.com/docker/compose/releases/download/${DC_VERSION}/docker-compose-linux-x86_64
ENV BX_VERSION v0.13.1
ENV BX_URL https://github.com/docker/buildx/releases/download/${BX_VERSION}/buildx-${BX_VERSION}.linux-amd64
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes \
  && curl -sS https://setup.atuin.sh | bash \
  && mkdir /tmp/download \
  && curl -L ${DO_URL} | tar -zx -C /tmp/download \
  && chgrp --recursive docker /tmp/download \
  && mv /tmp/download/docker/* /usr/local/bin \
  && rm -rf /tmp/download \
  && mkdir -p /usr/local/lib/docker/cli-plugins \
  && curl -L ${DC_URL} -o /usr/local/lib/docker/cli-plugins/docker-compose \
  && chmod 750 /usr/local/lib/docker/cli-plugins/docker-compose \
  && curl -L ${BX_URL} -o /usr/local/lib/docker/cli-plugins/docker-buildx \
  && chmod 750 /usr/local/lib/docker/cli-plugins/docker-buildx \
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

# NOTE (jpd): the section below exists mainly to handle a project running elixir 1.11.
# It allows the usage of openssl 1.1 and a compatible elixir-ls.

# configure openssl 1.1
# this is needed to compile older erlang versions
# example: KERL_CONFIGURE_OPTIONS="-with-ssl=$HOME/.local/lib/ssl" mise install
RUN mkdir -p ${HOME}/.local/src \
  && cd ${HOME}/.local/src \
  && curl -L https://www.openssl.org/source/openssl-1.1.1m.tar.gz | tar -xz \
  && cd openssl-1.1.1m \
  && ./config --prefix=${HOME}/.local/lib/ssl --openssldir=${HOME}/.local/lib/ssl shared zlib \
  && make \
  # && make test \
  && make install

# fetch elixir-ls to install custom releases
RUN git clone https://github.com/elixir-lsp/elixir-ls.git ${LOCAL_SRC_HOME}/elixir-ls

# command line utilities
RUN curl https://mise.jdx.dev/install.sh | sh \
  && curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash \
  && git clone https://github.com/tmux-plugins/tpm.git ${XDG_CONFIG_HOME}/tmux/plugins/tpm

# configure fish and bash
RUN fish -c true \
  && echo 'starship init fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo '{$LOCAL_BIN_HOME}/mise activate fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'zoxide init fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'atuin init fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'alias cat="bat"' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'alias l="eza --time-style=long-iso --color=auto --classify=always"' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'alias ll="l -ahl"' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'alias la="l -a"' >> ${XDG_CONFIG_HOME}/fish/config.fish

# git configuration
COPY ./patch/kickstart.nvim/updates.patch /tmp
COPY ./config/nvim/lua/custom/plugins/init.lua /tmp
RUN git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME}"/nvim \
  && cd ${XDG_CONFIG_HOME}/nvim \
  && git reset --hard c4363e4ad8aa3269a581d89b1e11403dd89df291 \
  && git apply /tmp/updates.patch \
  && cp /tmp/init.lua ${XDG_CONFIG_HOME}/nvim/lua/custom/plugins \
  && nvim --headless "+Lazy! sync" +qa

# install rtx plugins
RUN ${LOCAL_BIN_HOME}/mise plugins install --force --yes \
    awscli \
    bat \
    bitwarden \
    dagger \
    elixir \
    erlang \
    eza \
    fzf \
    helm \
    k3d \
    k3sup \
    k9s \
    kubectl \
    kubie \
    lefthook \
    lua \
    luajit \
    poetry \
    ripgrep \
    rust \
    starship \
    terraform \
    tilt \
    tmux \
    usql \
    yarn \
    zoxide

# configure git
ARG GIT_USER_EMAIL
ARG GIT_USER_NAME
RUN git config --global user.email "${GIT_USER_EMAIL}" \
  && git config --global user.name "${GIT_USER_NAME}" \
  && git config --global gpg.ssh.allowedSignersFile "${XDG_CONFIG_HOME}/git/allowed_signers" \
  && git config --global core.editor nvim \
  && git config --global diff.tool nvimdiff \
  && git config --global difftool.nvimdiff.layout "LOCAL,REMOTE" \
  && git config --global merge.tool nvimdiff \
  && git config --global mergetool.nvimdiff.layout "LOCAL,BASE,REMOTE / MERGED" \
  && git config --global includeIf."hasconfig:remote.*.url:gitea:*/**".path ${XDG_CONFIG_HOME}/git/personal_gitea \
  && git config --global includeIf."hasconfig:remote.*.url:github:joaodubas/**".path ${XDG_CONFIG_HOME}/git/personal_github \
  && git config --global includeIf."gitdir:/opt/work/".path ${XDG_CONFIG_HOME}/git/work

COPY ./scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY ./scripts/elixir-ls-setup.sh /usr/local/bin/elixir-ls-setup
