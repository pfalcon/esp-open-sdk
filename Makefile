#
# General configuration
#

# Copy vendor SDK into toolchain (y) or leave separate (n)
# If yes, the include and lib directories are copied over
STANDALONE = y

# Output directory for the toolchain
TOOLCHAIN = $(TOP)/xtensa-lx106-elf

# Output directory for the vendor SDK
SDKDIR = $(TOP)/sdk

# Version of the vendor SDK. Supported are:
# 0.9.2 0.9.3 0.9.4 0.9.5 0.9.6b1 1.0.0 1.0.1b1 1.0.1b2 1.0.1
# 1.1.0 1.1.1 1.1.2 1.2.0 1.3.0 1.4.0 1.5.0
VENDOR_SDK = 1.4.0

# Makefile setup: first target and phony targets
first: all
.PHONY: first all standalone clean esptool toolchain _toolchain clean-sysroot crosstool-NG _ct-ng libcirom libhal _libhal sdk sdk_patch clean-sdk


#
# Internal variables
#

TOP = $(PWD)
UNRAR = unrar x -o+
UNZIP = unzip -q -o
VENDOR_SDK_ZIP = $(VENDOR_SDK_ZIP_$(VENDOR_SDK))
VENDOR_SDK_DIR = $(VENDOR_SDK_DIR_$(VENDOR_SDK))

VENDOR_SDK_ZIP_1.5.0 = esp_iot_sdk_v1.5.0_15_11_27.zip
VENDOR_SDK_DIR_1.5.0 = esp_iot_sdk_v1.5.0
VENDOR_SDK_ZIP_1.4.0 = esp_iot_sdk_v1.4.0_15_09_18.zip
VENDOR_SDK_DIR_1.4.0 = esp_iot_sdk_v1.4.0
VENDOR_SDK_ZIP_1.3.0 = esp_iot_sdk_v1.3.0_15_08_08.zip
VENDOR_SDK_DIR_1.3.0 = esp_iot_sdk_v1.3.0
VENDOR_SDK_ZIP_1.2.0 = esp_iot_sdk_v1.2.0_15_07_03.zip
VENDOR_SDK_DIR_1.2.0 = esp_iot_sdk_v1.2.0
VENDOR_SDK_ZIP_1.1.2 = esp_iot_sdk_v1.1.2_15_06_12.zip
VENDOR_SDK_DIR_1.1.2 = esp_iot_sdk_v1.1.2
VENDOR_SDK_ZIP_1.1.1 = esp_iot_sdk_v1.1.1_15_06_05.zip
VENDOR_SDK_DIR_1.1.1 = esp_iot_sdk_v1.1.1
VENDOR_SDK_ZIP_1.1.0 = esp_iot_sdk_v1.1.0_15_05_26.zip
VENDOR_SDK_DIR_1.1.0 = esp_iot_sdk_v1.1.0
# MIT-licensed version was released without changing version number
#VENDOR_SDK_ZIP_1.1.0 = esp_iot_sdk_v1.1.0_15_05_22.zip
#VENDOR_SDK_DIR_1.1.0 = esp_iot_sdk_v1.1.0
VENDOR_SDK_ZIP_1.0.1 = esp_iot_sdk_v1.0.1_15_04_24.zip
VENDOR_SDK_DIR_1.0.1 = esp_iot_sdk_v1.0.1
VENDOR_SDK_ZIP_1.0.1b2 = esp_iot_sdk_v1.0.1_b2_15_04_10.zip
VENDOR_SDK_DIR_1.0.1b2 = esp_iot_sdk_v1.0.1_b2
VENDOR_SDK_ZIP_1.0.1b1 = esp_iot_sdk_v1.0.1_b1_15_04_02.zip
VENDOR_SDK_DIR_1.0.1b1 = esp_iot_sdk_v1.0.1_b1
VENDOR_SDK_ZIP_1.0.0 = esp_iot_sdk_v1.0.0_15_03_20.zip
VENDOR_SDK_DIR_1.0.0 = esp_iot_sdk_v1.0.0
VENDOR_SDK_ZIP_0.9.6b1 = esp_iot_sdk_v0.9.6_b1_15_02_15.zip
VENDOR_SDK_DIR_0.9.6b1 = esp_iot_sdk_v0.9.6_b1
VENDOR_SDK_ZIP_0.9.5 = esp_iot_sdk_v0.9.5_15_01_23.zip
VENDOR_SDK_DIR_0.9.5 = esp_iot_sdk_v0.9.5
VENDOR_SDK_ZIP_0.9.4 = esp_iot_sdk_v0.9.4_14_12_19.zip
VENDOR_SDK_DIR_0.9.4 = esp_iot_sdk_v0.9.4
VENDOR_SDK_ZIP_0.9.3 = esp_iot_sdk_v0.9.3_14_11_21.zip
VENDOR_SDK_DIR_0.9.3 = esp_iot_sdk_v0.9.3
VENDOR_SDK_ZIP_0.9.2 = esp_iot_sdk_v0.9.2_14_10_24.zip
VENDOR_SDK_DIR_0.9.2 = esp_iot_sdk_v0.9.2


#
# Global rules
#

all: esptool libcirom standalone sdk sdk_patch $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/libhal.a $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	@echo
	@echo "Xtensa toolchain is built, to use it:"
	@echo
	@echo 'export PATH=$(TOOLCHAIN)/bin:$$PATH'
	@echo
ifneq ($(STANDALONE),y)
	@echo "Espressif ESP8266 SDK is installed. Toolchain contains only Open Source components"
	@echo "To link external proprietary libraries add:"
	@echo
	@echo "xtensa-lx106-elf-gcc -I$(SDKDIR)/include -L$(SDKDIR)/lib"
	@echo
else
	@echo "Espressif ESP8266 SDK is installed, its libraries and headers are merged with the toolchain"
	@echo
endif

standalone: sdk sdk_patch toolchain
ifeq ($(STANDALONE),y)
	@echo "Installing vendor SDK headers into toolchain sysroot"
	@cp -Rf $(SDKDIR)/include/* $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/
	@echo "Installing vendor SDK libs into toolchain sysroot"
	@cp -Rf $(SDKDIR)/lib/* $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/
	@echo "Installing vendor SDK linker scripts into toolchain sysroot"
	@sed -e 's/\r//' $(SDKDIR)/ld/eagle.app.v6.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/eagle.app.v6.ld
	@sed -e 's/\r//' $(SDKDIR)/ld/eagle.rom.addr.v6.ld >$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/eagle.rom.addr.v6.ld
endif

clean: clean-sdk
	make -C crosstool-NG clean MAKELEVEL=0
	-rm -rf crosstool-NG/.build/src
	-rm -rf $(TOOLCHAIN)


#
# Free/Libre Tools
#

# esptool
esptool: $(TOOLCHAIN)/bin/esptool.py

$(TOOLCHAIN)/bin/esptool.py: esptool/esptool.py $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	cp esptool/esptool.py $(TOOLCHAIN)/bin/

# toolchain
toolchain: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc

$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc: crosstool-NG/ct-ng
	make -C crosstool-NG -f ../Makefile _toolchain

_toolchain:
	./ct-ng xtensa-lx106-elf
	sed -r -i.org s%CT_PREFIX_DIR=.*%CT_PREFIX_DIR="$(TOOLCHAIN)"% .config
	sed -r -i s%CT_INSTALL_DIR_RO=y%"#"CT_INSTALL_DIR_RO=y% .config
	cat ../crosstool-config-overrides >> .config
	./ct-ng build

clean-sysroot:
	rm -rf $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/*
	rm -rf $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/*

# crosstools
crosstool-NG: crosstool-NG/ct-ng

crosstool-NG/ct-ng: crosstool-NG/bootstrap
	make -C crosstool-NG -f ../Makefile _ct-ng

_ct-ng:
	./bootstrap
	./configure --prefix=`pwd`
	make MAKELEVEL=0
	make install MAKELEVEL=0

crosstool-NG/bootstrap:
	@echo "You cloned without --recursive, fetching submodules for you."
	git submodule update --init --recursive

# irom version of libc
libcirom: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libcirom.a

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libcirom.a: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libc.a $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	@echo "Creating irom version of libc..."
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-objcopy --rename-section .text=.irom0.text \
		--rename-section .literal=.irom0.literal $(<) $(@);

# libhal
libhal: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/libhal.a

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/libhal.a: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	make -C lx106-hal -f ../Makefile _libhal

_libhal:
	autoreconf -i
	PATH=$(TOOLCHAIN)/bin:$(PATH) ./configure --host=xtensa-lx106-elf --prefix=$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr
	PATH=$(TOOLCHAIN)/bin:$(PATH) make
	PATH=$(TOOLCHAIN)/bin:$(PATH) make install


#
# Non-free SDK
#

# Unpack the (unpatched) SDK
sdk: $(VENDOR_SDK_DIR)/.sdk_unzip
	ln -srnf $(VENDOR_SDK_DIR) $(SDKDIR)

$(VENDOR_SDK_DIR)/.sdk_unzip: $(VENDOR_SDK_ZIP)
	$(UNZIP) $^
	-mv License $(VENDOR_SDK_DIR)
	touch $@

# Patch the SDK
sdk_patch: .sdk_patch_$(VENDOR_SDK)

.sdk_patch_1.5.0: $(VENDOR_SDK_DIR_1.5.0)/.sdk_unzip
	patch -N -d $(VENDOR_SDK_DIR_1.5.0) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.4.0: $(VENDOR_SDK_DIR_1.4.0)/.sdk_unzip
	patch -N -d $(VENDOR_SDK_DIR_1.4.0) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.3.0: $(VENDOR_SDK_DIR_1.3.0)/.sdk_unzip
	patch -N -d $(VENDOR_SDK_DIR_1.3.0) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.2.0: $(VENDOR_SDK_DIR_1.2.0)/.sdk_unzip lib_mem_optimize_150714.zip libssl_patch_1.2.0-2.zip empty_user_rf_pre_init.o
	#$(UNZIP) libssl_patch_1.2.0-2.zip
	#$(UNZIP) libsmartconfig_2.4.2.zip
	$(UNZIP) lib_mem_optimize_150714.zip
	#mv libsmartconfig_2.4.2.a $(VENDOR_SDK_DIR_1.2.0)/lib/libsmartconfig.a
	mv libssl.a libnet80211.a libpp.a libsmartconfig.a $(VENDOR_SDK_DIR_1.2.0)/lib/
	patch -N -f -d $(VENDOR_SDK_DIR_1.2.0) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.2.0)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.2: $(VENDOR_SDK_DIR_1.1.2)/.sdk_unzip scan_issue_test.zip 1.1.2_patch_02.zip empty_user_rf_pre_init.o
	$(UNZIP) scan_issue_test.zip
	$(UNZIP) 1.1.2_patch_02.zip
	mv libmain.a libnet80211.a libpp.a $(VENDOR_SDK_DIR_1.1.2)/lib/
	patch -N -f -d $(VENDOR_SDK_DIR_1.1.2) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.2)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.1: $(VENDOR_SDK_DIR_1.1.1)/.sdk_unzip empty_user_rf_pre_init.o
	patch -N -f -d $(VENDOR_SDK_DIR_1.1.1) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.1)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.0: $(VENDOR_SDK_DIR_1.1.0)/.sdk_unzip lib_patch_on_sdk_v1.1.0.zip empty_user_rf_pre_init.o
	$(UNZIP) lib_patch_on_sdk_v1.1.0.zip
	mv libsmartconfig_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libsmartconfig.a
	mv libmain_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libmain.a
	mv libssl_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libssl.a
	patch -N -f -d $(VENDOR_SDK_DIR_1.1.0) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.0)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.0.1: $(VENDOR_SDK_DIR_1.0.1)/.sdk_unzip libnet80211.zip
	$(UNZIP) libnet80211.zip
	mv libnet80211.a $(VENDOR_SDK_DIR_1.0.1)/lib/
	patch -N -f -d $(VENDOR_SDK_DIR_1.0.1) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.1b2: $(VENDOR_SDK_DIR_1.0.1b2)/.sdk_unzip libssl.zip
	$(UNZIP) libssl.zip
	mv libssl/libssl.a $(VENDOR_SDK_DIR_1.0.1b2)/lib/
	patch -N -d $(VENDOR_SDK_DIR_1.0.1b2) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.1b1: $(VENDOR_SDK_DIR_1.0.1b1)/.sdk_unzip
	patch -N -d $(VENDOR_SDK_DIR_1.0.1b1) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.0: $(VENDOR_SDK_DIR_1.0.0)/.sdk_unzip
	patch -N -d $(VENDOR_SDK_DIR_1.0.0) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.6b1: $(VENDOR_SDK_DIR_0.9.6b1)/.sdk_unzip
	patch -N -d $(VENDOR_SDK_DIR_0.9.6b1) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.5: $(VENDOR_SDK_DIR_0.9.5)/.sdk_unzip sdk095_patch1.zip
	$(UNZIP) sdk095_patch1.zip
	mv libmain_fix_0.9.5.a $(VENDOR_SDK_DIR)/lib/libmain.a
	mv user_interface.h $(VENDOR_SDK_DIR)/include/
	patch -N -d $(VENDOR_SDK_DIR_0.9.5) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.4: $(VENDOR_SDK_DIR_0.9.4)/.sdk_unzip
	patch -N -d $(VENDOR_SDK_DIR_0.9.4) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.3: $(VENDOR_SDK_DIR_0.9.3)/.sdk_unzip esp_iot_sdk_v0.9.3_14_11_21_patch1.zip
	$(UNZIP) esp_iot_sdk_v0.9.3_14_11_21_patch1.zip
	@touch $@

.sdk_patch_0.9.2: $(VENDOR_SDK_DIR_0.9.2)/.sdk_unzip FRM_ERR_PATCH.rar
	$(UNRAR) FRM_ERR_PATCH.rar
	cp FRM_ERR_PATCH/*.a $(VENDOR_SDK_DIR)/lib/
	@touch $@

# Compile object file required by some patches
empty_user_rf_pre_init.o: empty_user_rf_pre_init.c $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc -O2 -c $<

# Download the SDK bundles
esp_iot_sdk_v1.5.0_15_11_27.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=989"
esp_iot_sdk_v1.4.0_15_09_18.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=838"
esp_iot_sdk_v1.3.0_15_08_08.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=664"
esp_iot_sdk_v1.2.0_15_07_03.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=564"
esp_iot_sdk_v1.1.2_15_06_12.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=521"
esp_iot_sdk_v1.1.1_15_06_05.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=484"
esp_iot_sdk_v1.1.0_15_05_26.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=425"
esp_iot_sdk_v1.1.0_15_05_22.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=423"
esp_iot_sdk_v1.0.1_15_04_24.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=325"
esp_iot_sdk_v1.0.1_b2_15_04_10.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=293"
esp_iot_sdk_v1.0.1_b1_15_04_02.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=276"
esp_iot_sdk_v1.0.0_15_03_20.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=250"
esp_iot_sdk_v0.9.6_b1_15_02_15.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=220"
esp_iot_sdk_v0.9.5_15_01_23.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=189"
esp_iot_sdk_v0.9.4_14_12_19.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=111"
esp_iot_sdk_v0.9.3_14_11_21.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=72"
esp_iot_sdk_v0.9.2_14_10_24.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=9"

# Download the patches
FRM_ERR_PATCH.rar:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=10"
esp_iot_sdk_v0.9.3_14_11_21_patch1.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=73"
sdk095_patch1.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=190"
libssl.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=316"
libnet80211.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=361"
lib_patch_on_sdk_v1.1.0.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=432"
scan_issue_test.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=525"
1.1.2_patch_02.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=546"
libssl_patch_1.2.0-1.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=583" -O $@
libssl_patch_1.2.0-2.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=586" -O $@
libsmartconfig_2.4.2.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=585"
lib_mem_optimize_150714.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=594"

clean-sdk:
	rm -rf $(VENDOR_SDK_DIR)
	rm -f $(SDKDIR)
	rm -f .sdk_patch_$(VENDOR_SDK)
