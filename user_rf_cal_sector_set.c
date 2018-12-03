#include <c_types.h>
#include <spi_flash.h>

/* Set the target flash sector to store RF_CAL parameters from user controlled
 * flash storage space..
 * Make this a weak symbol so a program can easily supply their own version.
 */
__attribute__ ((weak))
uint32 user_rf_cal_sector_set(void) {
    extern char flashchip;
    SpiFlashChip *flash = (SpiFlashChip*)(&flashchip + 4);
    // We know that sector size in 4096
    //uint32_t sec_num = flash->chip_size / flash->sector_size;
    uint32_t sec_num = flash->chip_size >> 12;
    return sec_num - 5;
}
