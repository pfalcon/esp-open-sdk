FROM debian:bullseye

LABEL maintainer="Ivan Gagis <igagis@gmail.com>"

RUN apt update
RUN apt install -y git

#########################
# Install esp-open-sdk. #

# Install dependencies.
RUN apt install -y make unrar-free autoconf automake libtool gcc g++ gperf flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python python3-serial sed git unzip bash help2man wget bzip2 libtool-bin

RUN useradd --create-home --shell /bin/bash --groups dialout builder
USER sdk
WORKDIR /home/sdk

RUN git clone --recursive https://github.com/esp-open-sdk/esp-open-sdk.git

# TODO: remove
# # Update SDK to version 3.0
# RUN (cd esp-open-sdk && git config user.email "igagis@gmail.com" && git config user.name "Ivan Gagis")
# RUN (cd esp-open-sdk && git fetch origin pull/344/head && git checkout -b pullrequest FETCH_HEAD && git submodule update --init)

# Update crosstool-NG to latest version
# RUN (cd esp-open-sdk/crosstool-NG && git checkout xtensa-1.22.x && git pull)

# Update esp tool to latest version.
# RUN (cd esp-open-sdk/esptool && git checkout master)

# Build the SDK.
RUN (cd esp-open-sdk && make && rm -rf crosstool-NG && rm -rf esp-open-lwip && rm -rf lx106-hal && rm -rf esptool)

# Add toolchain to PATH
ENV PATH="${PATH}:/home/sdk/esp-open-sdk/xtensa-lx106-elf/bin/"

USER root
WORKDIR /root
