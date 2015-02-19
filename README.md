esp-open-sdk
------------

This repository provides the integration scripts to build a complete
standalone SDK (with toolchain) for software development with the
Espressif ESP8266 and ESP8266EX chips.

The complete SDK consists of:

1. Xtensa lx106 architecture toolchain (100% OpenSource), based on
   following projects:
    * https://github.com/jcmvbkbc/crosstool-NG
    * https://github.com/jcmvbkbc/gcc-xtensa
    * https://github.com/jcmvbkbc/newlib-xtensa
    * https://github.com/tommie/lx106-hal

The source code above originates from work done directly by Tensilica Inc.,
Cadence Design Systems, Inc, and/or their contractors.

2. ESP8266 IoT SDK from Espressif Systems. This component is only
   partially open source, (some libraries are provided as binary blobs).
    * http://bbs.espressif.com/viewforum.php?f=5

OpenSource components of the SDK are based on:
* lwIP, http://savannah.nongnu.org/projects/lwip/
* Contiki, http://www.contiki-os.org/
* axTLS, http://axtls.sourceforge.net/
* wpa_supplicant, http://w1.fi/wpa_supplicant/ (source withheld by Espressif)
* net80211/ieee80211 (FreeBSD WiFi stack),
  http://www.unix.com/man-page/freebsd/9/NET80211
  (source withheld by Espressif)

Building
========

To build the standalone SDK and toolchain, you need a GNU/POSIX system
(Linux, BSD, MacOSX, Windows with Cygwin) with the standard GNU development
tools installed: gcc, binutils, flex, bison, etc. For Ubuntu 14.04
run:

```
$ sudo apt-get install make unrar autoconf automake libtool gcc g++ gperf \
    flex bison texinfo gawk ncurses-dev libexpat-dev python sed
```

For other Debian/Ubuntu versions, dependencies may be somewhat different.
E.g. you may need to install libtool-bin, etc.

The project can be built in two modes:

1. Where the toolchain and tools are kept separate from the vendor IoT SDK
   which contains binary blobs. This makes licensing more clear, and helps
   facilitate upgrades to vendor SDK releases.

2. A completely standalone ESP8266 SDK with the vendor SDK files merged
   into the toolchain. This mode makes it easier to build software (no
   additinal `-I` and `-L` flags are needed), but redistributability of
   this build is unclear and upgrades to newer vendor IoT SDK releases are
   complicated. This mode is default for local builds. Note that if you
   want to redistribute the binary toolchain built with this mode, you
   should:

    1. Make it clear to your users that the release is bound to a
       particular vendor IoT SDK and provide instructions how to upgrade
       to a newer vendor IoT SDK releases.
    2. Abide by licensing terms of the vendor IoT SDK.

To build the separated SDK:

```
$ make STANDALONE=n
```

To build the standalone SDK:

```
$ make STANDALONE=y
```

This will download all necessary components and compile them. Once done,
the toolchain (with the Xtensa HAL library) will be available in the
`xtensa-lx106-elf/` directory. Add its `bin/` subdirectory to your
`$PATH` to execute `xtensa-lx106-elf-gcc` and other tools.

ESP8266 SDK will be installed in `sdk/`. If you chose the non-standalone
SDK, run the compiler with the corresponding include and lib dir flags:

```
$ xtensa-lx106-elf-gcc -I$(THISDIR)/sdk/include -L$(THISDIR)/sdk/lib
```

The extra -I and -L flags are not needed when using the standalone SDK.

Pulling updates
===============
The project is updated from time to time, to update and prepare to
build a new SDK, run:

```
$ make clean
$ git pull
$ git submodule update
```

If you don't issue `make clean` (which causes toolchain and SDK to be
rebuilt from scratch on next `make`), you risk getting broken/inconsistent
results.

Additional configuration
========================

You can build a statically linked toolchain by uncommenting
`CT_STATIC_TOOLCHAIN=y` in the file `crosstool-config-overrides`. More
fine-tunable options may be available in that file and/or Makefile.
