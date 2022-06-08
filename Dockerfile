FROM debian:latest as builder

# Label base
LABEL maintainer="Alex Kislitsa"

# Radare version
ARG R2_VERSION=master
ARG R2_TAG=5.7.0

ENV R2_VERSION ${R2_VERSION}
ENV R2_TAG ${R2_TAG}
# ENV R2_PIPE_PY_VERSION ${R2_PIPE_PY_VERSION}

ENV DEBIAN_FRONTEND noninteractive

ENV TZ UTC

RUN echo -e "Building versions:\n\
  R2_VERSION=${R2_VERSION}\n\
  R2_TAG=${R2_TAG}"

# Build radare2 in a volume to minimize space used by build
VOLUME ["/mnt"]

# Install all build dependencies
# Install bindings
# Build and install radare2 on master branch
# Remove all build dependencies
# Cleanup
RUN \
  apt-get -y update && \
  apt install -y \
  cmake \
  pkg-config \
  ipython3 \
  libffi-dev \
  libssl-dev \
  python3-dev \
  python3-pip \
  build-essential \
  ruby \
  ruby-dev \
  wget \
  curl \
  git \
  patchelf \
  gawk \
  file \
  python3-distutils \
  python3-dev \
  python3-setuptools \
  python-is-python3 \
  libglib2.0-dev \
  libc6-dbg \
  bison \
  rpm2cpio cpio \
  zstd \
  sudo && \
  apt install -y locales --reinstall && \
  rm -rf /var/lib/apt/list/*

WORKDIR /mnt

RUN \
  git clone -q --depth 1 https://github.com/radareorg/radare2.git -b ${R2_TAG} && \
  cd radare2 && \
  git checkout -b ${R2_TAG} && \
  ./sys/install.sh --install && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  r2pm init && r2pm update && r2pm -gi r2ghidra-sleigh && r2pm -gi r2ghidra && r2pm -gi r2frida

FROM kalilinux/kali-rolling:latest as runner

# Label base
LABEL maintainer="Alex Kislitsa"

ENV DEBIAN_FRONTEND noninteractive

ENV TZ UTC

COPY --from=builder /usr/local /usr/local

# kali-linux-core: Base Kali Linux System – core items that are always included
# kali-linux-headless: Default install that doesn’t require GUI
# kali-linux-default: “Default” desktop (amd64/i386) images include these tools
# kali-linux-arm: All tools suitable for ARM devices
# kali-linux-nethunter: Tools used as part of Kali NetHunter
RUN \
  apt update -y && \
  apt install -y kali-linux-headless
RUN \
  apt install -y \
    pkg-config \
    libxxhash-dev \
    iputils-ping

# Create non-root user
RUN useradd -m adam && usermod -aG sudo adam

# New added for disable sudo password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY locale.gen /etc/
RUN locale-gen

# Initilise base user
USER adam
WORKDIR /home/adam
ENV HOME /home/adam
