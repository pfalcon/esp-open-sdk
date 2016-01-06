/* esp_protos.h - Prototypes for ROM and SDK functions
 *
 * Provide prototypes for functions named in (some versions of) the
 * SDK headers but not declared. Divided by functions in the ROM
 * and functions provided in the binary SDK libraries.
 *
 * Sources given are:
 * [1] SDK API Guide: http://bbs.espressif.com/download/file.php?id=1027
 * [2] cppreference.com: http://en.cppreference.com/w/c
 * [3] IoT_Demo in v0.9.2 SDK
 *
 * Variadic functions have GCC __attribute__ ((format))
 *
 * This file is released into the public domain.
 */
#ifndef HAVE_ESP_PROTOS_H
#define HAVE_ESP_PROTOS_H


#include <ets_sys.h>
#include <mem.h>
#include <stddef.h>
#include <stdint.h>


/*
 * ROM functions
 */
void ets_bzero(void *p, size_t n); /*[1]*/
void ets_delay_us(uint16_t us); /*[2]*/
void ets_install_putc1(void(*p)(char c)); /*[1]*/
/* TBD: ets_install_putc2 */
void ets_intr_lock(void);
void ets_intr_unlock(void);
void ets_isr_attach(int intr, void(*hdlr)(void *), void *arg);
void ets_isr_mask(unsigned int mask);
void ets_isr_unmask(unsigned int mask);
int ets_memcmp(const void *lhs, const void *rhs, size_t count); /*[2]*/
void *ets_memcpy(void *dest, const void *src, size_t count); /*[2]*/
void *ets_memmove(void *dest, const void *src, size_t count); /*[2]*/
void *ets_memset(void *dest, int ch, size_t count); /*[2]*/
int ets_putc(int ch); /*[3]*/
/* TBD: ets_str2macaddr */
int ets_strcmp(const char *lhs, const char *rhs); /*[2]*/
char *ets_strcpy(char *dest, const char *src); /*[2]*/
size_t ets_strlen(const char *str); /*[2]*/
int ets_strncmp(const char *lhs, const char *rhs, size_t count); /*[2]*/
char *ets_strncpy(char *dest, const char *src, size_t count); /*[2]*/
char *ets_strstr(const char *str, const char *substr); /*[2]*/
void ets_timer_disarm(ETSTimer *ptimer); /*[1]*/
/* TBD: ets_timer_done */
/* TBD: ets_timer_handler_isr */
/* TBD: ets_timer_init */
void ets_timer_setfn(ETSTimer *ptimer, ETSTimerFunc *pfunction, void *parg); /*[1]*/
/* TBD: ets_update_cpu_frequency */


/*
 * SDK functions
 */
#ifdef MEMLEAK_DEBUG_ENABLE
#    define MEMLEAK_DEBUG_EXTRA_ARGS , const char *file, int line
#else
#    define MEMLEAK_DEBUG_EXTRA_ARGS
#endif
void NmiTimSetFunc(void (*func)(void));
int ets_sprintf(char *buffer, const char *format, ...) __attribute__ ((format (printf, 2, 3))); /*[2]*/
void ets_timer_arm_new(ETSTimer *ptimer, uint32_t micro_milli_seconds, bool repeat_flag, bool is_milliseconds); /*[1]*/
void ets_timer_disarm(ETSTimer *ptimer); /*[1]*/
void ets_timer_setfn(ETSTimer *ptimer, ETSTimerFunc *pfunction, void *parg); /*[1]*/
int os_printf_plus(const char *format, ...) __attribute__ ((format (printf, 1, 2))); /*[2]*/
void *pvPortCalloc(size_t size, const char *file, int line);
void *pvPortMalloc(size_t size MEMLEAK_DEBUG_EXTRA_ARGS);
void *realloc(void *ptr, size_t new_size, const char *file, int line);
void *pvPortZalloc(size_t size MEMLEAK_DEBUG_EXTRA_ARGS);
void vPortFree(void *ptr MEMLEAK_DEBUG_EXTRA_ARGS);


#endif  /* HAVE_ESP_PROTOS_H */
