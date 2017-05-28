#include "osapi.h"
#include "user_interface.h"

#include "driver/uart.h"

void ICACHE_FLASH_ATTR sys_init_done_cb() {
    wifi_set_opmode(NULL_MODE);
    os_printf("SDK version:%s\n", system_get_sdk_version());
}

void ICACHE_FLASH_ATTR user_init()
{
    UART_SetBaudrate(UART0, BIT_RATE_115200);
    system_init_done_cb(sys_init_done_cb);
}
