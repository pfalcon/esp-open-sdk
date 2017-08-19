CC = xtensa-lx106-elf-gcc
CFLAGS = -I. -mlongcalls -DICACHE_FLASH
LDLIBS = -nostdlib -Wl,--start-group -lmain -lnet80211 -lwpa -llwip -lpp -lphy -lc -Wl,--end-group -lgcc
LDFLAGS = -Teagle.app.v6.ld

# Adapted from https://stackoverflow.com/a/27794283/182750 and https://github.com/pfalcon/esp-open-sdk/blob/c416ce38f843025401ab3f5d9ca21dad9ccc3f78/examples/blinky/Makefile

#The Target Binary Program
TARGET      := pool

#The Directories, Source, Includes, Objects, Binary
SRCDIR      := src
INCDIR      := include
BUILDDIR    := obj
TARGETDIR   := bin
SRCEXT      := c
OBJEXT      := o

INC         := -I$(INCDIR)

SOURCES     := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS     := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.$(OBJEXT)))

all: directories $(TARGET) images

directories:
	@mkdir -p $(TARGETDIR)
	@mkdir -p $(BUILDDIR)

clean:
	@$(RM) -rf $(BUILDDIR)
	@$(RM) -rf $(TARGETDIR)

images: $(TARGETDIR)/$(TARGET)
	esptool.py elf2image $^

flash: images
	esptool.py write_flash 0 $(TARGETDIR)/$(TARGET)-0x00000.bin 0x10000 $(TARGETDIR)/$(TARGET)-0x10000.bin

#Link
$(TARGET): $(OBJECTS)
	$(CC) -o $(TARGETDIR)/$(TARGET) $(LDFLAGS) $^ $(LDLIBS)

#Compile
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INC) -c -o $@ $<

#Non-File Targets
.PHONY: all clean images directories