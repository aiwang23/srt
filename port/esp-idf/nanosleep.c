#include <errno.h>
#include <stdint.h>
#include <time.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_rom_sys.h"

int nanosleep(const struct timespec *req, struct timespec *rem)
{
    if (req == NULL || req->tv_sec < 0 || req->tv_nsec < 0 || req->tv_nsec >= 1000000000L) {
        errno = EINVAL;
        return -1;
    }

    uint64_t totalUs = (uint64_t)req->tv_sec * 1000000ULL + (uint64_t)req->tv_nsec / 1000ULL;

    if (rem != NULL) {
        rem->tv_sec = 0;
        rem->tv_nsec = 0;
    }

    if (totalUs == 0) {
        return 0;
    }

    const uint64_t tickUs = 1000000ULL / configTICK_RATE_HZ;

    if (totalUs >= tickUs) {
        TickType_t ticks = (TickType_t)((totalUs + tickUs - 1) / tickUs);
        vTaskDelay(ticks);
    } else {
        esp_rom_delay_us((uint32_t)totalUs);
    }

    return 0;
}