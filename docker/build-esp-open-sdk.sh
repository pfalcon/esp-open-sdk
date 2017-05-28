#!/bin/bash
git clone --recursive https://github.com/pfalcon/esp-open-sdk.git
#cd esp-open-sdk && make
cd esp-open-sdk 
make clean
git pull
git submodule sync
git submodule update --init
make
