# esp-open-sdk common Makefile
#
# This makefile is inspired by the esp-open-rtos makefile by SuperHouse
# https://github.com/SuperHouse/esp-open-rtos, which in turn is adapted
# from the esp-mqtt makefile by @tuanpmt https://github.com/tuanpmt/esp_mqtt,
# but it has changed very significantly since then.

# assume the root directory is the directory common.mk is in
ROOT          := $(dir $(lastword $(MAKEFILE_LIST)))
# assume the program dir is the directory the top-level makefile was run in
PROGRAM_DIR   := $(dir $(firstword $(MAKEFILE_LIST)))

include $(ROOT)parameters.mk

ifndef PROGRAM
$(error "Set the PROGRAM environment variable in your Makefile")
endif

# Placing $(PROGRAM_DIR) and $(PROGRAM_DIR)include first allows
# programs to have their own copies of header config files for components
# , which is useful for overriding things.
SRC_DIRS      := $(PROGRAM_DIR) $(EXTRA_SRCS)
INC_DIRS      := $(PROGRAM_DIR) $(PROGRAM_DIR)include $(EXTRA_INCS) $(ROOT)/sdk/include
LIB_DIRS      := $(ROOT)/sdk/lib

SRC_ARGS      := $(addsuffix /**,$(SRC_DIRS))
INC_ARGS      := $(addprefix -I,$(INC_DIRS))
LIB_ARGS      := $(addprefix -L,$(LIB_DIRS))
LIB_ARGS      += $(addprefix -l,$(LIBS))
LIB_ARGS      += $(addprefix -l,$(SDK_LIBS))
LD_ARGS       := $(addprefix -T,$(LD_SCRIPTS))

PROGRAM_OUT   := $(BUILD_DIR)/$(PROGRAM).out

CFLAGS        := $(INC_ARGS)
CFLAGS        += -Os
CFLAGS        += -nostdlib
CFLAGS        += -mlongcalls
CFLAGS        += -mtext-section-literals
CFLAGS        += -ggdb
CFLAGS        += -Wpointer-arith
CFLAGS        += -Wundef
CFLAGS        += -Wl,-EL
CFLAGS        += -fdata-sections
CFLAGS        += -ffunction-sections
CFLAGS        += -fno-inline-functions
CFLAGS        += -Wno-address
CFLAGS        += -D__ets__
CFLAGS        += -DICACHE_FLASH

LDFLAGS       := $(LD_ARGS)
LDFLAGS       += -nostdlib
LDFLAGS       += -u call_user_start
LDFLAGS       += -Wl,-static
LDFLAGS       += -Wl,--gc-sections
LDFLAGS       += -Wl,--no-check-sections
LDFLAGS       += -Wl,--start-group $(LIB_ARGS) -Wl,--end-group

FW_ADDR_1     := 0x00000
FW_ADDR_2     := 0x40000
FW_FILE_1     := $(FIRMWARE_DIR)/$(FW_ADDR_1).bin
FW_FILE_2     := $(FIRMWARE_DIR)/$(FW_ADDR_2).bin

ifeq ("$(V)","1")
Q :=
vecho := @true
else
Q := @
vecho := @echo
endif

.PHONY: all clean flash erase_flash echo

all: $(FW_FILE_1) $(FW_FILE_2)

# recursive wildcards
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# How to recursively find all files that match a pattern
C_FILE        := $(foreach src, $(SRC_ARGS), $(call rwildcard, $(subst //,/,$(src)),*.c))
CPP_FILE      := $(foreach src, $(SRC_ARGS), $(call rwildcard, $(subst //,/,$(src)),*.cpp))
# strip leading "./" from source files
C_SOURCE      := $(patsubst ./%,%,$(C_FILE))
CPP_SOURCE    := $(patsubst ./%,%,$(CPP_FILE))
# add prefix of build dir and remove double slashes from path
C_OBJECT      := $(foreach obj, $(addprefix $(BUILD_DIR)/,$(patsubst %.c,%.o,$(C_SOURCE))), $(subst //,/, $(subst $(ROOT),,$(obj))))
CPP_OBJECT    := $(foreach obj, $(addprefix $(BUILD_DIR)/,$(patsubst %.cpp,%.o,$(CPP_SOURCE))), $(subst //,/, $(subst $(ROOT),,$(obj))))

define compile
SRC = $(1)
# replace source file extension by object file extension
OBJ = $(subst //,/,$(addprefix $(BUILD_DIR)/,$(subst $(ROOT),,$(patsubst %.c,%.o,$1))))
$$(OBJ): $$(SRC)
	$$(vecho) "$(2) $$@"
	$$(Q) mkdir -p $$(dir $$@)
	$$(Q) $$($(2)) $$(CFLAGS) -c $$< -o $$@
	$$(Q) $$($(2)) $$(CFLAGS) -MM -MT $$@ -MF $$(patsubst %.o,%.d,$$@) $$<
endef

$(foreach src,$(C_SOURCE),$(eval $(call compile,$(src),CC)))
$(foreach src,$(CPP_SOURCE),$(eval $(call compile,$(src),CPP)))

$(FW_FILE_1) $(FW_FILE_2): $(PROGRAM_OUT) $(FIRMWARE_DIR)
	$(vecho) "FW $@"
	$(Q) $(ESPTOOL) elf2image $(ESPTOOL_ARGS) $< -o $(FIRMWARE_DIR)/

$(BUILD_DIR) $(FIRMWARE_DIR):
	$(Q) mkdir -p $@

$(PROGRAM_OUT): $(C_OBJECT) $(CPP_OBJECT)
	$(Q) $(LD) $^ -o $@ $(LDFLAGS)

flash: $(FW_FILE_1) $(FW_FILE_2)
	$(vecho) "FLASH"
	$(Q) $(ESPTOOL) -p $(ESPPORT) --baud $(ESPBAUD) write_flash $(ESPTOOL_ARGS) $(FW_ADDR_1) $(FW_FILE_1) $(FW_ADDR_2) $(FW_FILE_2)

erase_flash:
	$(Q) $(ESPTOOL) -p $(ESPPORT) --baud $(ESPBAUD) erase_flash

size: $(PROGRAM_OUT)
	$(vecho) "SIZE"
	$(Q) $(CROSS)size --format=sysv $(PROGRAM_OUT)

test: flash
	screen $(ESPPORT) $(ESPBAUD)

rebuild: clean all

clean:
	$(vecho) "CLEAN"
	$(Q) rm -f $(PROGRAM_OUT)
	$(Q) rm -rf $(BUILD_DIR)
	$(Q) rm -rf $(FIRMWARE_DIR)

# prevent "intermediate" files from being deleted
.SECONDARY:

# print some useful help stuff
help:
	@echo "esp-open-sdk make"
	@echo ""
	@echo "Other targets:"
	@echo ""
	@echo "all"
	@echo "Default target. Will build firmware including any changed source files."
	@echo
	@echo "clean"
	@echo "Delete all build output."
	@echo ""
	@echo "rebuild"
	@echo "Build everything fresh from scratch."
	@echo ""
	@echo "flash"
	@echo "Build then upload firmware to MCU. Set ESPPORT & ESPBAUD to override port/baud rate."
	@echo ""
	@echo "test"
	@echo "'flash', then start a GNU Screen session on the same serial port to see serial output."
	@echo ""
	@echo "size"
	@echo "Build, then print a summary of built firmware size."
	@echo ""
	@echo "TIPS:"
	@echo "* You can use -jN for parallel builds. Much faster! Use 'make rebuild' instead of 'make clean all' for parallel builds."
	@echo "* You can create a local.mk file to create local overrides of variables like ESPPORT & ESPBAUD."
	@echo ""
	@echo "SAMPLE COMMAND LINE:"
	@echo "make -j2 test ESPPORT=/dev/ttyUSB0"
	@echo ""
