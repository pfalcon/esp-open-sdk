
# Whether to merge SDK into Xtensa toolchain, producing standalone
# ESP8266 toolchain. Use 'n' if you want generic Xtensa toolchain
# which can be used with multiple SDK versions.
STANDALONE = y

# Directory to install toolchain to, by default inside current dir.
TOOLCHAIN = $(TOP)/xtensa-lx106-elf


# Vendor SDK version to install, see VENDOR_SDK_ZIP_* vars below
# for supported versions.
VENDOR_SDK = 2.1.0-18-g61248df

.PHONY: crosstool-NG toolchain libhal libcirom sdk



TOP = $(PWD)
SHELL = /bin/bash
PATCH = patch -b -N
UNZIP = unzip -q -o
VENDOR_SDK_ZIP = $(VENDOR_SDK_ZIP_$(VENDOR_SDK))
VENDOR_SDK_DIR = $(VENDOR_SDK_DIR_$(VENDOR_SDK))

VENDOR_SDK_DIR_2.1.0-18-g61248df = ESP8266_NONOS_SDK-2.1.0-18-g61248df
VENDOR_SDK_ZIP_2.1.0 = ESP8266_NONOS_SDK-2.1.0.zip
VENDOR_SDK_DIR_2.1.0 = ESP8266_NONOS_SDK-2.1.0
VENDOR_SDK_ZIP_2.0.0 = ESP8266_NONOS_SDK_V2.0.0_16_08_10.zip
VENDOR_SDK_DIR_2.0.0 = ESP8266_NONOS_SDK_V2.0.0_16_08_10
VENDOR_SDK_ZIP_1.5.4 = ESP8266_NONOS_SDK_V1.5.4_16_05_20.zip
VENDOR_SDK_DIR_1.5.4 = ESP8266_NONOS_SDK_V1.5.4_16_05_20
VENDOR_SDK_ZIP_1.5.3 = ESP8266_NONOS_SDK_V1.5.3_16_04_18.zip
VENDOR_SDK_DIR_1.5.3 = ESP8266_NONOS_SDK_V1.5.3_16_04_18/ESP8266_NONOS_SDK
VENDOR_SDK_ZIP_1.5.2 = ESP8266_NONOS_SDK_V1.5.2_16_01_29.zip
VENDOR_SDK_DIR_1.5.2 = esp_iot_sdk_v1.5.2
VENDOR_SDK_ZIP_1.5.1 = ESP8266_NONOS_SDK_V1.5.1_16_01_08.zip
VENDOR_SDK_DIR_1.5.1 = esp_iot_sdk_v1.5.1
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



all: esptool libcirom standalone sdk sdk_patch $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/libhal.a $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc lwip
	@echo
	@echo "Xtensa toolchain is built, to use it:"
	@echo
	@echo 'export PATH=$(TOOLCHAIN)/bin:$$PATH'
	@echo
ifneq ($(STANDALONE),y)
	@echo "Espressif ESP8266 SDK is installed. Toolchain contains only Open Source components"
	@echo "To link external proprietary libraries add:"
	@echo
	@echo "xtensa-lx106-elf-gcc -I$(TOP)/sdk/include -L$(TOP)/sdk/lib"
	@echo
else
	@echo "Espressif ESP8266 SDK is installed, its libraries and headers are merged with the toolchain"
	@echo
endif

standalone: sdk sdk_patch toolchain
ifeq ($(STANDALONE),y)
	@echo "Installing vendor SDK headers into toolchain sysroot"
	@cp -Rf sdk/include/* $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/
	@echo "Installing vendor SDK libs into toolchain sysroot"
	@cp -Rf sdk/lib/* $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/
	@echo "Installing vendor SDK linker scripts into toolchain sysroot"
	@sed -e 's/\r//' sdk/ld/eagle.app.v6.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/eagle.app.v6.ld
	@sed -e 's/\r//' sdk/ld/eagle.rom.addr.v6.ld >$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/eagle.rom.addr.v6.ld
endif

clean: clean-sdk
	$(MAKE) -C crosstool-NG clean MAKELEVEL=0
	-rm -f crosstool-NG/.built
	-rm -rf crosstool-NG/.build/src
	-rm -f crosstool-NG/local-patches/gcc/4.8.5/1000-*
	-rm -rf $(TOOLCHAIN)

clean-sdk:
	rm -rf $(VENDOR_SDK_DIR)
	rm -f sdk
	rm -f .sdk_patch_$(VENDOR_SDK)
	rm -f user_rf_cal_sector_set.o empty_user_rf_pre_init.o
	$(MAKE) -C esp-open-lwip -f Makefile.open clean

clean-sysroot:
	rm -rf $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/*
	rm -rf $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/*


esptool: toolchain
	cp esptool/esptool.py $(TOOLCHAIN)/bin/

toolchain $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libc.a: crosstool-NG/.built

crosstool-NG/.built: crosstool-NG/ct-ng
	cp -f 1000-mforce-l32.patch crosstool-NG/local-patches/gcc/4.8.5/
	$(MAKE) -C crosstool-NG -f ../Makefile _toolchain
	touch $@

_toolchain:
	./ct-ng xtensa-lx106-elf
	sed -r -i.org s%CT_PREFIX_DIR=.*%CT_PREFIX_DIR="$(TOOLCHAIN)"% .config
	sed -r -i s%CT_INSTALL_DIR_RO=y%"#"CT_INSTALL_DIR_RO=y% .config
	cat ../crosstool-config-overrides >> .config
	./ct-ng build


crosstool-NG: crosstool-NG/ct-ng

crosstool-NG/ct-ng: crosstool-NG/bootstrap
	$(MAKE) -C crosstool-NG -f ../Makefile _ct-ng

_ct-ng:
	./bootstrap
	./configure --prefix=`pwd` --with-bash=/bin/bash
	$(MAKE) MAKELEVEL=0
	$(MAKE) install MAKELEVEL=0

crosstool-NG/bootstrap:
	@echo "You cloned without --recursive, fetching submodules for you."
	git submodule update --init --recursive

libcirom: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libcirom.a

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libcirom.a: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libc.a $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	@echo "Creating irom version of libc..."
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-objcopy --rename-section .text=.irom0.text \
		--rename-section .literal=.irom0.literal $(<) $(@);

libhal: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/libhal.a

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/libhal.a: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	$(MAKE) -C lx106-hal -f ../Makefile _libhal

_libhal:
	autoreconf -i
	PATH="$(TOOLCHAIN)/bin:$(PATH)" ./configure --host=xtensa-lx106-elf --prefix=$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr
	PATH="$(TOOLCHAIN)/bin:$(PATH)" $(MAKE)
	PATH="$(TOOLCHAIN)/bin:$(PATH)" $(MAKE) install



sdk: $(VENDOR_SDK_DIR)/.dir
	ln -snf $(VENDOR_SDK_DIR) sdk

$(VENDOR_SDK_DIR)/.dir: $(VENDOR_SDK_ZIP)
	$(UNZIP) $^
	-mv License $(VENDOR_SDK_DIR)
	touch $@

$(VENDOR_SDK_DIR_2.1.0-18-g61248df)/.dir:
	echo $(VENDOR_SDK_DIR_2.1.0-18-g61248df)
	git clone https://github.com/espressif/ESP8266_NONOS_SDK $(VENDOR_SDK_DIR_2.1.0-18-g61248df)
	(cd $(VENDOR_SDK_DIR_2.1.0-18-g61248df); git checkout 61248df5f6)
	touch $@

$(VENDOR_SDK_DIR_2.1.0)/.dir: $(VENDOR_SDK_ZIP_2.1.0)
	$(UNZIP) $^
	touch $@

$(VENDOR_SDK_DIR_2.0.0)/.dir: $(VENDOR_SDK_ZIP_2.0.0)
	$(UNZIP) $^
	mv ESP8266_NONOS_SDK $(VENDOR_SDK_DIR_2.0.0)
	-mv License $(VENDOR_SDK_DIR)
	touch $@

$(VENDOR_SDK_DIR_1.5.4)/.dir: $(VENDOR_SDK_ZIP_1.5.4)
	$(UNZIP) $^
	mv ESP8266_NONOS_SDK $(VENDOR_SDK_DIR_1.5.4)
	-mv License $(VENDOR_SDK_DIR)
	touch $@

sdk_patch: $(VENDOR_SDK_DIR)/.dir .sdk_patch_$(VENDOR_SDK)

.sdk_patch_2.1.0-18-g61248df .sdk_patch_2.1.0: user_rf_cal_sector_set.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 020100" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99_sdk_2.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR)/lib/libmain.a user_rf_cal_sector_set.o
	@touch $@

.sdk_patch_2.0.0: ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip user_rf_cal_sector_set.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 020000" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip
	mv libmain.a libnet80211.a libpp.a $(VENDOR_SDK_DIR_2.0.0)/lib/
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99_sdk_2.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR)/lib/libmain.a user_rf_cal_sector_set.o
	@touch $@

.sdk_patch_1.5.4:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010504" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.5.3:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010503" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.5.2: Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010502" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip
	mv libssl.a libnet80211.a libmain.a $(VENDOR_SDK_DIR_1.5.2)/lib/
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.5.1:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010501" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.5.0:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010500" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.4.0:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010400" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < dhcps_lease.patch
	@touch $@

.sdk_patch_1.3.0:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010300" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.2.0: lib_mem_optimize_150714.zip libssl_patch_1.2.0-2.zip empty_user_rf_pre_init.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010200" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	#$(UNZIP) libssl_patch_1.2.0-2.zip
	#$(UNZIP) libsmartconfig_2.4.2.zip
	$(UNZIP) lib_mem_optimize_150714.zip
	#mv libsmartconfig_2.4.2.a $(VENDOR_SDK_DIR_1.2.0)/lib/libsmartconfig.a
	mv libssl.a libnet80211.a libpp.a libsmartconfig.a $(VENDOR_SDK_DIR_1.2.0)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.2.0)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.2: scan_issue_test.zip 1.1.2_patch_02.zip empty_user_rf_pre_init.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010102" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) scan_issue_test.zip
	$(UNZIP) 1.1.2_patch_02.zip
	mv libmain.a libnet80211.a libpp.a $(VENDOR_SDK_DIR_1.1.2)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.2)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.1: empty_user_rf_pre_init.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010101" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.1)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.0: lib_patch_on_sdk_v1.1.0.zip empty_user_rf_pre_init.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010100" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) $<
	mv libsmartconfig_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libsmartconfig.a
	mv libmain_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libmain.a
	mv libssl_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libssl.a
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.0)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.0.1: libnet80211.zip esp_iot_sdk_v1.0.1/.dir
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010001" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) $<
	mv libnet80211.a $(VENDOR_SDK_DIR_1.0.1)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.1b2: libssl.zip esp_iot_sdk_v1.0.1_b2/.dir
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010001" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) $<
	mv libssl/libssl.a $(VENDOR_SDK_DIR_1.0.1b2)/lib/
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.1b1:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010001" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.0:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010000" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.6b1:
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.5: sdk095_patch1.zip esp_iot_sdk_v0.9.5/.dir
	$(UNZIP) $<
	mv libmain_fix_0.9.5.a $(VENDOR_SDK_DIR)/lib/libmain.a
	mv user_interface.h $(VENDOR_SDK_DIR)/include/
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.4:
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.3: esp_iot_sdk_v0.9.3_14_11_21_patch1.zip esp_iot_sdk_v0.9.3/.dir
	$(UNZIP) $<
	@touch $@

.sdk_patch_0.9.2: FRM_ERR_PATCH.rar esp_iot_sdk_v0.9.2/.dir 
	unrar x -o+ $<
	cp FRM_ERR_PATCH/*.a $(VENDOR_SDK_DIR)/lib/
	@touch $@

empty_user_rf_pre_init.o: empty_user_rf_pre_init.c $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc $(VENDOR_SDK_DIR)/.dir
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc -O2 -I$(VENDOR_SDK_DIR)/include -c $<

user_rf_cal_sector_set.o: user_rf_cal_sector_set.c $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc $(VENDOR_SDK_DIR)/.dir
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc -O2 -I$(VENDOR_SDK_DIR)/include -c $<

lwip: toolchain sdk_patch
ifeq ($(STANDALONE),y)
	$(MAKE) -C esp-open-lwip -f Makefile.open install \
	    CC=$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc \
	    AR=$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar \
	    PREFIX=$(TOOLCHAIN)
	cp -a esp-open-lwip/include/arch esp-open-lwip/include/lwip esp-open-lwip/include/netif \
	    esp-open-lwip/include/lwipopts.h \
	    $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/
endif


ESP8266_NONOS_SDK-2.1.0.zip:
	wget --content-disposition "https://github.com/espressif/ESP8266_NONOS_SDK/archive/v2.1.0.zip"
# The only change wrt to ESP8266_NONOS_SDK_V2.0.0_16_07_19.zip is licensing blurb in source/
# header files. Libs are the same (and patch is required just the same).
ESP8266_NONOS_SDK_V2.0.0_16_08_10.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1690"
ESP8266_NONOS_SDK_V2.0.0_16_07_19.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1613"
ESP8266_NONOS_SDK_V1.5.4_16_05_20.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1469"
ESP8266_NONOS_SDK_V1.5.3_16_04_18.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1361"
ESP8266_NONOS_SDK_V1.5.2_16_01_29.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1079"
ESP8266_NONOS_SDK_V1.5.1_16_01_08.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1046"
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
Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1168"
ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1654"
