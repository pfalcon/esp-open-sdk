TOP=$(PWD)
TOOLCHAIN=$(TOP)/toolchain

all: sdk_patch $(TOOLCHAIN)/lib/libhal.a $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	@echo
	@echo "Xtensa toolchain is built, to use it:"
	@echo
	@echo 'export PATH=$(TOOLCHAIN)/bin:$$PATH'
	@echo
	@echo "Espressif ESP8266 SDK is installed, to use it run compiler as follows:"
	@echo
	@echo "xtensa-lx106-elf-gcc -I$(TOP)/sdk/include -L$(TOP)/sdk/lib"
	@echo

sdk_patch: sdk/lib/libpp.a

sdk/lib/libpp.a: esp_iot_sdk_v0.9.2/.dir FRM_ERR_PATCH.rar
	unrar x -o+ FRM_ERR_PATCH.rar
	cp FRM_ERR_PATCH/*.a $$(dirname $@)

FRM_ERR_PATCH.rar:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=10"

esp_iot_sdk_v0.9.2/.dir: esp_iot_sdk_v0.9.2_14_10_24.zip
	unzip $^
	ln -s $$(dirname $@) sdk
	touch $@

esp_iot_sdk_v0.9.2_14_10_24.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=9"

$(TOOLCHAIN)/lib/libhal.a: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	make -C lx106-hal -f ../Makefile libhal

libhal:
	autoreconf -i
	PATH=$(TOOLCHAIN)/bin:$(PATH) ./configure --host=xtensa-lx106-elf --prefix=$(TOOLCHAIN)
	PATH=$(TOOLCHAIN)/bin:$(PATH) make
	PATH=$(TOOLCHAIN)/bin:$(PATH) make install


$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc: crosstool-NG/ct-ng
	make -C crosstool-NG -f ../Makefile toolchain

toolchain:
	./ct-ng xtensa-lx106-elf
	sed -r -i.org s%CT_PREFIX_DIR=.*%CT_PREFIX_DIR="$(TOOLCHAIN)"% .config
	sed -r -i s%CT_INSTALL_DIR_RO=y%"#"CT_INSTALL_DIR_RO=y% .config
	./ct-ng build

crosstool-NG/ct-ng:
	make -C crosstool-NG -f ../Makefile ct-ng

ct-ng:
	./bootstrap
	./configure --prefix=`pwd`
	make MAKELEVEL=0
	make install MAKELEVEL=0
