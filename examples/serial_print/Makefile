PROGRAM        = serial_print

# these values are set automatically
# uncomment and change them to override defauls
#
# FLASH_SIZE     = 8m
# FLASH_MODE     = dio
# ESPBAUD        = 115200
# ESPPORT        = /dev/ttyUSB0

LIBS           = gcc
SDK_LIBS       = main net80211 lwip phy pp wpa

EXTRA_SRCS     = $(ROOT)/sdk/driver_lib

# for a given extra source dirs, an include
# subdirectory is looked up automatically
#
# EXTRA_INCS     = $(ROOT)/sdk/driver_lib/include

include $(ESP_OPEN_SDK)/common.mk
