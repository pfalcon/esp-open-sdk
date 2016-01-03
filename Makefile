#
# General configuration
#

# Whether to merge the SDK into the Xtensa toolchain, producing a standalone
# ESP8266 toolchain. Use 'n' if you want a generic Xtensa toolchain
# which can be used with multiple SDK versions.
STANDALONE = y

# Directory to install the toolchain to, by default inside current dir
TOOLCHAIN = $(TOP)/xtensa-lx106-elf

# Directory to install the vendor SDK to, by default inside current dir
SDKDIR = $(TOP)/sdk

# Vendor SDK version to install. Supported are:
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
DWNLOAD = $(TOP)/download
PATCH = patch -b -N
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

all: esptool libcirom libhal standalone
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
	make -C modules/crosstool-NG clean MAKELEVEL=0
	-rm -rf modules/crosstool-NG/.build/src
	-rm -rf $(TOOLCHAIN)


#
# Free/Libre Tools
#

# esptool
esptool: $(TOOLCHAIN)/bin/esptool.py

$(TOOLCHAIN)/bin/esptool.py: modules/esptool/esptool.py $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	cp modules/esptool/esptool.py $(TOOLCHAIN)/bin/

# toolchain
toolchain: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc

$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc: modules/crosstool-NG/ct-ng $(DWNLOAD)/.dir
	mkdir -p modules/crosstool-NG/.build
	ln -srnf $(DWNLOAD) modules/crosstool-NG/.build/tarballs
	make -C modules/crosstool-NG -f ../../Makefile _toolchain

_toolchain:
	./ct-ng xtensa-lx106-elf
	sed -r -i -e "s%^(CT_PREFIX_DIR=).*%\1\"$(TOOLCHAIN)\"%" \
	    -e "s%^CT_INSTALL_DIR_RO=y%#&%" .config
	cat ../../patches/crosstool-config-overrides >> .config
	./ct-ng build

$(DWNLOAD)/.dir:
	mkdir -p $(DWNLOAD)
	@touch -t 200001010000 $@

clean-sysroot:
	rm -rf $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/*
	rm -rf $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/*

# crosstools
crosstool-NG: modules/crosstool-NG/ct-ng

modules/crosstool-NG/ct-ng: modules/crosstool-NG/bootstrap
	make -C modules/crosstool-NG -f ../../Makefile _ct-ng

_ct-ng:
	./bootstrap
	./configure --enable-local
	make install MAKELEVEL=0

modules/crosstool-NG/bootstrap:
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
	make -C modules/lx106-hal -f ../../Makefile _libhal

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

$(VENDOR_SDK_DIR)/.sdk_unzip: $(DWNLOAD)/$(VENDOR_SDK_ZIP)
	$(UNZIP) $^ -d $(VENDOR_SDK_DIR)
	mv $(VENDOR_SDK_DIR)/$(VENDOR_SDK_DIR)/* $(VENDOR_SDK_DIR)/
	rmdir $(VENDOR_SDK_DIR)/$(VENDOR_SDK_DIR)
	@touch $@

# Patch the SDK
sdk_patch: $(VENDOR_SDK_DIR)/.sdk_patch

$(VENDOR_SDK_DIR_1.5.0)/.sdk_patch: $(VENDOR_SDK_DIR_1.5.0)/.sdk_unzip
	$(PATCH) -d $(VENDOR_SDK_DIR_1.5.0) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_1.4.0)/.sdk_patch: $(VENDOR_SDK_DIR_1.4.0)/.sdk_unzip
	$(PATCH) -d $(VENDOR_SDK_DIR_1.4.0) -p1 < patches/c_types-c99.patch
	$(PATCH) -d $(VENDOR_SDK_DIR_1.4.0) -p1 < patches/dhcps_lease.patch
	@touch $@

$(VENDOR_SDK_DIR_1.3.0)/.sdk_patch: $(VENDOR_SDK_DIR_1.3.0)/.sdk_unzip
	$(PATCH) -d $(VENDOR_SDK_DIR_1.3.0) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_1.2.0)/.sdk_patch: $(VENDOR_SDK_DIR_1.2.0)/.sdk_unzip $(DWNLOAD)/lib_mem_optimize_150714.zip $(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o #$(DWNLOAD)/libsmartconfig_2.4.2.zip $(DWNLOAD)/libssl_patch_1.2.0-2.zip
	$(UNZIP) $(DWNLOAD)/lib_mem_optimize_150714.zip -d $(VENDOR_SDK_DIR_1.2.0)/lib/
	#$(UNZIP) $(DWNLOAD)/libssl_patch_1.2.0-2.zip -d $(VENDOR_SDK_DIR_1.2.0)/lib/
	#$(UNZIP) $(DWNLOAD)/libsmartconfig_2.4.2.zip -d $(VENDOR_SDK_DIR_1.2.0)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR_1.2.0) -p1 < patches/c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.2.0)/lib/libmain.a $(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o
	@touch $@

$(VENDOR_SDK_DIR_1.1.2)/.sdk_patch: $(VENDOR_SDK_DIR_1.1.2)/.sdk_unzip $(DWNLOAD)/scan_issue_test.zip $(DWNLOAD)/1.1.2_patch_02.zip $(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o
	$(UNZIP) $(DWNLOAD)/scan_issue_test.zip -d $(VENDOR_SDK_DIR_1.1.2)/lib/
	$(UNZIP) $(DWNLOAD)/1.1.2_patch_02.zip -d $(VENDOR_SDK_DIR_1.1.2)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR_1.1.2) -p1 < patches/c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.2)/lib/libmain.a $(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o
	@touch $@

$(VENDOR_SDK_DIR_1.1.1)/.sdk_patch: $(VENDOR_SDK_DIR_1.1.1)/.sdk_unzip $(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o
	$(PATCH) -f -d $(VENDOR_SDK_DIR_1.1.1) -p1 < patches/c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.1)/lib/libmain.a $(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o
	@touch $@

$(VENDOR_SDK_DIR_1.1.0)/.sdk_patch: $(VENDOR_SDK_DIR_1.1.0)/.sdk_unzip $(DWNLOAD)/lib_patch_on_sdk_v1.1.0.zip $(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o
	$(UNZIP) $(DWNLOAD)/lib_patch_on_sdk_v1.1.0.zip -d $(VENDOR_SDK_DIR_1.1.0)/lib/
	mv $(VENDOR_SDK_DIR_1.1.0)/lib/libsmartconfig_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libsmartconfig.a
	mv $(VENDOR_SDK_DIR_1.1.0)/lib/libmain_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libmain.a
	mv $(VENDOR_SDK_DIR_1.1.0)/lib/libssl_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libssl.a
	$(PATCH) -f -d $(VENDOR_SDK_DIR_1.1.0) -p1 < patches/c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.0)/lib/libmain.a $(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o
	@touch $@

$(VENDOR_SDK_DIR_1.0.1)/.sdk_patch: $(VENDOR_SDK_DIR_1.0.1)/.sdk_unzip $(DWNLOAD)/libnet80211.zip
	$(UNZIP) $(DWNLOAD)/libnet80211.zip -d $(VENDOR_SDK_DIR_1.0.1)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR_1.0.1) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_1.0.1b2)/.sdk_patch: $(VENDOR_SDK_DIR_1.0.1b2)/.sdk_unzip $(DWNLOAD)/libssl.zip
	$(UNZIP) $(DWNLOAD)/libssl.zip -d $(VENDOR_SDK_DIR_1.0.1b2)/
	mv $(VENDOR_SDK_DIR_1.0.1b2)/libssl/libssl.a $(VENDOR_SDK_DIR_1.0.1b2)/lib/
	rmdir $(VENDOR_SDK_DIR_1.0.1b2)/libssl
	$(PATCH) -d $(VENDOR_SDK_DIR_1.0.1b2) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_1.0.1b1)/.sdk_patch: $(VENDOR_SDK_DIR_1.0.1b1)/.sdk_unzip
	$(PATCH) -d $(VENDOR_SDK_DIR_1.0.1b1) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_1.0.0)/.sdk_patch: $(VENDOR_SDK_DIR_1.0.0)/.sdk_unzip
	$(PATCH) -d $(VENDOR_SDK_DIR_1.0.0) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_0.9.6b1)/.sdk_patch: $(VENDOR_SDK_DIR_0.9.6b1)/.sdk_unzip
	$(PATCH) -d $(VENDOR_SDK_DIR_0.9.6b1) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_0.9.5)/.sdk_patch: $(VENDOR_SDK_DIR_0.9.5)/.sdk_unzip $(DWNLOAD)/sdk095_patch1.zip
	$(UNZIP) $(DWNLOAD)/sdk095_patch1.zip -d $(VENDOR_SDK_DIR_0.9.5)/
	mv $(VENDOR_SDK_DIR_0.9.5)/libmain_fix_0.9.5.a $(VENDOR_SDK_DIR_0.9.5)/lib/libmain.a
	mv $(VENDOR_SDK_DIR_0.9.5)/user_interface.h $(VENDOR_SDK_DIR_0.9.5)/include/
	$(PATCH) -d $(VENDOR_SDK_DIR_0.9.5) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_0.9.4)/.sdk_patch: $(VENDOR_SDK_DIR_0.9.4)/.sdk_unzip
	$(PATCH) -d $(VENDOR_SDK_DIR_0.9.4) -p1 < patches/c_types-c99.patch
	@touch $@

$(VENDOR_SDK_DIR_0.9.3)/.sdk_patch: $(VENDOR_SDK_DIR_0.9.3)/.sdk_unzip $(DWNLOAD)/esp_iot_sdk_v0.9.3_14_11_21_patch1.zip
	$(UNZIP) $(DWNLOAD)/esp_iot_sdk_v0.9.3_14_11_21_patch1.zip
	@touch $@

$(VENDOR_SDK_DIR_0.9.2)/.sdk_patch: $(VENDOR_SDK_DIR_0.9.2)/.sdk_unzip $(DWNLOAD)/FRM_ERR_PATCH.rar
	cd $(VENDOR_SDK_DIR_0.9.2) && $(UNRAR) $(DWNLOAD)/FRM_ERR_PATCH.rar
	mv $(VENDOR_SDK_DIR_0.9.2)/FRM_ERR_PATCH/*.a $(VENDOR_SDK_DIR_0.9.2)/lib/
	@touch $@

# Compile object file required by some patches
$(VENDOR_SDK_DIR)/.build/empty_user_rf_pre_init.o: patches/empty_user_rf_pre_init.c $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	mkdir -p $(VENDOR_SDK_DIR)/.build
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc -O2 -c $< -o $@

# Download the SDK bundles
$(DWNLOAD)/esp_iot_sdk_v1.5.0_15_11_27.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=989"
$(DWNLOAD)/esp_iot_sdk_v1.4.0_15_09_18.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=838"
$(DWNLOAD)/esp_iot_sdk_v1.3.0_15_08_08.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=664"
$(DWNLOAD)/esp_iot_sdk_v1.2.0_15_07_03.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=564"
$(DWNLOAD)/esp_iot_sdk_v1.1.2_15_06_12.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=521"
$(DWNLOAD)/esp_iot_sdk_v1.1.1_15_06_05.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=484"
$(DWNLOAD)/esp_iot_sdk_v1.1.0_15_05_26.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=425"
# URL errors out w/ 404
#$(DWNLOAD)/esp_iot_sdk_v1.1.0_15_05_22.zip: $(DWNLOAD)/.dir
#	wget -O $@ "http://bbs.espressif.com/download/file.php?id=423"
$(DWNLOAD)/esp_iot_sdk_v1.0.1_15_04_24.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=325"
$(DWNLOAD)/esp_iot_sdk_v1.0.1_b2_15_04_10.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=293"
$(DWNLOAD)/esp_iot_sdk_v1.0.1_b1_15_04_02.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=276"
$(DWNLOAD)/esp_iot_sdk_v1.0.0_15_03_20.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=250"
$(DWNLOAD)/esp_iot_sdk_v0.9.6_b1_15_02_15.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=220"
$(DWNLOAD)/esp_iot_sdk_v0.9.5_15_01_23.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=189"
$(DWNLOAD)/esp_iot_sdk_v0.9.4_14_12_19.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=111"
$(DWNLOAD)/esp_iot_sdk_v0.9.3_14_11_21.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=72"
$(DWNLOAD)/esp_iot_sdk_v0.9.2_14_10_24.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=9"

# Download the patches
$(DWNLOAD)/FRM_ERR_PATCH.rar: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=10"
$(DWNLOAD)/esp_iot_sdk_v0.9.3_14_11_21_patch1.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=73"
$(DWNLOAD)/sdk095_patch1.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=190"
$(DWNLOAD)/libssl.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=316"
$(DWNLOAD)/libnet80211.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=361"
$(DWNLOAD)/lib_patch_on_sdk_v1.1.0.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=432"
$(DWNLOAD)/scan_issue_test.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=525"
$(DWNLOAD)/1.1.2_patch_02.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=546"
$(DWNLOAD)/libssl_patch_1.2.0-1.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=583"
$(DWNLOAD)/libssl_patch_1.2.0-2.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=586"
# URL errors out w/ 404
#$(DWNLOAD)/libsmartconfig_2.4.2.zip: $(DWNLOAD)/.dir
#	wget -O $@ "http://bbs.espressif.com/download/file.php?id=585"
$(DWNLOAD)/lib_mem_optimize_150714.zip: $(DWNLOAD)/.dir
	wget -O $@ "http://bbs.espressif.com/download/file.php?id=594"

clean-sdk:
	rm -rf $(VENDOR_SDK_DIR)
	rm -f $(SDKDIR)
