FROM debian:bullseye

LABEL maintainer="Ivan Gagis <igagis@gmail.com>"

RUN apt update
RUN apt install --yes git

# Install dependencies.
RUN apt install --yes make unrar-free autoconf automake libtool gcc g++ gperf flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python sed git unzip bash help2man wget bzip2 libtool-bin

# The crosstool-NG forbids buildinf as root, so add non-root user to build it.
# Add newly created user right away to 'dialout' group to allow access to serial ports when using esptool.
RUN useradd --create-home --shell /bin/bash --groups dialout sdk

# copy outside repo contents into the image
COPY sdk /home/sdk/esp-open-sdk
RUN chown --recursive sdk /home/sdk/esp-open-sdk

USER sdk
WORKDIR /home/sdk

# Build the SDK.
RUN (cd esp-open-sdk && make)

# remove stuff which is not needed anymore to make the image a bit smaller
RUN (cd esp-open-sdk && rm -rf crosstool-NG && rm -rf esp-open-lwip && rm -rf lx106-hal && rm -rf esptool)

# Add toolchain to PATH
ENV PATH="${PATH}:/home/sdk/esp-open-sdk/xtensa-lx106-elf/bin/"

USER root
WORKDIR /root

# switch to python3 because python-serial package is not available in debian bullseye, so we have to use python3-serial
# and esptool will be run with python3 then
RUN apt install --yes python3 python-is-python3 python3-serial

# remove unused packages
RUN apt autoremove --yes

# make python3 the default, for some reason, installing python-is-python3 package does not work when building on github actions CI
RUN rm /usr/bin/python
RUN ln -s /usr/bin/python3 /usr/bin/python

# print python version
RUN python --version
