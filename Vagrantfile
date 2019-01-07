# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    # Build fails (OOM) with default 512mb
    v.memory = 1024
    v.cpus = 2
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
     # Install required packages
     sudo apt-get update
     sudo apt-get -y install git make autoconf automake libtool gcc g++ gperf \
              flex bison texinfo gawk ncurses-dev libexpat-dev python sed unzip

     # Build SDK
     cd /vagrant
     make

     # Setup environment variables
     sudo tee /etc/profile.d/esp-sdk-paths.sh >/dev/null <<EOF
#!/bin/sh
#
# Espressif SDK / xtensa toolchain paths
#

export PATH="/vagrant/xtensa-lx106-elf/bin:\\\$PATH"

# These are the variables used in many Makefiles found around the internet
export XTENSA_TOOLS_ROOT="/vagrant/xtensa-lx106-elf/bin"
export SDK_BASE="/vagrant/sdk"
EOF

     sudo chmod +x /etc/profile.d/esp-sdk-paths.sh
  SHELL
end
