FROM ubuntu:22.04

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
    pkg-config \
    python3-openssl \
    sudo \
    tk-dev \
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
  && groupadd --gid 980 wheel \
  && groupadd --gid 999 docker \
  && groupadd --gid 1000 coder \
  && useradd \
    --uid 1000 \
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
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes \
  && curl -LO ${BAT_URL} \
  && dpkg -i ${BAT_FILE} \
  && rm ${BAT_FILE} \
  && curl -LO ${RG_URL} \
  && dpkg -i ${RG_FILE} \
  && rm ${RG_FILE}

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
  && curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# configure fish
RUN git clone https://github.com/NvChad/NvChad.git ~/.config/nvim \
  && fish -c true \
  && echo 'starship init fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo '{$XDG_DATA_HOME}/rtx/bin/rtx activate fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish \
  && echo 'zoxide init fish | source' >> ${XDG_CONFIG_HOME}/fish/config.fish

RUN ${XDG_DATA_HOME}/rtx/bin/rtx plugins install \
    elixir \
    erlang \
    kubectl \
    awscli \
    helm \
    poetry \
    terraform
