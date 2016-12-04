# This file is originally inspired by the esp-open-rtos project 

-include $(ROOT)local.mk
-include local.mk

# Flash size in megabits
# Valid values are same as for esptool.py - 2m,4m,8m,16m,32m,...
FLASH_SIZE    ?= 8m

# Flash mode, valid values are same as for esptool.py - qio,qout,dio.dout
FLASH_MODE    ?= dio

# Flash speed in MHz, valid values are same as for esptool.py - 80m, 40m, 26m, 20m
FLASH_SPEED   ?= 40m

# Output directories to store intermediate compiled files
# relative to the program directory
BUILD_DIR     ?= $(PROGRAM_DIR)/build
FIRMWARE_DIR  ?= $(PROGRAM_DIR)/firmware

# esptool.py from https://github.com/themadinventor/esptool
ESPTOOL       ?= esptool.py
# serial port settings for esptool.py
ESPBAUD       ?= 115200
ESPPORT       ?= /dev/ttyUSB0

ESPTOOL_ARGS  = -fs $(FLASH_SIZE) -fm $(FLASH_MODE) -ff $(FLASH_SPEED)

# Compiler names, etc. assume gdb
CROSS         ?= xtensa-lx106-elf-

AR            = $(CROSS)ar
CC            = $(CROSS)gcc
CPP           = $(CROSS)cpp
LD            = $(CROSS)gcc
NM            = $(CROSS)nm
C++           = $(CROSS)g++
SIZE          = $(CROSS)size
OBJCOPY       = $(CROSS)objcopy
OBJDUMP       = $(CROSS)objdump

# binary esp-iot-rtos SDK libraries to link. These are pre-processed prior to linking.
LIBS          ?= hal gcc c
SDK_LIBS      ?= json main net80211 lwip phy pp pwm ssl upgrade wpa

LD_SCRIPTS    ?= $(ROOT)/sdk/ld/eagle.app.v6.ld

EXTRA_INCS    ?= $(addsuffix /include, $(EXTRA_SRCS))

# V ?= 0
