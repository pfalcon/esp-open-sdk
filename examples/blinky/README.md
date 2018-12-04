## Blinky

When successfully configured, built and written to the flash memory of an ESP8266 module or development board, this "Hello World" project continuously toggles a LED on the target on and off, at a rate of one cycle per second.

This project provides a simple way to check the basic functionality of the development environment and targeted hardware. It is a good way to perform initial sanity testing of a new installation of the SDK or a new hardware target.

To build the firmware and write it to the target:

    $ make flash

### Troubleshooting

* "Permission Denied" when attempting to write the firmware may be due to your user account not having access to the serial port. On many Linux distributions, this can be fixed by adding your account to the dialout group with:

    `$ sudo usermod -a -G dialout <username>`

* If, after writing the firmware, the LEDs stay on or off, check that the correct GPIO pin is configured for the LED in `blinky.c`. To find the correct pin, check schematics and datasheets for your hardware. Note that development boards typically have two user controllable LEDs, one on the ESP8266 module and one on the development board. E.g., NodeMCU development boards typically use the ESP-12 module, which has a LED on pin 2, while the dev board itself has a LED on a different pin.

* If, after writing the firmware, the LED is flashing, but at a much higher rate than one one-off cycle per second, the module has failed to boot the new firmware, and is writing error messages to the serial port. The messages may be handy for further searching online. To retrieve them, connect a terminal program to the same serial port that was used when writing to the module, set the baudrate to 74880 and mode to 8-N-1 asynchronous.

* If the module fails to boot (LED is flashing at a high rate), a block of initialization data may be missing from the module, or the data may not match the current version of the SDK. The correct initialization data is included with the SDK. It can be written to the module with a command such as this:

    `$ esptool.py write_flash 0x3fc000 esp-open-sdk/ESP8266_NONOS_SDK_V2.0.0_16_08_10/bin/esp_init_data_default.bin`

    Note that to the appropriate memory address (`0x3fc00 above`) may be different for your module. See [SDK Init Data](https://github.com/nodemcu/nodemcu-firmware/blob/master/docs/en/flash.md#sdk-init-data) for more information.

    For more background information, also see [issue 279](https://github.com/pfalcon/esp-open-sdk/issues/279).
