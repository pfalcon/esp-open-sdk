FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get install -yq software-properties-common python-software-properties
RUN add-apt-repository -y multiverse
RUN apt-get update && apt-get install -yq \
    make \
    unrar \
    bzip2 \
    autoconf \
    automake \
    libtool \
    gcc \
    g++ \
    gperf \
    flex \
    bison \
    texinfo \
    gawk \
    ncurses-dev \
    libexpat-dev \
    python \
    python-serial \
    sed \
    git \
    unzip \
    bash \
    help2man \
    libtool-bin \
    wget

RUN useradd esp-open-sdk -m -G sudo
RUN echo 'esp-open-sdk:secrete' | chpasswd

# Assuming this dockerfile is in cwd with repo cloned
COPY . /home/esp-open-sdk
RUN chown esp-open-sdk:esp-open-sdk /home/esp-open-sdk -R
USER esp-open-sdk

ENV PATH /home/esp-open-sdk/xtensa-lx106-elf/bin/:$PATH
WORKDIR /home/esp-open-sdk
RUN alias xgcc="xtensa-lx106-elf-gcc"
RUN make STANDALONE=y | tee make0.log
