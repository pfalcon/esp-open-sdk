This repository provides integration scripts to build complete standalone
SDK (with toolchain) for software development for Espressif ESP8266,
ESP8266EX chips.

Complete SDK consists of:

1. Xtensa lx106 architecture toolchain (100% OpenSource), based on
following projects:

https://github.com/jcmvbkbc/crosstool-NG
https://github.com/jcmvbkbc/gcc-xtensa
https://github.com/jcmvbkbc/newlib-xtensa
https://github.com/tommie/lx106-hal

The sourcecode above originates from work done directly by Tensilica Inc.,
Cadence Design Systems, Inc, or their contractors.

2. ESP8266 IoT SDK from Espressif Systems. This component is only partially
open source, some libraries provided as binary blobs. 

http://bbs.espressif.com/viewforum.php?f=5

OpenSource components of SDK are based on:

lwIP, http://savannah.nongnu.org/projects/lwip/
Contiki, http://www.contiki-os.org/
axTLS, http://axtls.sourceforge.net/
wpa_supplicant, http://w1.fi/wpa_supplicant/ (source withheld by Espressif)


Building
========

To build standalone SDK with toolchain, you need GNU/POSIX system (Linux,
BSD, MacOSX, Windows with Cygwin) with standard GNU development tools
installed, like gcc, binutils, flex, bison, etc. For Ubuntu 14.04
install:

sudo apt-get install make unrar autoconf automake libtool gcc g++ gperf \
    flex bison texinfo gawk ncurses-dev libexpat-dev python sed

For other Debian/Ubuntu versions, dependencies may be somewhat different.
E.g., you may need to install libtool-bin, etc.

The project can be build in two modes:

1. Where OpenSource toolchain and tools kept separate from vendor IoT SDK
containing binary blobs. That makes licensing more clear, and facilitates
upgrades to new vendor SDK releases.

2. Completely standalone ESP8266 SDK with vendor SDK files merged with
toolchain. This mode makes it easier to build software (no additinal
-I and -L flags are needed), but redistributability of this build is
unclear and upgrade to newer vendor IoT SDK release is complicated.
This mode is default for local builds. Note that if you want to
redistribute binary toolchain built with this mode, your should:
1) make it clear to your users that the release is bound to particular
vendor IoT SDK and provide instructions how to upgrade to newer vendor
IoT SDK releases; 2) abide by licensing terms of the vendor IoT SDK.

To build separated SDK:

make STANDALONE=n

To build standalone SDK:

make STANDALONE=y

This will download all necessary components and compile them. Once done,
the toolchain (with Xtensa HAL library) will be available in xtensa-lx106-elf/
directory. Add its bin/ subdirectory to PATH to execute "xtensa-lx106-elf-gcc"
and other tools.

ESP8266 SDK will be installed in sdk/. If you chose non-standalone SDK, to use it,
run the compiler with corresponding include and lib dir flags:

xtensa-lx106-elf-gcc -I$(THISDIR)/sdk/include -L$(THISDIR)/sdk/lib

Extra -I and -L flags are not needed for standalone SDK.


Pulling updates
===============
The project is updated from time to time, to get the updates and prepare to
build new SDK:

make clean
git pull
git submodule update

If you don't issue "make clean" (which causes toolchain and SDK to be rebuilt
from scratch on next "make"), you risk getting broken/inconsistent result.


Additional configuration
========================

You can build statically linked toolchain by uncommenting
CT_STATIC_TOOLCHAIN=y option in crosstool-config-overrides
file. More fine-tunable options may be available in that
file and/or Makefile.
